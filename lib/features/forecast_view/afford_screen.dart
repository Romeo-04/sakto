/// Can I afford this? BUILD_PLAN.md Section 13, screen 5, and Section 8.7.
///
/// Amount, date and envelope in. A verdict, the money left, and the effect on
/// the essential envelope in pesos come out. This turns a vague worry into a
/// number.
library;

import 'package:baon/app_providers.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/affordability.dart';
import 'package:baon/engine/engine.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AffordScreen extends ConsumerStatefulWidget {
  const AffordScreen({super.key, this.initialEnvelopeId});

  final String? initialEnvelopeId;

  @override
  ConsumerState<AffordScreen> createState() => _AffordScreenState();
}

class _AffordScreenState extends ConsumerState<AffordScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _envelopeId;

  /// Null until the forecast's `as_of` date is known, so the default day
  /// always comes from the injected clock rather than the device's wall
  /// clock. BUILD_PLAN.md Section 16 requires the clock to be injected.
  DateTime? _date;
  AffordabilityAnswer? _answer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _envelopeId = widget.initialEnvelopeId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _check(ForecastResult forecast) async {
    final Money? amount = Money.tryParse(_amountController.text);
    if (amount == null || amount.isZero || _envelopeId == null) {
      return;
    }
    setState(() => _checking = true);
    try {
      final EnvelopeForecast? essential = forecast.essentialEnvelope;
      final AffordabilityAnswer answer = checkAffordability(
        plans: forecast.plans,
        asOf: forecast.asOf,
        userId: 'local',
        envelopeId: _envelopeId!,
        amount: amount,
        on: _date ?? forecast.asOf,
        essentialEnvelopeId: essential?.id,
      );
      if (mounted) {
        setState(() => _answer = answer);
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ForecastResult> forecast = ref.watch(forecastProvider);

    return Scaffold(
      backgroundColor: BaonColors.paper,
      appBar: AppBar(title: const Text('CAN I AFFORD THIS?')),
      body: forecast.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('$e')),
        data: (ForecastResult result) {
          _envelopeId ??= result.envelopes
              .where((EnvelopeForecast e) => !e.isReserve)
              .firstOrNull
              ?.id;
          final DateTime effectiveDate = _date ?? result.asOf;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.xxxl,
            ),
            children: <Widget>[
              GlassAmountField(
                label: 'How much?',
                controller: _amountController,
                autofocus: true,
              ),
              const SizedBox(height: Space.lg),
              const Text('WHICH ENVELOPE?', style: BaonType.label),
              const SizedBox(height: Space.sm),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: result.envelopes
                    .where((EnvelopeForecast e) => !e.isReserve)
                    .map((EnvelopeForecast e) {
                      final bool selected = e.id == _envelopeId;
                      return GlassChoice(
                        label: e.label,
                        selected: selected,
                        avatar: Mascot(
                          seed: e.label,
                          mood: moodFor(e.headlineRisk),
                          size: 28,
                        ),
                        onTap: () => setState(() {
                          _envelopeId = e.id;
                          _answer = null;
                        }),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: Space.lg),
              const Text('WHEN?', style: BaonType.label),
              const SizedBox(height: Space.sm),
              GlassButton.secondary(
                label:
                    '${effectiveDate.year}-'
                    '${effectiveDate.month.toString().padLeft(2, '0')}-'
                    '${effectiveDate.day.toString().padLeft(2, '0')}',
                icon: Icons.calendar_today_outlined,
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: effectiveDate,
                    firstDate: result.asOf,
                    lastDate: result.asOf.add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
                      _answer = null;
                    });
                  }
                },
              ),
              const SizedBox(height: Space.xl),
              GlassButton(
                label: _checking ? 'CHECKING...' : 'CHECK',
                expand: true,
                onPressed: _checking || _envelopeId == null
                    ? null
                    : () => _check(result),
              ),
              if (_answer != null) ...<Widget>[
                const SizedBox(height: Space.xl),
                _AnswerCard(answer: _answer!),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer});

  final AffordabilityAnswer answer;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (answer.verdict) {
      AffordVerdict.safe => BaonColors.safe,
      AffordVerdict.tight => BaonColors.tight,
      AffordVerdict.risky => BaonColors.risky,
    };
    final Color soft = switch (answer.verdict) {
      AffordVerdict.safe => BaonColors.safeSoft,
      AffordVerdict.tight => BaonColors.tightSoft,
      AffordVerdict.risky => BaonColors.riskySoft,
    };

    return GlassCard(
      color: soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                switch (answer.verdict) {
                  AffordVerdict.safe => Icons.check_circle,
                  AffordVerdict.tight => Icons.timelapse,
                  AffordVerdict.risky => Icons.cancel,
                },
                color: color,
                size: 32,
              ),
              const SizedBox(width: Space.sm),
              Text(
                answer.verdict.wireName.toUpperCase(),
                style: BaonType.h1.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          Text(
            'It leaves ${answer.leftInEnvelope.format()} in '
            '${answer.envelopeLabel}'
            '${answer.eventsStillAffordable > 0 ? ', enough for ${answer.eventsStillAffordable} more event${answer.eventsStillAffordable == 1 ? '' : 's'}' : ''}.',
            style: BaonType.body,
          ),
          const SizedBox(height: Space.sm),
          Text(
            answer.leavesEssentialsAlone
                ? 'It does not touch your essential spending.'
                : 'It takes about ${answer.essentialCostInPesos.format()} '
                      'from your essential spending.',
            style: BaonType.body,
          ),
          const SizedBox(height: Space.sm),
          Text(
            'Risk to this envelope: '
            '${(answer.riskOwnBefore * 100).round()}% → '
            '${(answer.riskOwnAfter * 100).round()}%.',
            style: BaonType.bodyMuted,
          ),
        ],
      ),
    );
  }
}
