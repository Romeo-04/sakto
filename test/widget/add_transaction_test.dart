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
 {"key":"gcash","display_name":"GCash","kind":"ewallet","brand_color":"#0057FF","logo_asset":"a.png","notification_package":null}
]}
''';

/// See BUILD_PLAN.md Section 13 note in
/// `lib/features/transactions/add_transaction_screen.dart`: `IndexedStack`
/// keeps every tab mounted, and an indeterminate `CircularProgressIndicator`
/// never lets `pumpAndSettle` finish, so every widget test in this repo
/// pumps a bounded number of times instead.
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
  testWidgets(
    'logging an expense resonates with the categorizer, the envelope, and '
    'the dashboard',
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

      await accounts.create(providerKey: 'gcash', label: 'GCash main');
      final AccountRow gcash = (await accounts.activeAccounts()).single;
      await balances.saveBalance(
        accountId: gcash.id,
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
            // The provider registry is already seeded above from a string
            // literal. The categorizer rules are left to load for real from
            // the bundled asset, since this test exercises exactly that.
            databaseReadyProvider.overrideWith((Ref ref) async {}),
          ],
          child: const BaonApp(),
        ),
      );
      await _settle(tester);

      // Jump to Activity and open the add-transaction screen.
      await tester.tap(
        find.byIcon(Icons.receipt_long_outlined).first,
        warnIfMissed: false,
      );
      await _settle(tester);
      await tester.tap(find.byIcon(Icons.add));
      await _settle(tester);

      expect(find.text('LOG AN EXPENSE'), findsOneWidget);

      // Type a known keyword and let the Tier 1 categorizer suggest a
      // category, exactly as it would for a bank-notification transaction.
      // Field order on screen: the amount field, then the merchant field.
      // "50" reads as PHP 50.00 — Money.tryParse treats bare digits as whole
      // pesos, matching how every other amount field in the app behaves.
      await tester.enterText(find.byType(TextField).at(0), '50');
      await tester.enterText(find.byType(TextField).at(1), 'JOLLIBEE SM NORTH');
      await _settle(tester);

      expect(
        find.textContaining('Recognised as'),
        findsOneWidget,
        reason: 'the rule categorizer should recognise "JOLLIBEE"',
      );

      // The form is long — 14 category chips wrap across several rows — so
      // the envelope preview and the LOG IT button sit below the fold on a
      // typical test viewport, exactly as they would on a real phone. Scroll
      // down as a real user would rather than asserting on off-screen state.
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await _settle(tester);

      // The envelope preview must show the correct envelope and post-spend
      // balance before the user commits.
      expect(
        find.textContaining('Comes out of Food and transport'),
        findsOneWidget,
      );
      expect(find.textContaining('PHP 1,950.00'), findsOneWidget);

      await tester.tap(find.text('LOG IT'));
      await _settle(tester);

      // Back on Activity, no dialog is left open and the log succeeded
      // (no exception thrown by the save path).
      expect(tester.takeException(), isNull);

      // Jump to Dashboard and confirm the envelope balance actually moved:
      // PHP 2,000 opening less PHP 50 spent leaves PHP 1,950.
      await tester.tap(
        find.byIcon(Icons.dashboard_outlined).first,
        warnIfMissed: false,
      );
      await _settle(tester);
      expect(find.textContaining('PHP 1,950.00'), findsOneWidget);
    },
  );
}
