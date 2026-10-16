@TestOn('vm')
library;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/db/seed.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const String _providersJson = '''
{
  "version": 1,
  "providers": [
    {"key":"gcash","display_name":"GCash","kind":"ewallet","brand_color":"#0057FF","logo_asset":"a.png","notification_package":"com.globe.gcash.android"},
    {"key":"maribank","display_name":"MariBank","kind":"digital_bank","brand_color":"#F2542D","logo_asset":"b.png","notification_package":null},
    {"key":"gotyme","display_name":"GoTyme Bank","kind":"digital_bank","brand_color":"#00B7C3","logo_asset":"c.png","notification_package":null},
    {"key":"cash","display_name":"Cash on hand","kind":"cash","brand_color":"#4B5563","logo_asset":"d.png","notification_package":null}
  ]
}
''';

void main() {
  late BaonDatabase db;
  late FixedClock clock;
  late AccountRepository accounts;
  late EnvelopeRepository envelopes;

  setUp(() async {
    clock = FixedClock(DateTime.utc(2026, 9, 4, 8));
    db = BaonDatabase.memory();
    await db.seedProvidersFromJson(_providersJson);
    accounts = AccountRepository(db, clock);
    envelopes = EnvelopeRepository(db, clock);
  });

  tearDown(() async {
    await db.close();
  });

  group('seeding', () {
    test('creates the category list from the plan', () async {
      final List<CategoryRow> rows = await db.select(db.categories).get();
      expect(rows.length, seedCategories.length);
      final Set<String> keys = rows.map((CategoryRow r) => r.key).toSet();
      expect(
        keys,
        containsAll(<String>[
          'transport',
          'food_daily',
          'dates_leisure',
          'savings_in',
          'other',
        ]),
      );
    });

    test('marks the essential categories', () async {
      final List<CategoryRow> rows = await db.select(db.categories).get();
      final Set<String> essential = rows
          .where((CategoryRow r) => r.isEssential)
          .map((CategoryRow r) => r.key)
          .toSet();
      expect(
        essential,
        containsAll(<String>[
          'transport',
          'food_daily',
          'school',
          'health',
          'load_data',
        ]),
      );
      expect(essential, isNot(contains('dates_leisure')));
    });

    test('loads the provider registry from JSON', () async {
      final List<ProviderRow> rows = await accounts.allProviders();
      expect(rows.length, 4);
      final ProviderRow gcash = rows.firstWhere(
        (ProviderRow p) => p.key == 'gcash',
      );
      expect(gcash.kind, ProviderKind.ewallet);
      expect(gcash.notificationPackage, 'com.globe.gcash.android');
      final ProviderRow cash = rows.firstWhere(
        (ProviderRow p) => p.key == 'cash',
      );
      expect(cash.kind, ProviderKind.cash);
      expect(cash.notificationPackage, isNull);
    });

    test('reseeding updates a row instead of duplicating it', () async {
      await db.seedProvidersFromJson(
        _providersJson.replaceAll('"GCash"', '"GCash 2"'),
      );
      final List<ProviderRow> rows = await accounts.allProviders();
      expect(rows.length, 4, reason: 'an upsert must not add a second row');
      expect(
        rows.firstWhere((ProviderRow p) => p.key == 'gcash').displayName,
        'GCash 2',
      );
    });
  });

  group('M1 acceptance: three accounts and three envelopes', () {
    Future<void> buildTheSetup() async {
      await accounts.create(providerKey: 'gcash', label: 'GCash main');
      await accounts.create(providerKey: 'maribank', label: 'MariBank');
      await accounts.create(
        providerKey: 'gotyme',
        label: 'GoTyme savings',
        role: AccountRole.savings,
      );
    }

    test('adds three accounts', () async {
      await buildTheSetup();
      final List<AccountRow> rows = await accounts.activeAccounts();
      expect(rows.length, 3);
      expect(rows.map((AccountRow a) => a.label), <String>[
        'GCash main',
        'MariBank',
        'GoTyme savings',
      ]);
    });

    test('adds three envelopes with the three shapes', () async {
      await envelopes.create(
        label: 'Food and transport',
        shape: EnvelopeShape.steady,
        refill: const Money(200000),
        refillCadence: Cadence.weekly,
        refillAnchor: 'monday',
        categoryKeys: <String>['transport', 'food_daily'],
      );
      await envelopes.create(
        label: 'Dates',
        shape: EnvelopeShape.episodic,
        refill: const Money(300000),
        refillCadence: Cadence.monthly,
        refillAnchor: '1',
        categoryKeys: <String>['dates_leisure'],
      );
      await envelopes.create(
        label: 'Savings',
        shape: EnvelopeShape.reserve,
        refill: Money.zero,
        refillCadence: Cadence.none,
        refillAnchor: '',
      );

      final List<EnvelopeWithState> rows = await envelopes.envelopesWithState();
      expect(rows.length, 3);
      expect(rows.map((EnvelopeWithState e) => e.shape), <EnvelopeShape>[
        EnvelopeShape.steady,
        EnvelopeShape.episodic,
        EnvelopeShape.reserve,
      ]);
      expect(
        rows.first.categoryKeys,
        containsAll(<String>['transport', 'food_daily']),
      );
    });

    test(
      'the unallocated invariant holds when envelopes match accounts',
      () async {
        await buildTheSetup();
        final List<AccountRow> rows = await accounts.activeAccounts();
        await _snapshot(db, clock, rows[0].id, const Money(300000));
        await _snapshot(db, clock, rows[1].id, const Money(200000));
        await _snapshot(db, clock, rows[2].id, const Money(472000));

        await envelopes.create(
          label: 'Food and transport',
          shape: EnvelopeShape.steady,
          refill: const Money(200000),
          refillCadence: Cadence.weekly,
          refillAnchor: 'monday',
          openingBalance: const Money(200000),
        );
        await envelopes.create(
          label: 'Dates',
          shape: EnvelopeShape.episodic,
          refill: const Money(300000),
          refillCadence: Cadence.monthly,
          refillAnchor: '1',
          openingBalance: const Money(300000),
        );
        await envelopes.create(
          label: 'Savings',
          shape: EnvelopeShape.reserve,
          refill: Money.zero,
          refillCadence: Cadence.none,
          refillAnchor: '',
          openingBalance: const Money(472000),
        );

        final Money accountTotal = await accounts.accountTotal();
        expect(accountTotal, const Money(972000));

        final EnvelopeTotals totals = await envelopes.totals(accountTotal);
        expect(totals.envelopeTotal, const Money(972000));
        expect(totals.unallocated, Money.zero);
        expect(totals.invariantHolds, isTrue);
      },
    );

    test('leftover money shows as unallocated, not as an error', () async {
      await buildTheSetup();
      final List<AccountRow> rows = await accounts.activeAccounts();
      await _snapshot(db, clock, rows[0].id, const Money(500000));

      await envelopes.create(
        label: 'Food and transport',
        shape: EnvelopeShape.steady,
        refill: const Money(200000),
        refillCadence: Cadence.weekly,
        refillAnchor: 'monday',
        openingBalance: const Money(200000),
      );

      final EnvelopeTotals totals = await envelopes.totals(
        await accounts.accountTotal(),
      );
      expect(totals.unallocated, const Money(300000));
      expect(totals.invariantHolds, isTrue);
      expect(totals.overAllocated, Money.zero);
    });

    test('over-allocation breaks the invariant and is reported', () async {
      await buildTheSetup();
      final List<AccountRow> rows = await accounts.activeAccounts();
      await _snapshot(db, clock, rows[0].id, const Money(100000));

      await envelopes.create(
        label: 'Food and transport',
        shape: EnvelopeShape.steady,
        refill: const Money(200000),
        refillCadence: Cadence.weekly,
        refillAnchor: 'monday',
        openingBalance: const Money(250000),
      );

      final EnvelopeTotals totals = await envelopes.totals(
        await accounts.accountTotal(),
      );
      expect(totals.unallocated, const Money(-150000));
      expect(
        totals.invariantHolds,
        isFalse,
        reason: 'the dashboard must show "Fix your envelopes"',
      );
      expect(totals.overAllocated, const Money(150000));
    });
  });

  group('account maintenance', () {
    test('excludes a non-spendable account from the total', () async {
      final String id = await accounts.create(
        providerKey: 'gcash',
        label: 'GCash main',
      );
      final String bond = await accounts.create(
        providerKey: 'gotyme',
        label: 'Locked fund',
        includeInSpendable: false,
      );
      await _snapshot(db, clock, id, const Money(100000));
      await _snapshot(db, clock, bond, const Money(900000));

      expect(await accounts.accountTotal(), const Money(100000));
    });

    test('archiving and soft deleting hide an account', () async {
      final String keep = await accounts.create(
        providerKey: 'gcash',
        label: 'Keep',
      );
      final String archived = await accounts.create(
        providerKey: 'maribank',
        label: 'Archive me',
      );
      final String deleted = await accounts.create(
        providerKey: 'gotyme',
        label: 'Delete me',
      );
      await accounts.archive(archived);
      await accounts.softDelete(deleted);

      final List<AccountRow> rows = await accounts.activeAccounts();
      expect(rows.map((AccountRow a) => a.id), <String>[keep]);
    });

    test('renaming bumps updatedAt so sync can order the change', () async {
      final String id = await accounts.create(
        providerKey: 'gcash',
        label: 'Old name',
      );
      clock.advance(const Duration(hours: 2));
      await accounts.rename(id, 'New name');

      final AccountRow row = (await accounts.activeAccounts()).single;
      expect(row.label, 'New name');
      expect(row.updatedAt, DateTime.utc(2026, 9, 4, 10));
    });

    test(
      'the latest snapshot wins and staleness is measured from it',
      () async {
        final String id = await accounts.create(
          providerKey: 'gcash',
          label: 'GCash',
        );
        await _snapshot(db, clock, id, const Money(100000));
        clock.advance(const Duration(days: 1));
        await _snapshot(db, clock, id, const Money(80000));

        final AccountWithBalance row =
            (await accounts.accountsWithBalances()).single;
        expect(row.balance, const Money(80000));
        expect(row.isStaleAt(clock.nowUtc()), isFalse);
        expect(
          row.isStaleAt(clock.nowUtc().add(const Duration(hours: 73))),
          isTrue,
          reason:
              'BUILD_PLAN.md Section 8.2 marks a snapshot stale after 72 hours',
        );
      },
    );

    test('an account with no snapshot counts as zero and as stale', () async {
      await accounts.create(providerKey: 'gcash', label: 'GCash');
      final AccountWithBalance row =
          (await accounts.accountsWithBalances()).single;
      expect(row.balance, Money.zero);
      expect(row.capturedAt, isNull);
      expect(row.isStaleAt(clock.nowUtc()), isTrue);
    });
  });

  group('envelope maintenance', () {
    late String food;
    late String dates;

    setUp(() async {
      food = await envelopes.create(
        label: 'Food and transport',
        shape: EnvelopeShape.steady,
        refill: const Money(200000),
        refillCadence: Cadence.weekly,
        refillAnchor: 'monday',
        openingBalance: const Money(92000),
        categoryKeys: <String>['transport', 'food_daily'],
      );
      dates = await envelopes.create(
        label: 'Dates',
        shape: EnvelopeShape.episodic,
        refill: const Money(300000),
        refillCadence: Cadence.monthly,
        refillAnchor: '1',
        openingBalance: const Money(120000),
        categoryKeys: <String>['dates_leisure'],
        allowBorrowFrom: <String>['env_food'],
      );
    });

    test('routes a category to its envelope', () async {
      expect(await envelopes.envelopeForCategory('food_daily'), food);
      expect(await envelopes.envelopeForCategory('dates_leisure'), dates);
      expect(await envelopes.envelopeForCategory('shopping'), isNull);
    });

    test('replacing categories drops the old routes', () async {
      await envelopes.setCategories(food, <String>['transport', 'groceries']);
      expect(
        await envelopes.categoryKeysFor(food),
        containsAll(<String>['transport', 'groceries']),
      );
      expect(await envelopes.envelopeForCategory('food_daily'), isNull);
    });

    test('adjusting a balance moves it by the delta', () async {
      await envelopes.adjustBalance(food, const Money(-15000));
      final EnvelopeWithState row = (await envelopes.envelopesWithState())
          .firstWhere((EnvelopeWithState e) => e.id == food);
      expect(row.balance, const Money(77000));
    });

    test('a borrow moves money and leaves a record', () async {
      await envelopes.recordBorrow(
        fromEnvelopeId: food,
        toEnvelopeId: dates,
        amount: const Money(40000),
      );

      final List<EnvelopeWithState> rows = await envelopes.envelopesWithState();
      expect(
        rows.firstWhere((EnvelopeWithState e) => e.id == food).balance,
        const Money(52000),
      );
      expect(
        rows.firstWhere((EnvelopeWithState e) => e.id == dates).balance,
        const Money(160000),
      );

      final List<BorrowEventRow> events = await db
          .select(db.borrowEvents)
          .get();
      expect(events.single.amountCents, const Money(40000));
      expect(events.single.repaidAt, isNull);
    });

    test('the borrow list round-trips through the JSON column', () async {
      final EnvelopeRow row = (await envelopes.activeEnvelopes()).firstWhere(
        (EnvelopeRow e) => e.id == dates,
      );
      expect(row.allowBorrowFrom, <String>['env_food']);
    });

    test('an envelope with no borrow target reads as an empty list', () async {
      final EnvelopeRow row = (await envelopes.activeEnvelopes()).firstWhere(
        (EnvelopeRow e) => e.id == food,
      );
      expect(row.allowBorrowFrom, isEmpty);
    });

    test('soft deleting hides an envelope', () async {
      await envelopes.softDelete(dates);
      final List<EnvelopeRow> rows = await envelopes.activeEnvelopes();
      expect(rows.map((EnvelopeRow e) => e.id), <String>[food]);
    });
  });

  group('money round-trips through SQLite', () {
    test('a balance survives as exact centavos', () async {
      final String id = await accounts.create(
        providerKey: 'gcash',
        label: 'GCash',
      );
      await _snapshot(db, clock, id, const Money(123456789));
      final AccountWithBalance row =
          (await accounts.accountsWithBalances()).single;
      expect(row.balance.centavos, 123456789);
    });

    test('a negative balance is stored, not clamped', () async {
      final String id = await accounts.create(
        providerKey: 'gcash',
        label: 'GCash',
      );
      await _snapshot(db, clock, id, const Money(-2500));
      final AccountWithBalance row =
          (await accounts.accountsWithBalances()).single;
      expect(row.balance, const Money(-2500));
    });

    test('a timestamp round-trips as UTC', () async {
      final String id = await accounts.create(
        providerKey: 'gcash',
        label: 'GCash',
      );
      final AccountRow row = (await accounts.activeAccounts()).single;
      expect(row.createdAt.toUtc(), DateTime.utc(2026, 9, 4, 8));
      expect(id, startsWith('acc_'));
    });
  });
}

Future<void> _snapshot(
  BaonDatabase db,
  Clock clock,
  String accountId,
  Money balance,
) async {
  await db
      .into(db.balanceSnapshots)
      .insert(
        BalanceSnapshotsCompanion.insert(
          id: 'snap_${accountId}_${clock.nowUtc().microsecondsSinceEpoch}',
          accountId: accountId,
          balanceCents: balance,
          source: SnapshotSource.manual,
          capturedAt: clock.nowUtc(),
        ),
      );
}
