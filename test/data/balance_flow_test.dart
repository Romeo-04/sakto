@TestOn('vm')
library;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/balance_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/data/repositories/txn_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const String _providersJson = '''
{"version":1,"providers":[
 {"key":"gcash","display_name":"GCash","kind":"ewallet","brand_color":"#0057FF","logo_asset":"a.png","notification_package":null},
 {"key":"cash","display_name":"Cash","kind":"cash","brand_color":"#4B5563","logo_asset":"b.png","notification_package":null}
]}
''';

void main() {
  late BaonDatabase db;
  late FixedClock clock;
  late AccountRepository accounts;
  late EnvelopeRepository envelopes;
  late TxnRepository txns;
  late BalanceRepository balances;

  late String gcash;
  late String foodEnvelope;
  late String datesEnvelope;

  setUp(() async {
    clock = FixedClock(DateTime.utc(2026, 9, 1, 8));
    db = BaonDatabase.memory();
    await db.seedProvidersFromJson(_providersJson);
    accounts = AccountRepository(db, clock);
    envelopes = EnvelopeRepository(db, clock);
    txns = TxnRepository(db, clock, envelopes);
    balances = BalanceRepository(db, clock, accounts, txns);

    gcash = await accounts.create(providerKey: 'gcash', label: 'GCash main');
    foodEnvelope = await envelopes.create(
      label: 'Food and transport',
      shape: EnvelopeShape.steady,
      refill: const Money(200000),
      refillCadence: Cadence.weekly,
      refillAnchor: 'monday',
      openingBalance: const Money(200000),
      categoryKeys: <String>['transport', 'food_daily'],
    );
    datesEnvelope = await envelopes.create(
      label: 'Dates',
      shape: EnvelopeShape.episodic,
      refill: const Money(300000),
      refillCadence: Cadence.monthly,
      refillAnchor: '1',
      openingBalance: const Money(120000),
      categoryKeys: <String>['dates_leisure'],
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<Money> envelopeBalance(String id) async {
    final List<EnvelopeWithState> rows = await envelopes.envelopesWithState();
    return rows.firstWhere((EnvelopeWithState e) => e.id == id).balance;
  }

  group('M2 acceptance', () {
    test('the first balance creates no Unaccounted row', () async {
      final SavedBalance saved = await balances.saveBalance(
        accountId: gcash,
        balance: const Money(320000),
      );
      expect(saved.createdUnaccounted, isFalse);
      expect(await txns.unaccounted(), isEmpty);
    });

    test('a drop creates a correct Unaccounted row in one envelope', () async {
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(320000),
      );
      clock.advance(const Duration(days: 2));

      final SavedBalance saved = await balances.saveBalance(
        accountId: gcash,
        balance: const Money(285000),
      );

      expect(saved.createdUnaccounted, isTrue);
      expect(saved.result.delta, const Money(-35000));

      final List<TxnRow> pending = await txns.unaccounted();
      expect(pending.length, 1);
      expect(pending.single.amountCents, const Money(35000));
      expect(pending.single.direction, TxnDirection.moneyOut);
      expect(pending.single.source, TxnSource.reconciled);
      expect(pending.single.categoryKey, 'other');
      expect(
        pending.single.occurredAt,
        DateTime.utc(2026, 9, 2, 8),
        reason: 'placed at the midpoint of the gap',
      );

      expect(
        saved.envelopeId,
        foodEnvelope,
        reason: 'an unrouted spend falls to the everyday steady envelope',
      );
      expect(await envelopeBalance(foodEnvelope), const Money(165000));
      expect(
        await envelopeBalance(datesEnvelope),
        const Money(120000),
        reason: 'only one envelope may move',
      );
    });

    test('logged spending is deducted before the gap is booked', () async {
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(320000),
      );
      clock.advance(const Duration(days: 1));
      await txns.record(
        accountId: gcash,
        amount: const Money(20000),
        direction: TxnDirection.moneyOut,
        categoryKey: 'food_daily',
        occurredAt: clock.nowUtc(),
      );
      clock.advance(const Duration(days: 1));

      final SavedBalance saved = await balances.saveBalance(
        accountId: gcash,
        balance: const Money(285000),
      );

      expect(saved.result.expected, const Money(300000));
      expect(saved.result.delta, const Money(-15000));
      expect((await txns.unaccounted()).single.amountCents, const Money(15000));
      expect(
        await envelopeBalance(foodEnvelope),
        const Money(165000),
        reason: 'PHP 200 logged plus PHP 150 unaccounted, both from food',
      );
    });

    test('a rise books an inflow', () async {
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(100000),
      );
      clock.advance(const Duration(days: 1));
      final SavedBalance saved = await balances.saveBalance(
        accountId: gcash,
        balance: const Money(350000),
      );
      expect(saved.result.delta, const Money(250000));
      expect((await txns.unaccounted()).single.direction, TxnDirection.moneyIn);
      expect(await envelopeBalance(foodEnvelope), const Money(450000));
    });

    test('a change inside the tolerance books nothing', () async {
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(320000),
      );
      clock.advance(const Duration(days: 1));
      final SavedBalance saved = await balances.saveBalance(
        accountId: gcash,
        balance: const Money(319950),
      );
      expect(saved.createdUnaccounted, isFalse);
      expect(await envelopeBalance(foodEnvelope), const Money(200000));
    });
  });

  group('routing a transaction to an envelope', () {
    test('a category routes to its own envelope', () async {
      await txns.record(
        accountId: gcash,
        amount: const Money(90000),
        direction: TxnDirection.moneyOut,
        categoryKey: 'dates_leisure',
        occurredAt: clock.nowUtc(),
      );
      expect(await envelopeBalance(datesEnvelope), const Money(30000));
      expect(await envelopeBalance(foodEnvelope), const Money(200000));
    });

    test('a transfer never moves an envelope', () async {
      await txns.record(
        accountId: gcash,
        amount: const Money(50000),
        direction: TxnDirection.moneyOut,
        categoryKey: 'transfer_internal',
        occurredAt: clock.nowUtc(),
      );
      await txns.record(
        accountId: gcash,
        amount: const Money(50000),
        direction: TxnDirection.moneyOut,
        categoryKey: 'savings_in',
        occurredAt: clock.nowUtc(),
      );
      expect(
        await envelopeBalance(foodEnvelope),
        const Money(200000),
        reason: 'BUILD_PLAN.md Section 8.4: a transfer is not a spend',
      );
    });
  });

  group('labelling an Unaccounted item', () {
    Future<TxnRow> makeUnaccounted() async {
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(320000),
      );
      clock.advance(const Duration(days: 2));
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(230000),
      );
      return (await txns.unaccounted()).single;
    }

    test('relabelling moves the money to the right envelope', () async {
      final TxnRow row = await makeUnaccounted();
      expect(await envelopeBalance(foodEnvelope), const Money(110000));

      await txns.relabel(txnId: row.id, categoryKey: 'dates_leisure');

      expect(
        await envelopeBalance(foodEnvelope),
        const Money(200000),
        reason: 'the wrong envelope must be put back exactly',
      );
      expect(await envelopeBalance(datesEnvelope), const Money(30000));
    });

    test(
      'a relabelled row leaves the Unaccounted list and is a training row',
      () async {
        final TxnRow row = await makeUnaccounted();
        await txns.relabel(txnId: row.id, categoryKey: 'dates_leisure');

        expect(await txns.unaccounted(), isEmpty);
        final TxnRow updated = (await txns.between(
          DateTime.utc(2026, 8),
          DateTime.utc(2026, 10),
        )).firstWhere((TxnRow t) => t.id == row.id);
        expect(updated.userCorrected, isTrue);
        expect(updated.categoryConfidence, 1.0);
      },
    );

    test('confirming the same category still records a correction', () async {
      final TxnRow row = await makeUnaccounted();
      await txns.relabel(txnId: row.id, categoryKey: 'other');
      expect(await txns.unaccounted(), isEmpty);
      expect(await envelopeBalance(foodEnvelope), const Money(110000));
    });

    test('splitting keeps the total and clears the item', () async {
      final TxnRow row = await makeUnaccounted();
      final List<String> ids = await txns.split(
        txnId: row.id,
        parts: <({Money amount, String categoryKey})>[
          (amount: const Money(60000), categoryKey: 'dates_leisure'),
          (amount: const Money(30000), categoryKey: 'food_daily'),
        ],
      );

      expect(ids.length, 2);
      expect(await txns.unaccounted(), isEmpty);
      expect(await envelopeBalance(datesEnvelope), const Money(60000));
      expect(await envelopeBalance(foodEnvelope), const Money(170000));
    });

    test('a split that does not add up is refused', () async {
      final TxnRow row = await makeUnaccounted();
      await expectLater(
        txns.split(
          txnId: row.id,
          parts: <({Money amount, String categoryKey})>[
            (amount: const Money(10000), categoryKey: 'food_daily'),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('deleting a transaction returns the money to its envelope', () async {
      final String id = await txns.record(
        accountId: gcash,
        amount: const Money(90000),
        direction: TxnDirection.moneyOut,
        categoryKey: 'dates_leisure',
        occurredAt: clock.nowUtc(),
      );
      expect(await envelopeBalance(datesEnvelope), const Money(30000));
      await txns.softDelete(id);
      expect(await envelopeBalance(datesEnvelope), const Money(120000));
    });
  });

  group('staleness and history', () {
    test('an account goes stale after 72 hours', () async {
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(320000),
      );
      expect(await balances.staleAccounts(), isEmpty);

      clock.advance(const Duration(hours: 73));
      final List<AccountWithBalance> stale = await balances.staleAccounts();
      expect(stale.single.account.id, gcash);
    });

    test(
      'history is kept oldest first and the earliest date is found',
      () async {
        await balances.saveBalance(
          accountId: gcash,
          balance: const Money(320000),
        );
        clock.advance(const Duration(days: 3));
        await balances.saveBalance(
          accountId: gcash,
          balance: const Money(300000),
        );

        final List<BalanceSnapshotRow> rows = await balances.history(gcash);
        expect(rows.length, 2);
        expect(rows.first.balanceCents, const Money(320000));
        expect(
          await balances.earliestSnapshotAt(),
          DateTime.utc(2026, 9, 1, 8),
        );
      },
    );

    test('saveMany records every account at one moment', () async {
      final String cash = await accounts.create(
        providerKey: 'cash',
        label: 'Wallet',
      );
      final List<SavedBalance> saved = await balances.saveMany(<String, Money>{
        gcash: const Money(320000),
        cash: const Money(50000),
      });
      expect(saved.length, 2);
      expect(await accounts.accountTotal(), const Money(370000));
    });
  });
}
