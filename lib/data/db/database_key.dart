/// The database encryption key and the one-time encryption of an old file.
///
/// BUILD_PLAN.md Section 12: the SQLite file is encrypted with SQLCipher and
/// the key lives in the platform keystore. `pubspec.yaml` makes
/// `package:sqlite3` bundle SQLCipher; this file decides which key opens the
/// file and makes sure the file on disk is encrypted with it.
///
/// No Flutter and no plugins here, so the logic runs in plain VM tests. The
/// keystore itself sits behind [DatabaseKeyStore].
library;

import 'dart:io';
import 'dart:math';

import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:sqlite3/sqlite3.dart';

/// Where the key is kept. On a device this is the platform keystore.
abstract interface class DatabaseKeyStore {
  Future<String?> read();

  Future<void> write(String key);
}

/// The first 16 bytes of every unencrypted SQLite file. An SQLCipher file
/// starts with random bytes instead.
const String _plaintextHeader = 'SQLite format 3\u0000';

final RegExp _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// The statement that unlocks a connection. The key is 32 raw bytes in hex,
/// so SQLCipher uses it directly instead of deriving a key from a password.
String keyPragma(String hexKey) => "PRAGMA key = \"x'$hexKey'\"";

/// Unlocks [db] with [hexKey] and proves the file really is encrypted.
///
/// Throws instead of carrying on unencrypted: if the app was ever built
/// without SQLCipher, `PRAGMA key` would be ignored silently and balances
/// would be written in plain text.
void applyKey(CommonDatabase db, String hexKey) {
  if (db.select('PRAGMA cipher_version').isEmpty) {
    throw StateError(
      'SQLCipher is not linked into this build. Refusing to open the '
      'database unencrypted. Check `hooks: user_defines: sqlite3` in '
      'pubspec.yaml.',
    );
  }
  db.execute(keyPragma(hexKey));
  // The key is only checked on the first read. Read now, so a wrong key
  // fails here rather than halfway through a query.
  db.select('SELECT count(*) FROM sqlite_master');
}

/// Returns the stored key, or creates, stores and returns a new one.
Future<String> loadOrCreateKey(DatabaseKeyStore store) async {
  final String? existing = await store.read();
  if (existing != null && _hexKey.hasMatch(existing)) {
    return existing;
  }
  final Random random = Random.secure();
  final String key = List<String>.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  await store.write(key);
  return key;
}

/// Whether [file] is an SQLite database that is not encrypted.
bool isPlaintextSqlite(File file) {
  if (!file.existsSync()) {
    return false;
  }
  final RandomAccessFile handle = file.openSync();
  try {
    return String.fromCharCodes(handle.readSync(16)) == _plaintextHeader;
  } finally {
    handle.closeSync();
  }
}

/// Makes the file at [path] safe to open with the returned key.
///
/// - No file: a fresh install. Returns a new key.
/// - An unencrypted file, from a build before encryption: encrypts it in
///   place, keeping every row and the schema version.
/// - An encrypted file and its key: leaves both alone.
/// - An encrypted file whose key is gone, for example because the keystore
///   was reset: the file can never be read again. It is renamed to
///   `<name>.unreadable-<n>` rather than deleted, and the app starts empty
///   with a new key instead of failing on every launch.
Future<String> prepareDatabaseFile(String path, DatabaseKeyStore store) async {
  final File file = File(path);
  final File pending = File('$path.encrypting');

  // A previous encryption finished writing the new file but stopped before
  // the swap. The new file is complete; finish the swap.
  if (!file.existsSync() && pending.existsSync()) {
    pending.renameSync(path);
  }

  if (!file.existsSync()) {
    return loadOrCreateKey(store);
  }
  if (file.lengthSync() == 0) {
    file.deleteSync();
    return loadOrCreateKey(store);
  }
  if (isPlaintextSqlite(file)) {
    final String key = await loadOrCreateKey(store);
    _encryptInPlace(path, key);
    return key;
  }

  final String? stored = await store.read();
  if (stored != null && _hexKey.hasMatch(stored) && _opensWith(path, stored)) {
    return stored;
  }
  _setAside(path);
  // Any stored value failed to open the file, so it is not worth keeping.
  await store.write('');
  return loadOrCreateKey(store);
}

void _encryptInPlace(String path, String hexKey) {
  final File pending = File('$path.encrypting');
  if (pending.existsSync()) {
    pending.deleteSync();
  }
  final Database db = sqlite3.open(path);
  try {
    // sqlcipher_export copies tables and rows but not user_version, which
    // drift reads as the schema version. Carry it over by hand.
    final Object? version = db
        .select('PRAGMA user_version')
        .single
        .values
        .single;
    final String target = pending.path.replaceAll("'", "''");
    db.execute("ATTACH DATABASE '$target' AS encrypted KEY \"x'$hexKey'\"");
    db.select("SELECT sqlcipher_export('encrypted')");
    db.execute('PRAGMA encrypted.user_version = ${version as int}');
    db.execute('DETACH DATABASE encrypted');
  } finally {
    db.close();
  }
  _deleteWithSidecars(path);
  pending.renameSync(path);
}

bool _opensWith(String path, String hexKey) {
  final Database db = sqlite3.open(path);
  try {
    applyKey(db, hexKey);
    return true;
  } on SqliteException {
    return false;
  } finally {
    db.close();
  }
}

void _setAside(String path) {
  int n = 1;
  while (File('$path.unreadable-$n').existsSync()) {
    n++;
  }
  File(path).renameSync('$path.unreadable-$n');
  for (final String suffix in <String>['-wal', '-shm', '-journal']) {
    final File sidecar = File('$path$suffix');
    if (sidecar.existsSync()) {
      sidecar.renameSync('$path.unreadable-$n$suffix');
    }
  }
}

void _deleteWithSidecars(String path) {
  for (final String suffix in <String>['', '-wal', '-shm', '-journal']) {
    final File f = File('$path$suffix');
    if (f.existsSync()) {
      f.deleteSync();
    }
  }
}
