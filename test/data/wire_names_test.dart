@TestOn('vm')
library;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/data/repositories/txn_repository.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

/// BUILD_PLAN.md Section 7 and `lib/core/enums.dart`: SQLite stores each
/// enum's `wireName`, never the Dart `Enum.name`. The Supabase schema checks
/// the same strings (`direction in ('in', 'out')`), so a Dart name in a row
/// would fail the first sync.
const String _providersJson = '''
{
  "version": 1,
  "providers": [
    {"key":"gcash","display_name":"GCash","kind":"ewallet","brand_color":"#0057FF","logo_asset":"a.png","notification_package":null},
    {"key":"maribank","display_name":"MariBank","kind":"digital_bank","brand_color":"#F2542D","logo_asset":"b.png","notification_package":null},
    {"key":"bdo","display_name":"BDO","kind":"traditional_bank","brand_color":"#003DA5","logo_asset":"c.png","notification_package":null}
  ]
}
''';

void main() {
  late BaonDatabase db;
  late FixedClock clock;
  late AccountRepository accounts;
  late TxnRepository txns;

  setUp(() async {
    clock = FixedClock(DateTime.utc(2026, 9, 4, 8));
    db = BaonDatabase.memory();
    await db.seedProvidersFromJson(_providersJson);
    accounts = AccountRepository(db, clock);
    txns = TxnRepository(db, clock, EnvelopeRepository(db, clock));
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> rawText(
    String sql, [
    List<Object> args = const <Object>[],
  ]) async {
    final row = await db
        .customSelect(
          sql,
          variables: args.map((Object a) => Variable<Object>(a)).toList(),
        )
        .getSingle();
    return row.data.values.single as String;
  }

  test('a provider kind is stored as its wire name', () async {
    expect(
      await rawText("SELECT kind FROM providers WHERE key = 'maribank'"),
      ProviderKind.digitalBank.wireName,
    );
    expect(
      await rawText("SELECT kind FROM providers WHERE key = 'bdo'"),
      ProviderKind.traditionalBank.wireName,
    );
  });

  test('a transaction direction is stored as its wire name', () async {
    final String accountId = await accounts.create(
      providerKey: 'gcash',
      label: 'GCash main',
    );
    final String spend = await txns.record(
      accountId: accountId,
      amount: const Money.pesos(50),
      direction: TxnDirection.moneyOut,
      categoryKey: 'food_daily',
      occurredAt: clock.nowUtc(),
    );
    final String income = await txns.record(
      accountId: accountId,
      amount: const Money.pesos(500),
      direction: TxnDirection.moneyIn,
      categoryKey: 'income',
      occurredAt: clock.nowUtc(),
    );

    expect(
      await rawText('SELECT direction FROM txns WHERE id = ?', <Object>[spend]),
      'out',
    );
    expect(
      await rawText('SELECT direction FROM txns WHERE id = ?', <Object>[
        income,
      ]),
      'in',
    );
  });

  test('a stored wire name reads back as the right enum value', () async {
    final ProviderRow row = await (db.select(
      db.providers,
    )..where(($ProvidersTable t) => t.key.equals('maribank'))).getSingle();
    expect(row.kind, ProviderKind.digitalBank);
  });

  test(
    'rows written with Dart enum names are rewritten to wire names',
    () async {
      final String accountId = await accounts.create(
        providerKey: 'gcash',
        label: 'GCash main',
      );
      final String spend = await txns.record(
        accountId: accountId,
        amount: const Money.pesos(50),
        direction: TxnDirection.moneyOut,
        categoryKey: 'food_daily',
        occurredAt: clock.nowUtc(),
      );
      // What a schema-1 database on a development machine holds.
      await db.customStatement(
        "UPDATE providers SET kind = 'digitalBank' WHERE key = 'maribank'",
      );
      await db.customStatement(
        "UPDATE providers SET kind = 'traditionalBank' WHERE key = 'bdo'",
      );
      await db.customStatement(
        "UPDATE txns SET direction = 'moneyOut' WHERE id = ?",
        <Object>[spend],
      );

      await db.rewriteLegacyEnumNames();

      expect(
        await rawText("SELECT kind FROM providers WHERE key = 'maribank'"),
        'digital_bank',
      );
      expect(
        await rawText("SELECT kind FROM providers WHERE key = 'bdo'"),
        'traditional_bank',
      );
      expect(
        await rawText('SELECT direction FROM txns WHERE id = ?', <Object>[
          spend,
        ]),
        'out',
      );
    },
  );
}
