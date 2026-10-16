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

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async => value = key;
}

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
    final String key = await prepareDatabaseFile(path, store);
    expect(key, store.value);
    expect(File(path).existsSync(), isFalse);
  });

  test('an unencrypted database is encrypted in place, data kept', () async {
    writePlaintextDatabase();
    expect(isPlaintextSqlite(File(path)), isTrue);

    final String key = await prepareDatabaseFile(path, store);

    expect(isPlaintextSqlite(File(path)), isFalse);
    final Database db = openWithKey(key);
    addTearDown(db.close);
    expect(db.select('SELECT body FROM notes').single['body'], 'kept');
    expect(db.select('PRAGMA user_version').single.values.single, 2);
  });

  test('the encrypted file cannot be read without the key', () async {
    writePlaintextDatabase();
    await prepareDatabaseFile(path, store);

    final Database db = sqlite3.open(path);
    addTearDown(db.close);
    expect(
      () => db.select('SELECT body FROM notes'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('an encrypted file with its key is left as it is', () async {
    writePlaintextDatabase();
    final String key = await prepareDatabaseFile(path, store);
    final List<int> before = File(path).readAsBytesSync();

    expect(await prepareDatabaseFile(path, store), key);
    expect(File(path).readAsBytesSync(), before);
  });

  test(
    'an encrypted file whose key was lost is set aside, not opened',
    () async {
      writePlaintextDatabase();
      await prepareDatabaseFile(path, store);
      final MemoryKeyStore wiped = MemoryKeyStore();

      final String newKey = await prepareDatabaseFile(path, wiped);

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
}
