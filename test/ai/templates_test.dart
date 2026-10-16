import 'package:baon/ai/templates.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/engine.dart';
import 'package:baon/engine/monte_carlo.dart';
import 'package:flutter_test/flutter_test.dart';

EnvelopeForecast steady({
  double pOwn = 0.05,
  double pSpill = 0.05,
  Money committed = Money.zero,
  String committedNote = '',
}) => EnvelopeForecast(
  id: 'env_food',
  label: 'Food and transport',
  shape: EnvelopeShape.steady,
  balance: const Money(92000),
  refill: const Money(200000),
  daysLeft: 3,
  committed: committed,
  committedNote: committedNote,
  dailyBurnEwma: const Money(21000),
  dailyBurnMedian: const Money(19000),
  safeDaily: const Money(9000),
  runwayDays: 4.4,
  pShortfallOwn: pOwn,
  pShortfallWithSpill: pSpill,
  endBalanceP10: const Money(-8000),
  endBalanceP50: const Money(14000),
  endBalanceP90: const Money(33000),
  eventRatePerWeek: 0,
  eventSizeMedian: Money.zero,
  eventsAffordable: 0,
  borrowTarget: null,
  expectedSpill: Money.zero,
  horizonEnd: DateTime(2026, 9, 7),
);

EnvelopeForecast episodic({
  double risk = 0.47,
  int eventsAffordable = 1,
  String? borrowTarget = 'env_food',
  Money expectedSpill = const Money(26000),
}) => EnvelopeForecast(
  id: 'env_dates',
  label: 'Dates',
  shape: EnvelopeShape.episodic,
  balance: const Money(120000),
  refill: const Money(300000),
  daysLeft: 12,
  committed: Money.zero,
  committedNote: '',
  dailyBurnEwma: Money.zero,
  dailyBurnMedian: Money.zero,
  safeDaily: Money.zero,
  runwayDays: 0,
  pShortfallOwn: risk,
  pShortfallWithSpill: risk,
  endBalanceP10: Money.zero,
  endBalanceP50: Money.zero,
  endBalanceP90: Money.zero,
  eventRatePerWeek: 1.8,
  eventSizeMedian: const Money(90000),
  eventsAffordable: eventsAffordable,
  borrowTarget: borrowTarget,
  expectedSpill: expectedSpill,
  horizonEnd: DateTime(2026, 9, 16),
);

EnvelopeForecast get reserve => EnvelopeForecast(
  id: 'env_savings',
  label: 'Savings',
  shape: EnvelopeShape.reserve,
  balance: const Money(472000),
  refill: Money.zero,
  daysLeft: 0,
  committed: Money.zero,
  committedNote: '',
  dailyBurnEwma: Money.zero,
  dailyBurnMedian: Money.zero,
  safeDaily: Money.zero,
  runwayDays: 0,
  pShortfallOwn: 0,
  pShortfallWithSpill: 0,
  endBalanceP10: Money.zero,
  endBalanceP50: Money.zero,
  endBalanceP90: Money.zero,
  eventRatePerWeek: 0,
  eventSizeMedian: Money.zero,
  eventsAffordable: 0,
  borrowTarget: null,
  expectedSpill: Money.zero,
  horizonEnd: DateTime(2026, 9, 18),
);

