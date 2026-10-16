@TestOn('vm')
library;

import 'package:baon/app_providers.dart';
import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/balance_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/data/repositories/txn_repository.dart';
import 'package:baon/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const String _providersJson = '''
{"version":1,"providers":[
 {"key":"gcash","display_name":"GCash","kind":"ewallet","brand_color":"#0057FF","logo_asset":"a.png","notification_package":null},
 {"key":"cash","display_name":"Cash","kind":"cash","brand_color":"#4B5563","logo_asset":"b.png","notification_package":null}
]}
''';

/// A smoke test asserting the whole app boots and its screens render without
/// throwing. This is not a substitute for the engine's unit tests; it exists
/// to catch a wiring mistake between providers and widgets that a pure-Dart
/// test cannot see.
///
/// Uses bounded [WidgetTester.pump] calls rather than `pumpAndSettle`.
/// `IndexedStack` in [HomeShell] keeps every tab mounted at once, and each
/// tab shows an indeterminate `CircularProgressIndicator` while its provider
/// loads. An indeterminate spinner never stops scheduling frames, so
/// `pumpAndSettle` would wait for a state that never arrives even once every
/// provider has already resolved.
Future<void> _settle(
  WidgetTester tester, {
  int steps = 30,
  Duration step = const Duration(milliseconds: 200),
}) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(step);
  }
}

void main() {
  testWidgets('a fresh install shows onboarding, step 1 of 4', (
    WidgetTester tester,
  ) async {
    final BaonDatabase db = BaonDatabase.memory();
    await db.seedProvidersFromJson(_providersJson);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(DateTime.utc(2026, 9, 4))),
          // The providers are already seeded above from a string literal.
          // Overriding this skips a second real rootBundle asset load in the
          // same test process, which is slow and, in back-to-back widget
          // tests, does not reliably complete a second time.
          databaseReadyProvider.overrideWith((Ref ref) async {}),
        ],
        child: const BaonApp(),
      ),
    );
    await _settle(tester);

    expect(find.text('BAON'), findsOneWidget);
    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    expect(find.text('WHERE DO YOU KEEP MONEY?'), findsOneWidget);
  });

  testWidgets(
    'an account that already exists skips onboarding and shows the dashboard',
    (WidgetTester tester) async {
      final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 4));
      final BaonDatabase db = BaonDatabase.memory();
      await db.seedProvidersFromJson(_providersJson);
      addTearDown(db.close);

      final AccountRepository accounts = AccountRepository(db, clock);
      final EnvelopeRepository envelopes = EnvelopeRepository(db, clock);
      final TxnRepository txns = TxnRepository(db, clock, envelopes);
      final BalanceRepository balances = BalanceRepository(
        db,
        clock,
        accounts,
        txns,
      );

      final String gcash = await accounts.create(
        providerKey: 'gcash',
        label: 'GCash main',
      );
      await balances.saveBalance(
        accountId: gcash,
        balance: const Money(320000),
      );
      await envelopes.create(
        label: 'Food and transport',
        shape: EnvelopeShape.steady,
        refill: const Money(200000),
        refillCadence: Cadence.weekly,
        refillAnchor: 'monday',
        openingBalance: const Money(200000),
        categoryKeys: const <String>['food_daily', 'transport'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            databaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(clock),
            databaseReadyProvider.overrideWith((Ref ref) async {}),
          ],
          child: const BaonApp(),
        ),
      );
      await _settle(tester);

      expect(find.text('STEP 1 OF 4'), findsNothing);
      expect(find.text('Food and transport'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('every bottom tab opens without throwing', (
    WidgetTester tester,
  ) async {
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 4));
    final BaonDatabase db = BaonDatabase.memory();
    await db.seedProvidersFromJson(_providersJson);
    addTearDown(db.close);

    final AccountRepository accounts = AccountRepository(db, clock);
    final EnvelopeRepository envelopes = EnvelopeRepository(db, clock);
    final TxnRepository txns = TxnRepository(db, clock, envelopes);
    final BalanceRepository balances = BalanceRepository(
      db,
      clock,
      accounts,
      txns,
    );

    final String gcash = await accounts.create(
      providerKey: 'gcash',
      label: 'GCash main',
    );
    await balances.saveBalance(accountId: gcash, balance: const Money(320000));
    await envelopes.create(
      label: 'Food and transport',
      shape: EnvelopeShape.steady,
      refill: const Money(200000),
      refillCadence: Cadence.weekly,
      refillAnchor: 'monday',
      openingBalance: const Money(200000),
      categoryKeys: const <String>['food_daily', 'transport'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          databaseReadyProvider.overrideWith((Ref ref) async {}),
        ],
        child: const BaonApp(),
      ),
    );
    await _settle(tester);

    // Selected by icon, not label text: a NavigationDestination's label also
    // lives inside an unrendered Tooltip, so a text finder can be ambiguous
    // or, once a tab is already selected, briefly absent mid-transition.
    for (final IconData icon in <IconData>[
      Icons.account_balance_wallet_outlined,
      Icons.insights_outlined,
      Icons.receipt_long_outlined,
      Icons.settings_outlined,
      Icons.dashboard_outlined,
    ]) {
      await tester.tap(find.byIcon(icon).first, warnIfMissed: false);
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: 'tapping $icon threw');
    }
  });

  testWidgets("the dashboard's FIX button jumps to the Balances tab", (
    WidgetTester tester,
  ) async {
    final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 4));
    final BaonDatabase db = BaonDatabase.memory();
    await db.seedProvidersFromJson(_providersJson);
    addTearDown(db.close);

    final AccountRepository accounts = AccountRepository(db, clock);
    final EnvelopeRepository envelopes = EnvelopeRepository(db, clock);
    final TxnRepository txns = TxnRepository(db, clock, envelopes);
    final BalanceRepository balances = BalanceRepository(
      db,
      clock,
      accounts,
      txns,
    );

    // The envelope claims more than the account holds, breaking the
    // BUILD_PLAN.md Section 8.2 invariant and surfacing the FIX banner.
    final String gcash = await accounts.create(
      providerKey: 'gcash',
      label: 'GCash main',
    );
    await balances.saveBalance(accountId: gcash, balance: const Money(50000));
    await envelopes.create(
      label: 'Food and transport',
      shape: EnvelopeShape.steady,
      refill: const Money(200000),
      refillCadence: Cadence.weekly,
      refillAnchor: 'monday',
      openingBalance: const Money(200000),
      categoryKeys: const <String>['food_daily', 'transport'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          databaseReadyProvider.overrideWith((Ref ref) async {}),
        ],
        child: const BaonApp(),
      ),
    );
    await _settle(tester);

    expect(find.text('FIX'), findsOneWidget);
    await tester.tap(find.text('FIX'));
    await _settle(tester);

    expect(find.text('UPDATE BALANCES'), findsOneWidget);
  });
}
