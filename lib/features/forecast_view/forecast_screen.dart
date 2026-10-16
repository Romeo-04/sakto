/// Forecast. BUILD_PLAN.md Section 13, screen 4.
///
/// Pick an envelope, show a fan chart from P10 to P90 and the shortfall
/// probability. For an episodic envelope, show the event rate and size
/// instead of a daily rate.
library;

import 'package:baon/ai/explainer/number_guard.dart';
import 'package:baon/ai/templates.dart';
import 'package:baon/app_providers.dart';
import 'package:baon/engine/engine.dart';
import 'package:baon/features/forecast_view/afford_screen.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ForecastResult> forecast = ref.watch(forecastProvider);

    return Scaffold(
      backgroundColor: BaonColors.paper,
      body: forecast.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('$e')),
        data: (ForecastResult result) {
          if (result.envelopes.isEmpty) {
            return const EmptyState(
              icon: Icons.insights_outlined,
              title: 'No forecast yet',
              message: 'Add an envelope to see a forecast for it.',
            );
          }
          final EnvelopeForecast selected =
              result.byId(_selectedId ?? '') ?? result.envelopes.first;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.xxxl,
            ),
            children: <Widget>[
              const Text('FORECAST', style: BaonType.h1),
              const SizedBox(height: Space.lg),
              _EnvelopePicker(
                envelopes: result.envelopes,
                selectedId: selected.id,
                onSelect: (String id) => setState(() => _selectedId = id),
              ),
              const SizedBox(height: Space.lg),
              EnvelopeIdentity(
                label: selected.label,
                mood: selected.isReserve
                    ? MascotMood.sleepy
                    : moodFor(selected.headlineRisk),
              ),
              const SizedBox(height: Space.md),
              _ForecastDetail(envelope: selected),
              const SizedBox(height: Space.lg),
              _ExplainCard(envelope: selected, forecast: result),
              const SizedBox(height: Space.lg),
              GlassButton(
                label: 'CAN I AFFORD SOMETHING?',
                expand: true,
                icon: Icons.calculate_outlined,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          AffordScreen(initialEnvelopeId: selected.id),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EnvelopePicker extends StatelessWidget {
  const _EnvelopePicker({
    required this.envelopes,
    required this.selectedId,
    required this.onSelect,
  });

  final List<EnvelopeForecast> envelopes;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final e in envelopes)
          GlassChoice(
            label: e.label,
            selected: e.id == selectedId,
            onTap: () => onSelect(e.id),
          ),
      ],
    );
  }
}

/// Plain-language explanation of the forecast. BUILD_PLAN.md Section 9.5.
///
/// Every word here comes from `lib/ai/templates.dart`, which reads only the
/// engine's own [EnvelopeForecast] fields. Section 9.4's number guard is run
/// against the produced text anyway and shown alongside it, so the guard is
/// visibly exercised even before Tier 2's model exists to actually need it.
class _ExplainCard extends StatelessWidget {
  const _ExplainCard({required this.envelope, required this.forecast});

  final EnvelopeForecast envelope;
  final ForecastResult forecast;

  @override
  Widget build(BuildContext context) {
    final String explanation = explainEnvelope(envelope);
    final GuardResult guard = checkNumberGuard(
      generatedText: explanation,
      engineJson: forecast.toJson(),
    );

    return GlassCard(
      color: MascotPalette.forSeed(envelope.label).pane,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.chat_bubble_outline, color: BaonColors.accent),
              const SizedBox(width: Space.sm),
              const Expanded(
                child: Text('IN PLAIN WORDS', style: BaonType.label),
              ),
              GlassBadge(
                label: guard.isAccepted ? 'CHECKED' : 'REJECTED',
                color: guard.isAccepted
                    ? BaonColors.safeSoft
                    : BaonColors.riskySoft,
                foreground: guard.isAccepted
                    ? BaonColors.safe
                    : BaonColors.risky,
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(explanation, style: BaonType.body),
        ],
      ),
    );
  }
}

class _ForecastDetail extends StatelessWidget {
  const _ForecastDetail({required this.envelope});

  final EnvelopeForecast envelope;

  @override
  Widget build(BuildContext context) {
    if (envelope.isReserve) {
      return GlassCard(
        color: MascotPalette.forSeed(envelope.label).pane,
        child: PrimaryNumber(
          label: 'Balance',
          value: envelope.balance.format(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GlassCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: PrimaryNumber(
                  label: 'Chance of shortfall',
                  value: '${(envelope.headlineRisk * 100).round()}%',
                  color: BaonColors.ink,
                ),
              ),
              RiskBadge(probability: envelope.headlineRisk),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        if (envelope.isSteady) _SteadyDetail(envelope: envelope),
        if (envelope.isEpisodic) _EpisodicDetail(envelope: envelope),
      ],
    );
  }
}

class _SteadyDetail extends StatelessWidget {
  const _SteadyDetail({required this.envelope});