void main() {
  group('explainSteadyEnvelope', () {
    test('matches the shape of the Section 9.5 example exactly', () {
      final String text = explainSteadyEnvelope(steady());
      expect(text, contains('You have PHP 920.00 for 3 days.'));
      expect(text, contains('That is PHP 90.00 a day.'));
      expect(text, contains('You currently spend about PHP 210.00 a day.'));
      expect(text, contains('Chance of running short: 5%.'));
    });

    test('uses the singular for exactly one day left', () {
      final EnvelopeForecast e = EnvelopeForecast(
        id: 'x',
        label: 'x',
        shape: EnvelopeShape.steady,
        balance: const Money(1000),
        refill: Money.zero,
        daysLeft: 1,
        committed: Money.zero,
        committedNote: '',
        dailyBurnEwma: Money.zero,
        dailyBurnMedian: Money.zero,
        safeDaily: Money.zero,
        runwayDays: 0,
        pShortfallOwn: 0,
        pShortfallWithSpill: 0,
        endBalanceP10: Money.zero,
        endBalanceP50: Money.zero,
        endBalanceP90: Money.zero,
        eventRatePerWeek: 0,
        eventSizeMedian: Money.zero,
        eventsAffordable: 0,
        borrowTarget: null,
        expectedSpill: Money.zero,
        horizonEnd: DateTime(2026, 9, 18),
      );
      expect(explainSteadyEnvelope(e), contains('1 day.'));
      expect(explainSteadyEnvelope(e), isNot(contains('1 days.')));
    });

    test('mentions the committed cost and its note when there is one', () {
      final String text = explainSteadyEnvelope(
        steady(
          committed: const Money(45000),
          committedNote: 'commute, 3 weekdays',
        ),
      );
      expect(text, contains('sets aside PHP 450.00'));
      expect(text, contains('for commute, 3 weekdays'));
    });

    test('says nothing about a commitment when there is none', () {
      expect(explainSteadyEnvelope(steady()), isNot(contains('sets aside')));
    });
  });

  group('explainEpisodicEnvelope', () {
    test('reports the rate and size, never a daily figure', () {
      final String text = explainEpisodicEnvelope(episodic());
      expect(text, contains('1.8 a week'));
      expect(text, contains('around PHP 900.00 each time'));
      expect(text, contains('1 more event'));
      expect(text, contains('Chance of running short: 47%.'));
    });

    test('uses the plural for more than one event', () {
      final String text = explainEpisodicEnvelope(
        episodic(eventsAffordable: 2),
      );
      expect(text, contains('2 more events'));
    });

    test('mentions the spill only when there is a positive one', () {
      final String withSpill = explainEpisodicEnvelope(episodic());
      expect(
        withSpill,
        contains('PHP 260.00 to come out of your other envelopes'),
      );

      final String noSpill = explainEpisodicEnvelope(
        episodic(borrowTarget: null, expectedSpill: Money.zero),
      );
      expect(noSpill, isNot(contains('come out of')));
    });
  });

  group('explainReserveEnvelope', () {
    test('reports only the balance, never a risk', () {
      final String text = explainReserveEnvelope(reserve);
      expect(text, contains('PHP 4,720.00'));
      expect(text, isNot(contains('%')));
      expect(text, isNot(contains('risk')));
    });
  });

  group('explainEnvelope dispatches by shape', () {
    test('picks the steady template', () {
      expect(explainEnvelope(steady()), explainSteadyEnvelope(steady()));
    });

    test('picks the episodic template', () {
      expect(explainEnvelope(episodic()), explainEpisodicEnvelope(episodic()));
    });

    test('picks the reserve template', () {
      expect(explainEnvelope(reserve), explainReserveEnvelope(reserve));
    });
  });

  group('explainForecast', () {
    ForecastResult forecastWith(
      List<EnvelopeForecast> envelopes, {
      DataQuality quality = DataQuality.good,
      Money unallocated = Money.zero,
    }) => ForecastResult(
      asOf: DateTime(2026, 9, 4),
      accountTotal: const Money(684000),
      unallocated: unallocated,
      envelopes: envelopes,
      largestLever: null,
      staleAccounts: const <String>[],
      dataQuality: quality,
      plans: const <EnvelopePlan>[],
    );

    test('asks for an envelope when there are none', () {
      expect(
        explainForecast(forecastWith(const <EnvelopeForecast>[])),
        contains('Add an envelope'),
      );
    });

    test('flags a broken invariant before anything else', () {
      final String text = explainForecast(
        forecastWith(<EnvelopeForecast>[
          steady(),
        ], unallocated: const Money(-5000)),
      );
      expect(text, contains('PHP 50.00 more'));
      expect(text, contains('Fix your envelopes'));
    });

    test('picks the riskiest non-reserve envelope', () {
      final String text = explainForecast(
        forecastWith(<EnvelopeForecast>[
          steady(pSpill: 0.05),
          episodic(risk: 0.5),
          reserve,
        ]),
      );
      expect(text, contains('Dates'));
      expect(text, contains('real risk'));
    });

    test('reports safe when the riskiest envelope is comfortable', () {
      final String text = explainForecast(
        forecastWith(<EnvelopeForecast>[steady(pSpill: 0.02)]),
      );
      expect(text, contains('looks safe'));
    });

    test('reports tight in the middle band', () {
      final String text = explainForecast(
        forecastWith(<EnvelopeForecast>[steady(pSpill: 0.2)]),
      );
      expect(text, contains('is tight'));
    });

    test('mentions data quality only when it is low', () {
      final String low = explainForecast(
        forecastWith(<EnvelopeForecast>[
          steady(pSpill: 0.02),
        ], quality: DataQuality.low),
      );
      expect(low, contains('sharpen as you log more days'));

      final String good = explainForecast(
        forecastWith(<EnvelopeForecast>[steady(pSpill: 0.02)]),
      );
      expect(good, isNot(contains('sharpen')));
    });

    test('says nothing is at risk when only reserves exist', () {
      final String text = explainForecast(
        forecastWith(<EnvelopeForecast>[reserve]),
      );
      expect(text, contains('Nothing is at risk'));
    });
  });
}
