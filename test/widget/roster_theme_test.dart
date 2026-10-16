@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:baon/app_providers.dart';
import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/balance_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/data/repositories/txn_repository.dart';
import 'package:baon/features/forecast_view/afford_screen.dart';
import 'package:baon/features/onboarding/onboarding_screen.dart';
import 'package:baon/features/transactions/add_transaction_screen.dart';
import 'package:baon/main.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/theme.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  test('mascot moods use the existing risk boundaries', () {
    expect(moodFor(0.099), MascotMood.happy);
    expect(moodFor(0.10), MascotMood.worried);
    expect(moodFor(0.349), MascotMood.worried);
    expect(moodFor(0.35), MascotMood.crying);
    expect(
      MascotPalette.forSeed('Food and transport'),
      same(MascotPalette.forSeed('Food and transport')),
    );
  });
  testWidgets('button supports keyboard activation and disabled state', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildBaonTheme(),
        home: Scaffold(
          body: GlassButton(label: 'SAVE', onPressed: () => taps++),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildBaonTheme(),
        home: const Scaffold(body: GlassButton(label: 'SAVE', onPressed: null)),
      ),
    );
    await tester.tap(find.text('SAVE'));
    expect(taps, 1);
  });
  testWidgets('risk change settles and respects reduced motion', (
    tester,
  ) async {
    Widget host(MascotMood mood, bool reduced) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Mascot(seed: 'Dates', mood: mood),
      ),
    );
    await tester.pumpWidget(host(MascotMood.happy, false));
    await tester.pumpWidget(host(MascotMood.crying, false));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(host(MascotMood.sleepy, true));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 600.0, 1100.0]) {
    testWidgets('all screens fit at ${width.toInt()}dp with real fonts', (
      tester,
    ) async {
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final family in ['Fredoka', 'Nunito']) {
        final loader = FontLoader(family)
          ..addFont(
            Future.value(
              ByteData.sublistView(
                File('assets/fonts/$family.ttf').readAsBytesSync(),
              ),
            ),
          );
        await loader.load();
      }
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File(
                'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
              ).readAsBytesSync(),
            ),
          ),
        );
      await icons.load();
      final clock = FixedClock(DateTime.utc(2026, 9, 4));
      final db = BaonDatabase.memory();
      await db.seedProvidersFromJson(
        '{"version":1,"providers":[{"key":"gcash","display_name":"GCash","kind":"ewallet","brand_color":"#0057FF","logo_asset":"a.png","notification_package":null}]}',
      );
      final accounts = AccountRepository(db, clock);
      final envelopes = EnvelopeRepository(db, clock);
      final txns = TxnRepository(db, clock, envelopes);
      final balances = BalanceRepository(db, clock, accounts, txns);
      final account = await accounts.create(
        providerKey: 'gcash',
        label: 'GCash main',
      );
      await balances.saveBalance(
        accountId: account,
        balance: const Money(600000),
      );
      for (final entry in [
        ('Food and transport', EnvelopeShape.steady),
        ('Dates', EnvelopeShape.episodic),
        ('Savings', EnvelopeShape.reserve),
      ]) {
        await envelopes.create(
          label: entry.$1,
          shape: entry.$2,
          refill: const Money(200000),
          refillCadence: entry.$2 == EnvelopeShape.reserve
              ? Cadence.none
              : Cadence.weekly,
          refillAnchor: 'monday',
          openingBalance: const Money(200000),
          categoryKeys: entry.$2 == EnvelopeShape.steady
              ? ['food_daily', 'transport']
              : entry.$2 == EnvelopeShape.episodic
              ? ['dates_leisure']
              : [],
        );
      }
      for (var day = 1; day <= 7; day++) {
        await txns.record(
          accountId: account,
          amount: const Money(12000),
          direction: TxnDirection.moneyOut,
          categoryKey: 'food_daily',
          occurredAt: DateTime.utc(2026, 9, day),
        );
      }
      await txns.record(
        accountId: account,
        amount: const Money(60000),
        direction: TxnDirection.moneyOut,
        categoryKey: 'dates_leisure',
        occurredAt: DateTime.utc(2026, 9, 3),
      );
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          databaseReadyProvider.overrideWith((ref) async {}),
        ],
      );
      const key = ValueKey('capture');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RepaintBoundary(key: key, child: BaonApp()),
        ),
      );
      await settle(tester);
      Future<void> capture(String name) async {
        expect(tester.takeException(), isNull, reason: '$name at $width');
        if (const bool.fromEnvironment('CAPTURE_ROSTER')) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(key),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File(
              '.impeccable/review/roster/$name-${width.toInt()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
      }

      await capture('dashboard');
      final plateA = tester.getRect(
        find.widgetWithText(NamePlate, 'Food and transport'),
      );
      final plateB = tester.getRect(find.widgetWithText(NamePlate, 'Dates'));
      if (width >= 600) {
        expect(plateA.top, plateB.top);
      } else {
        expect(plateB.top, greaterThan(plateA.bottom));
      }
      for (var index = 1; index < 5; index++) {
        container.read(selectedTabProvider.notifier).state = index;
        await settle(tester);
        await capture(
          ['dashboard', 'balances', 'forecast', 'activity', 'settings'][index],
        );
      }
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      unawaited(
        nav.push(MaterialPageRoute<void>(builder: (_) => const AffordScreen())),
      );
      await settle(tester);
      await capture('afford');
      nav.pop();
      await settle(tester);
      unawaited(
        nav.push(
          MaterialPageRoute<void>(builder: (_) => const AddTransactionScreen()),
        ),
      );
      await settle(tester);
      await capture('add-transaction');
      nav.pop();
      await settle(tester);
      unawaited(
        nav.push(
          MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
        ),
      );
      await settle(tester);
      await capture('onboarding');
      nav.pop();
      await settle(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await db.close();
      debugDisableShadows = true;
    });
  }
}
