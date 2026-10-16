import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// The single seam where the database file is opened.
///
/// ENCRYPTION, BUILD_PLAN.md Section 12. The file is not yet encrypted. This
/// is the one place that changes when SQLCipher is added: swap the executor
/// for a `sqlcipher_flutter_libs` build and run
/// `PRAGMA key = <key from flutter_secure_storage>` before the first read.
/// Nothing outside this file needs to know. Do not open a second connection
/// anywhere else, or the cipher will be skipped on that path.
///
/// SQLCipher is deferred because this machine has no Android SDK, so an
/// encrypted build cannot be verified on a device yet. Ship encryption before
/// any release that stores real balances.
QueryExecutor openBaonDatabase({String name = 'baon'}) =>
    driftDatabase(name: name);

/// An in-memory database for tests. Never touches the disk.
QueryExecutor openMemoryDatabase() => DatabaseConnection(
  NativeDatabase.memory(),
  closeStreamsSynchronously: true,
);