  final EnvelopeForecast envelope;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('RANGE OF OUTCOMES', style: BaonType.label),
              const SizedBox(height: Space.md),
              SizedBox(height: 140, child: _FanChart(envelope: envelope)),
              const SizedBox(height: Space.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _FanLegend(
                    label: 'P10',
                    value: envelope.endBalanceP10.format(),
                  ),
                  _FanLegend(
                    label: 'P50',
                    value: envelope.endBalanceP50.format(),
                  ),
                  _FanLegend(
                    label: 'P90',
                    value: envelope.endBalanceP90.format(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: PrimaryNumber(
                      label: 'Daily burn',
                      value: envelope.dailyBurnEwma.format(),
                      large: false,
                    ),
                  ),
                  Expanded(
                    child: PrimaryNumber(
                      label: 'Runway',
                      value: '${envelope.runwayDays.toStringAsFixed(1)} d',
                      large: false,
                    ),
                  ),
                ],
              ),
              if (envelope.committedNote.isNotEmpty) ...<Widget>[
                const SizedBox(height: Space.md),
                const Divider(),
                const SizedBox(height: Space.sm),
                Text(
                  'Committed: ${envelope.committed.format()} '
                  '(${envelope.committedNote})',
                  style: BaonType.bodyMuted,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EpisodicDetail extends StatelessWidget {
  const _EpisodicDetail({required this.envelope});

  final EnvelopeForecast envelope;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: MascotPalette.forSeed(envelope.label).pane,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: PrimaryNumber(
                  label: 'Rate',
                  value: '${envelope.eventRatePerWeek.toStringAsFixed(1)}/wk',
                  large: false,
                ),
              ),
              Expanded(
                child: PrimaryNumber(
                  label: 'Typical cost',
                  value: envelope.eventSizeMedian.format(),
                  large: false,
                ),
              ),
              Expanded(
                child: PrimaryNumber(
                  label: 'Events left',
                  value: '${envelope.eventsAffordable}',
                  large: false,
                  color: envelope.eventsAffordable <= 0
                      ? BaonColors.risky
                      : BaonColors.ink,
                ),
              ),
            ],
          ),
          if (envelope.borrowTarget != null) ...<Widget>[
            const SizedBox(height: Space.md),
            const Divider(),
            const SizedBox(height: Space.sm),
            Text(
              'Expected spill if it overruns: ${envelope.expectedSpill.format()}',
              style: BaonType.bodyMuted,
            ),
          ],
        ],
      ),
    );
  }
}

class _FanLegend extends StatelessWidget {
  const _FanLegend({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(label, style: BaonType.label),
        Text(
          value,
          style: BaonType.body.copyWith(
            fontWeight: FontWeight.w700,
            fontVariations: const [FontVariation('wght', 700)],
          ),
        ),
      ],
    );
  }
}

class _FanChart extends StatelessWidget {
  const _FanChart({required this.envelope});

  final EnvelopeForecast envelope;

  @override
  Widget build(BuildContext context) {
    final double p10 = envelope.endBalanceP10.centavos / 100;
    final double p50 = envelope.endBalanceP50.centavos / 100;
    final double p90 = envelope.endBalanceP90.centavos / 100;
    final double balance = envelope.balance.centavos / 100;

    final double minY = <double>[
      p10,
      0,
      balance,
    ].reduce((double a, double b) => a < b ? a : b);
    final double maxY = <double>[
      p90,
      balance,
    ].reduce((double a, double b) => a > b ? a : b);
    final double pad = (maxY - minY).abs() * 0.15 + 1;

    final hue = MascotPalette.forSeed(envelope.label).plate;
    LineChartBarData edge(double end, {bool median = false}) =>
        LineChartBarData(
          spots: [FlSpot(0, balance), FlSpot(1, end)],
          color: median ? BaonColors.ink : hue,
          barWidth: median ? 3 : 1,
          dotData: const FlDotData(show: false),
        );
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 1,
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: Space.xs,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(
                  value == 0 ? 'Balance' : 'P10–P90',
                  style: BaonType.label,
                ),
              ),
            ),
          ),
        ),
        lineBarsData: [edge(p10), edge(p90), edge(p50, median: true)],
        betweenBarsData: [
          BetweenBarsData(
            fromIndex: 0,
            toIndex: 1,
            color: hue.withValues(alpha: 0.5),
          ),
        ],
      ),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 150),
    );
  }
}
