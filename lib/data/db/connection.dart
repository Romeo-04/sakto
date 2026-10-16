import 'package:baon/data/db/database_key.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;

/// The single seam where the database file is opened.
///
/// ENCRYPTION, BUILD_PLAN.md Section 12. The file is encrypted with SQLCipher
/// (bundled through `hooks: user_defines: sqlite3` in `pubspec.yaml`). The
/// key comes from the platform keystore. [prepareDatabaseFile] encrypts an
/// older unencrypted file once, and [applyKey] refuses to open the file if
/// SQLCipher is missing. Do not open a second connection anywhere else, or
/// the key will be skipped on that path.
QueryExecutor openBaonDatabase({String name = 'baon'}) {
  return DatabaseConnection.delayed(
    Future<DatabaseConnection>(() async {
      // The same location drift_flutter uses by default, so a file created
      // before encryption is found and encrypted rather than abandoned.
      final String path = p.join(
        (await getApplicationDocumentsDirectory()).path,
        '$name.sqlite',
      );
      final String key = await prepareDatabaseFile(
        path,
        SecureDatabaseKeyStore(name),
      );
      return driftDatabase(
        name: name,
        native: DriftNativeOptions(
          databasePath: () async => path,
          setup: (CommonDatabase db) => applyKey(db, key),
        ),
      );
    }),
  );
}

/// An in-memory database for tests. Never touches the disk.
QueryExecutor openMemoryDatabase() => DatabaseConnection(
  NativeDatabase.memory(),
  closeStreamsSynchronously: true,
);

/// The key in the platform keystore: the Android Keystore on Android, the
/// Data Protection API on Windows.
class SecureDatabaseKeyStore implements DatabaseKeyStore {
  SecureDatabaseKeyStore(String databaseName)
    : _entry = 'baon_db_key_$databaseName';

  final String _entry;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _entry);

  @override
  Future<void> write(String key) => _storage.write(key: _entry, value: key);
}
