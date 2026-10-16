/// Template fallback. BUILD_PLAN.md Section 9.5.
///
/// The app must be fully useful with the language model turned off. These
/// templates are what the explainer falls back to — and, until Tier 2 ships,
/// what it always uses. Every number here comes straight from the engine's
/// [EnvelopeForecast]; nothing is computed in this file. Section 2's rule
/// ("the language model never computes a number") holds trivially here
/// because there is no model in the loop at all.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/engine.dart';

/// Builds the one-paragraph explanation for a steady envelope.
///
/// Matches the example string in BUILD_PLAN.md Section 9.5:
/// "You have PHP {spendable} for {days_left} days. That is PHP {safe_daily}
/// a day. You currently spend about PHP {daily_burn_ewma} a day. Chance of
/// running short: {p_shortfall}%."
String explainSteadyEnvelope(EnvelopeForecast envelope) {
  final Money usable = (envelope.balance - envelope.committed).clampToZero();
  final int riskPercent = (envelope.headlineRisk * 100).round();

  final StringBuffer out = StringBuffer()
    ..write('You have ${usable.format()} for ${envelope.daysLeft} ')
    ..write(envelope.daysLeft == 1 ? 'day. ' : 'days. ')
    ..write('That is ${envelope.safeDaily.format()} a day. ')
    ..write(
      'You currently spend about ${envelope.dailyBurnEwma.format()} a day. ',
    )
    ..write('Chance of running short: $riskPercent%.');

  if (envelope.committed.isPositive) {
    out.write(' This already sets aside ${envelope.committed.format()}');
    if (envelope.committedNote.isNotEmpty) {
      out.write(' for ${envelope.committedNote}');
    }
    out.write('.');
  }

  return out.toString();
}

/// Builds the explanation for an episodic envelope.
///
/// BUILD_PLAN.md Section 8.4: report the rate and the size, not a daily
/// figure, because a daily average is never true for a lumpy spend.
String explainEpisodicEnvelope(EnvelopeForecast envelope) {
  final int riskPercent = (envelope.headlineRisk * 100).round();
  final String rate = envelope.eventRatePerWeek.toStringAsFixed(1);

  final StringBuffer out = StringBuffer()
    ..write('You spend about $rate a week here, ')
    ..write('around ${envelope.eventSizeMedian.format()} each time. ')
    ..write('At this rate, ${envelope.label} affords ')
    ..write('${envelope.eventsAffordable} more ')
    ..write(envelope.eventsAffordable == 1 ? 'event ' : 'events ')
    ..write('before it runs out. Chance of running short: $riskPercent%.');

  if (envelope.borrowTarget != null && envelope.expectedSpill.isPositive) {
    out.write(
      ' If it does, expect about ${envelope.expectedSpill.format()} to '
      'come out of your other envelopes.',
    );
  }

  return out.toString();
}

/// Builds the explanation for a reserve envelope. There is no risk to report,
/// because BUILD_PLAN.md Section 8.4 says a reserve is never in a runway.
String explainReserveEnvelope(EnvelopeForecast envelope) {
  return 'You are holding ${envelope.balance.format()} in ${envelope.label}. '
      'This money is set aside and is not part of any spending forecast.';
}

/// Picks the right template for whatever shape the envelope is.
String explainEnvelope(EnvelopeForecast envelope) {
  if (envelope.isReserve) {
    return explainReserveEnvelope(envelope);
  }
  if (envelope.isEpisodic) {
    return explainEpisodicEnvelope(envelope);
  }
  return explainSteadyEnvelope(envelope);
}

/// A one-line summary across every envelope, for the dashboard header.
///
/// BUILD_PLAN.md Section 13: one primary number per screen. This template
/// picks the single riskiest envelope rather than trying to average every
/// envelope into one meaningless figure.
String explainForecast(ForecastResult forecast) {
  if (forecast.envelopes.isEmpty) {
    return 'Add an envelope to get a forecast.';
  }

  if (forecast.envelopesNeedFixing) {
    return 'Your envelopes claim ${forecast.unallocated.abs().format()} more '
        'than your accounts hold. Fix your envelopes before trusting this '
        'forecast.';
  }

  EnvelopeForecast? worst;
  for (final EnvelopeForecast e in forecast.envelopes) {
    if (e.isReserve) {
      continue;
    }
    if (worst == null || e.headlineRisk > worst.headlineRisk) {
      worst = e;
    }
  }
  if (worst == null) {
    return 'Everything here is savings. Nothing is at risk right now.';
  }

  final String quality = forecast.dataQuality == DataQuality.low
      ? ' This estimate will sharpen as you log more days.'
      : '';

  if (worst.headlineRisk < 0.10) {
    return '${worst.label} looks safe for now.$quality';
  }
  if (worst.headlineRisk < 0.35) {
    return '${worst.label} is tight. Keep an eye on it.$quality';
  }
  return '${worst.label} is at real risk of running short.$quality';
}
