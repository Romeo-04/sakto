@TestOn('vm')
library;

import 'dart:io';

import 'package:baon/data/db/database_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// BUILD_PLAN.md Section 12: the database file is encrypted with SQLCipher
/// and the key lives in the platform keystore.
class MemoryKeyStore implements DatabaseKeyStore {
  String? value;

  /// Results to hand out before [value], one per read: a String, null, or
  /// an Exception to throw. Simulates a keystore that is slow to come up.
  final List<Object?> script = <Object?>[];
  int reads = 0;
  int writes = 0;

  @override
  Future<String?> read() async {
    reads++;
    if (script.isNotEmpty) {
      final Object? next = script.removeAt(0);
      if (next is Exception) {
        throw next;
      }
      return next as String?;
    }
    return value;
  }

  @override
  Future<void> write(String key) async {
    writes++;
    value = key;
  }
}

Future<String> prepare(String path, DatabaseKeyStore store) =>
    prepareDatabaseFile(path, store, retryDelay: Duration.zero);

void main() {
  late Directory dir;
  late String path;
  late MemoryKeyStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('baon_key_test');
    path = p.join(dir.path, 'baon.sqlite');
    store = MemoryKeyStore();
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  void writePlaintextDatabase() {
    final Database db = sqlite3.open(path);
    db.execute('CREATE TABLE notes (body TEXT)');
    db.execute("INSERT INTO notes VALUES ('kept')");
    db.execute('PRAGMA user_version = 2');
    db.close();
  }

  Database openWithKey(String hexKey) {
    final Database db = sqlite3.open(path);
    db.execute(keyPragma(hexKey));
    return db;
  }

  test('SQLCipher is the linked SQLite build', () {
    final Database db = sqlite3.openInMemory();
    addTearDown(db.close);
    expect(db.select('PRAGMA cipher_version'), isNotEmpty);
  });

  test('a new key is 32 random bytes as hex, and is stored once', () async {
    final String first = await loadOrCreateKey(store);
    expect(first, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(await loadOrCreateKey(store), first);
    expect(store.value, first);
  });

  test('two new keys are different', () async {
    final String a = await loadOrCreateKey(MemoryKeyStore());
    final String b = await loadOrCreateKey(MemoryKeyStore());
    expect(a, isNot(b));
  });

  test('a fresh install creates a key and no file', () async {
    final String key = await prepare(path, store);
    expect(key, store.value);
    expect(File(path).existsSync(), isFalse);
  });

  test('an unencrypted database is encrypted in place, data kept', () async {
    writePlaintextDatabase();
    expect(isPlaintextSqlite(File(path)), isTrue);

    final String key = await prepare(path, store);

    expect(isPlaintextSqlite(File(path)), isFalse);
    final Database db = openWithKey(key);
    addTearDown(db.close);
    expect(db.select('SELECT body FROM notes').single['body'], 'kept');
    expect(db.select('PRAGMA user_version').single.values.single, 2);
  });

  test('the encrypted file cannot be read without the key', () async {
    writePlaintextDatabase();
    await prepare(path, store);

    final Database db = sqlite3.open(path);
    addTearDown(db.close);
    expect(
      () => db.select('SELECT body FROM notes'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('an encrypted file with its key is left as it is', () async {
    writePlaintextDatabase();
    final String key = await prepare(path, store);
    final List<int> before = File(path).readAsBytesSync();

    expect(await prepare(path, store), key);
    expect(File(path).readAsBytesSync(), before);
  });

  test(
    'an encrypted file whose key was lost is set aside, not opened',
    () async {
      writePlaintextDatabase();
      await prepare(path, store);
      final MemoryKeyStore wiped = MemoryKeyStore();

      final String newKey = await prepare(path, wiped);

      expect(newKey, wiped.value);
      expect(File(path).existsSync(), isFalse);
      final List<String> kept = dir
          .listSync()
          .map((FileSystemEntity e) => p.basename(e.path))
          .where((String n) => n.startsWith('baon.sqlite.unreadable'))
          .toList();
      expect(kept, hasLength(1));
    },
  );

  test('a key that is slow to read is waited for, not replaced', () async {
    writePlaintextDatabase();
    final String key = await prepare(path, store);
    final List<int> before = File(path).readAsBytesSync();
    store.script.addAll(<Object?>[null, null]);
    final int writesBefore = store.writes;

    expect(await prepare(path, store), key);
    expect(store.writes, writesBefore);
    expect(File(path).readAsBytesSync(), before);
  });

  test('a keystore error stops the open and changes nothing', () async {
    writePlaintextDatabase();
    final String key = await prepare(path, store);
    final List<int> before = File(path).readAsBytesSync();
    store.script.addAll(<Object?>[
      Exception('keystore'),
      Exception('keystore'),
      Exception('keystore'),
    ]);

    await expectLater(prepare(path, store), throwsException);
    expect(store.value, key);
    expect(File(path).readAsBytesSync(), before);
  });

  test('an encryption cut off before the swap is finished', () async {
    writePlaintextDatabase();
    final String key = await prepare(path, store);
    // The state after the old file was deleted but before the rename.
    File(path).renameSync('$path.encrypting');

    expect(await prepare(path, store), key);
    expect(File('$path.encrypting').existsSync(), isFalse);
    final Database db = openWithKey(key);
    addTearDown(db.close);
    expect(db.select('SELECT body FROM notes').single['body'], 'kept');
  });

  test('a half-written encryption is redone from the old file', () async {
    writePlaintextDatabase();
    File('$path.encrypting').writeAsStringSync('partial');

    final String key = await prepare(path, store);

    expect(File('$path.encrypting').existsSync(), isFalse);
    final Database db = openWithKey(key);
    addTearDown(db.close);
    expect(db.select('SELECT body FROM notes').single['body'], 'kept');
  });

  test('an empty file is treated as a fresh install', () async {
    File(path).writeAsBytesSync(<int>[]);

    final String key = await prepare(path, store);

    expect(key, store.value);
    expect(File(path).existsSync(), isFalse);
  });

  test('no unencrypted side file is left after encryption', () async {
    writePlaintextDatabase();
    File('$path-wal').writeAsBytesSync(<int>[]);

    await prepare(path, store);

    for (final String suffix in <String>['-wal', '-shm', '-journal']) {
      expect(File('$path$suffix').existsSync(), isFalse, reason: suffix);
    }
  });
}
