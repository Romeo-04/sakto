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
import 'dart:isolate';
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

/// The files SQLite keeps next to the database. They hold database pages, so
/// they are deleted or moved together with it.
const List<String> _sidecars = <String>['-wal', '-shm', '-journal'];

/// How many times a keystore read is tried before its answer is believed.
const int _readAttempts = 3;

final RegExp _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// The statement that unlocks a connection. The key is 32 raw bytes in hex,
/// so SQLCipher uses it directly instead of deriving a key from a password.
String keyPragma(String hexKey) => "PRAGMA key = \"x'$hexKey'\"";

/// Unlocks [db] with [hexKey] and proves the file really is encrypted.
///
/// Throws instead of carrying on unencrypted: if the app was ever built
/// without SQLCipher, `PRAGMA key` would be ignored silently and balances
/// would be written in plain text. A wrong key also throws here (SQLite
/// error 26, "file is not a database"), on the first read.
void applyKey(CommonDatabase db, String hexKey) {
  if (db.select('PRAGMA cipher_version').isEmpty) {
    throw StateError(
      'SQLCipher is not linked into this build. Refusing to open the '
      'database unencrypted. Check `hooks: user_defines: sqlite3` in '
      'pubspec.yaml, then run `flutter clean`.',
    );
  }
  db.execute(keyPragma(hexKey));
  db.select('SELECT count(*) FROM sqlite_master');
}

/// Returns the stored key, or creates, stores and returns a new one.
Future<String> loadOrCreateKey(DatabaseKeyStore store) async {
  final String? existing = await store.read();
  if (existing != null && _hexKey.hasMatch(existing)) {
    return existing;
  }
  return _storeNewKey(store);
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
/// - No file: a fresh install. Returns the key, creating it if needed.
/// - An unencrypted file, from a build before encryption: encrypts it in
///   place, keeping every row and the schema version.
/// - An encrypted file and a stored key: returns the key and leaves the file
///   alone. If the key is wrong, [applyKey] reports it when drift opens the
///   file; nothing here moves or deletes data on a guess.
/// - An encrypted file and no stored key, after [_readAttempts] reads: the
///   key is gone (Android's keystore was reset, or the app data was copied
///   to a new phone without it), so the file can never be read again. It is
///   renamed to `<name>.unreadable-<n>`, not deleted, and the app starts
///   empty with a new key instead of failing on every launch.
///
/// A keystore that throws is retried, then the error is passed on. Nothing
/// is renamed and no key is written when the keystore cannot be read.
Future<String> prepareDatabaseFile(
  String path,
  DatabaseKeyStore store, {
  Duration retryDelay = const Duration(milliseconds: 250),
}) async {
  final File file = File(path);
  final File pending = File('$path.encrypting');

  // A previous encryption finished writing the new file and deleted the old
  // one, but stopped before the rename. The new file is complete.
  if (!file.existsSync() && pending.existsSync()) {
    pending.renameSync(path);
  }

  if (!file.existsSync()) {
    return loadOrCreateKey(store);
  }
  if (file.lengthSync() == 0) {
    _deleteWithSidecars(path);
    return loadOrCreateKey(store);
  }
  if (isPlaintextSqlite(file)) {
    final String key = await loadOrCreateKey(store);
    // One-time and proportional to the data, so keep it off the UI thread.
    await Isolate.run(() => encryptInPlace(path, key));
    return key;
  }

  final String? stored = await _readKey(store, retryDelay);
  if (stored != null) {
    return stored;
  }
  _setAside(path);
  return _storeNewKey(store);
}

/// Copies the unencrypted database at [path] into an encrypted one with
/// [hexKey], then swaps it into place.
///
/// The order makes every crash point recoverable: the new file is complete
/// before anything is deleted, the side files go before the main file, and
/// [prepareDatabaseFile] finishes a swap that stopped before the rename.
void encryptInPlace(String path, String hexKey) {
  final File pending = File('$path.encrypting');
  if (pending.existsSync()) {
    pending.deleteSync();
  }
  final Database db = sqlite3.open(path);
  try {
    // sqlcipher_export copies tables and rows but not user_version, which
    // drift reads as the schema version. Carry it over by hand.
    final int version =
        db.select('PRAGMA user_version').single.values.single! as int;
    final String target = pending.path.replaceAll("'", "''");
    db.execute("ATTACH DATABASE '$target' AS encrypted KEY \"x'$hexKey'\"");
    db.select("SELECT sqlcipher_export('encrypted')");
    db.execute('PRAGMA encrypted.user_version = $version');
    db.execute('DETACH DATABASE encrypted');
  } finally {
    db.close();
  }
  _deleteWithSidecars(path);
  pending.renameSync(path);
}

/// Reads the key, trying again when the keystore answers null or throws, so
/// a keystore that is slow to come up is not mistaken for a lost key.
Future<String?> _readKey(DatabaseKeyStore store, Duration retryDelay) async {
  for (int attempt = 1; ; attempt++) {
    try {
      final String? key = await store.read();
      if (key != null && _hexKey.hasMatch(key)) {
        return key;
      }
      if (attempt >= _readAttempts) {
        return null;
      }
    } on Exception {
      if (attempt >= _readAttempts) {
        rethrow;
      }
    }
    await Future<void>.delayed(retryDelay);
  }
}

Future<String> _storeNewKey(DatabaseKeyStore store) async {
  final Random random = Random.secure();
  final String key = List<String>.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  await store.write(key);
  return key;
}

void _setAside(String path) {
  int n = 1;
  while (File('$path.unreadable-$n').existsSync()) {
    n++;
  }
  for (final String suffix in _sidecars) {
    final File sidecar = File('$path$suffix');
    if (sidecar.existsSync()) {
      sidecar.renameSync('$path.unreadable-$n$suffix');
    }
  }
  File(path).renameSync('$path.unreadable-$n');
}

/// Side files first, main file last: a crash in between must never leave an
/// old side file next to a new database, where SQLite would replay it.
void _deleteWithSidecars(String path) {
  for (final String suffix in <String>[..._sidecars, '']) {
    final File f = File('$path$suffix');
    if (f.existsSync()) {
      f.deleteSync();
    }
  }
}
