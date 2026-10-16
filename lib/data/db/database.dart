import 'dart:convert';

import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/connection.dart';
import 'package:baon/data/db/seed.dart';
import 'package:baon/data/db/tables.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'database.g.dart';

/// The local SQLite database. BUILD_PLAN.md Section 3: this is the source of
/// truth. The app is fully usable with no account and no signal.
@DriftDatabase(
  tables: <Type>[
    Providers,
    Accounts,
    BalanceSnapshots,
    Categories,
    Txns,
    Obligations,
    IncomeExpectations,
    Envelopes,
    EnvelopeCategories,
    Allocations,
    BorrowEvents,
    Settings,
  ],
)
class BaonDatabase extends _$BaonDatabase {
  BaonDatabase([QueryExecutor? executor])
    : super(executor ?? openBaonDatabase());

  /// Builds a throwaway in-memory database for tests.
  BaonDatabase.memory() : super(openMemoryDatabase());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedCategories();
      await _createIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await rewriteLegacyEnumNames();
      }
    },
    beforeOpen: (OpeningDetails details) async {
      // Foreign keys are off by default in SQLite. Without this the cascade
      // deletes above never fire and orphan rows build up silently.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Schema 2. Schema 1 stored enums by their Dart name, so rows from it say
  /// `digitalBank` or `moneyOut` where Section 7 says `digital_bank` or `out`.
  /// Only these four values differ between the two names; every other enum
  /// value is the same string either way.
  Future<void> rewriteLegacyEnumNames() async {
    await transaction(() async {
      for (final ProviderKind kind in <ProviderKind>[
        ProviderKind.digitalBank,
        ProviderKind.traditionalBank,
      ]) {
        await customStatement(
          'UPDATE providers SET kind = ? WHERE kind = ?',
          <Object>[kind.wireName, kind.name],
        );
      }
      for (final TxnDirection direction in TxnDirection.values) {
        await customStatement(
          'UPDATE txns SET direction = ? WHERE direction = ?',
          <Object>[direction.wireName, direction.name],
        );
      }
    });
  }

  Future<void> _seedCategories() async {
    await batch(
      (Batch b) => b.insertAll(
        categories,
        seedCategories.map(
          (SeedCategory c) => CategoriesCompanion.insert(
            key: c.key,
            displayName: c.displayName,
            isEssential: c.isEssential,
            icon: c.icon,
            sortOrder: c.sortOrder,
          ),
        ),
      ),
    );
  }

  Future<void> _createIndexes() async {
    // The engine reads transactions by account over a date window on every
    // forecast. Without these it degrades to a full scan as history grows.
    await customStatement(
      'CREATE INDEX idx_txn_account_occurred ON txns (account_id, occurred_at)',
    );
    await customStatement(
      'CREATE INDEX idx_txn_occurred ON txns (occurred_at)',
    );
    await customStatement(
      'CREATE INDEX idx_snapshot_account_captured '
      'ON balance_snapshots (account_id, captured_at DESC)',
    );
    await customStatement(
      'CREATE INDEX idx_allocation_envelope ON allocations (envelope_id)',
    );
  }

  /// Loads `assets/providers.json` into the provider table.
  ///
  /// BUILD_PLAN.md Section 3: the registry is data, not code, so a new bank
  /// needs no release. Rows are upserted, so an updated asset corrects an
  /// existing install without losing the accounts that point at it.
  Future<void> seedProvidersFromAsset({
    String assetPath = 'assets/providers.json',
  }) async {
    final String raw = await rootBundle.loadString(assetPath);
    await seedProvidersFromJson(raw);
  }

  /// Loads the provider registry from a JSON string. Split out from
  /// [seedProvidersFromAsset] so tests need no asset bundle.
  Future<void> seedProvidersFromJson(String raw) async {
    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> entries = decoded['providers'] as List<dynamic>;
    await batch((Batch b) {
      for (final dynamic entry in entries) {
        final Map<String, dynamic> row = entry as Map<String, dynamic>;
        b.insert(
          providers,
          ProvidersCompanion.insert(
            key: row['key'] as String,
            displayName: row['display_name'] as String,
            kind: _providerKind(row['kind'] as String),
            brandColor: row['brand_color'] as String,
            logoAsset: row['logo_asset'] as String,
            notificationPackage: Value<String?>(
              row['notification_package'] as String?,
            ),
          ),
          onConflict: DoUpdate<$ProvidersTable, ProviderRow>(
            (_) => ProvidersCompanion.custom(
              displayName: Variable<String>(row['display_name'] as String),
              brandColor: Variable<String>(row['brand_color'] as String),
              logoAsset: Variable<String>(row['logo_asset'] as String),
            ),
          ),
        );
      }
    });
  }

  static ProviderKind _providerKind(String wire) => ProviderKind.fromWire(wire);
}
