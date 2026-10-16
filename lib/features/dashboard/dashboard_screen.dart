/// Dashboard. BUILD_PLAN.md Section 13, screen 2.
///
/// One card per envelope. Never one combined number, because a shortfall in
/// Dates is a different problem from a shortfall in Food and transport.
library;

import 'package:baon/app_providers.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/engine.dart';
import 'package:baon/features/transactions/add_transaction_screen.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ForecastResult> forecast = ref.watch(forecastProvider);

    return Scaffold(
      backgroundColor: BaonColors.paper,
      body: RefreshIndicator(
        color: BaonColors.accent,
        onRefresh: () async => ref.invalidate(forecastProvider),
        child: forecast.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace s) => ListView(
            children: <Widget>[
              const SizedBox(height: Space.xxxl),
              EmptyState(
                icon: Icons.error_outline,
                title: 'Could not build the forecast',
                message: '$e',
              ),
            ],
          ),
          data: (ForecastResult result) => _DashboardBody(result: result),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.result});

  final ForecastResult result;

  @override
  Widget build(BuildContext context) {
    if (result.envelopes.isEmpty) {
      return ListView(
        children: const <Widget>[
          SizedBox(height: Space.xxxl),
          EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No envelopes yet',
            message: 'Set up an envelope from Settings to start forecasting.',
          ),
        ],
      );
    }

    final EnvelopeForecast? spillSource = result.envelopes
        .where(
          (EnvelopeForecast e) =>
              e.borrowTarget != null && e.expectedSpill.isPositive,
        )
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.lg,
        Space.lg,
        Space.xxxl,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: Text('BAON', style: BaonType.h1)),
            GlassBadge(
              label: result.dataQuality == DataQuality.low
                  ? 'LEARNING'
                  : 'READY',
              color: result.dataQuality == DataQuality.low
                  ? BaonColors.tightSoft
                  : BaonColors.safeSoft,
              foreground: result.dataQuality == DataQuality.low
                  ? BaonColors.tight
                  : BaonColors.safe,
            ),
          ],
        ),
        const SizedBox(height: Space.xs),
        Text(
          'Total across accounts: ${result.accountTotal.format()}',
          style: BaonType.bodyMuted,
        ),
        const SizedBox(height: Space.lg),
        if (result.envelopesNeedFixing) ...<Widget>[
          _FixEnvelopesBanner(unallocated: result.unallocated),
          const SizedBox(height: Space.md),
        ],
        if (result.staleAccounts.isNotEmpty) ...<Widget>[
          _StaleAccountsBanner(staleAccounts: result.staleAccounts),
          const SizedBox(height: Space.md),
        ],
        if (spillSource != null) ...<Widget>[
          GlassCard(
            color: BaonColors.riskySoft,
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: BaonColors.risky,
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    '${spillSource.label} may take '
                    '${spillSource.expectedSpill.format()} from '
                    '${result.byId(spillSource.borrowTarget!)?.label ?? "another envelope"}.',
                    style: BaonType.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
        ],
        if (result.largestLever != null) ...<Widget>[
          GlassCard(
            color: BaonColors.accentSoft,
            child: Row(
              children: <Widget>[
                const Icon(Icons.lightbulb_outline, color: BaonColors.accent),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    'Biggest lever: ${result.largestLever!.action} in '
                    '${result.byId(result.largestLever!.envelopeId)?.label ?? ""} '
                    'saves ${result.largestLever!.saving.format()}.',
                    style: BaonType.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth + Space.lg * 2 >= 600 ? 2 : 1;
            final width =
                (constraints.maxWidth - Space.lg * (columns - 1)) / columns;
            return Wrap(
              spacing: Space.lg,
              runSpacing: Space.lg,
              children: [
                for (final envelope in result.envelopes)
                  SizedBox(
                    width: width,
                    child: _EnvelopeCard(envelope: envelope, result: result),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EnvelopeCard extends StatelessWidget {
  const _EnvelopeCard({required this.envelope, required this.result});

  final EnvelopeForecast envelope;
  final ForecastResult result;

  @override
  Widget build(BuildContext context) {
    final palette = MascotPalette.forSeed(envelope.label);
    final refillOn = result.plans
        .where((plan) => plan.envelope.id == envelope.id)
        .firstOrNull
        ?.envelope
        .nextRefillOn;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassCard(
          color: palette.pane,
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Mascot(
                  seed: envelope.label,
                  mood: envelope.isReserve
                      ? MascotMood.sleepy
                      : moodFor(envelope.headlineRisk),
                ),
              ),
              const SizedBox(height: Space.sm),
              Center(
                child: NamePlate(label: envelope.label, seed: envelope.label),
              ),
              const SizedBox(height: Space.sm),
              if (!envelope.isReserve)
                Center(
                  child: RefillPill(
                    label: refillOn == null
                        ? 'Refill · ${envelope.refill.format()}'
                        : 'Refill · ${refillOn.month}/${refillOn.day}',
                  ),
                ),
              const SizedBox(height: Space.sm),
              Text(
                envelope.committedNote.isNotEmpty
                    ? envelope.committedNote
                    : envelope.isReserve
                    ? 'Balance only'
                    : envelope.isSteady
                    ? 'Daily spending'
                    : 'Occasional plans',
                style: BaonType.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.lg),
              if (envelope.isReserve) _ReserveBody(envelope: envelope),
              if (envelope.isSteady) _SteadyBody(envelope: envelope),
              if (envelope.isEpisodic) _EpisodicBody(envelope: envelope),
              if (!envelope.isReserve) ...[
                const SizedBox(height: Space.md),
                Row(
                  children: [
                    RiskBadge(probability: envelope.headlineRisk),
                    const Spacer(),
                    _QuickLogButton(envelopeId: envelope.id),
                  ],
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: -3,
          left: Space.lg,
          child: RibbonTab(
            seed: envelope.label,
            label: envelope.isReserve
                ? null
                : envelope.isSteady
                ? '${envelope.daysLeft}'
                : '${envelope.eventsAffordable}',
          ),
        ),
      ],
    );
  }
}

class _ReserveBody extends StatelessWidget {
  const _ReserveBody({required this.envelope});

  final EnvelopeForecast envelope;

  @override
  Widget build(BuildContext context) {
    return PrimaryNumber(label: 'Balance', value: envelope.balance.format());
  }
}

class _SteadyBody extends StatelessWidget {
  const _SteadyBody({required this.envelope});

  final EnvelopeForecast envelope;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PrimaryNumber(label: 'Money left', value: envelope.balance.format()),
        const SizedBox(height: Space.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PrimaryNumber(
                label: 'Days left',
                value: '${envelope.daysLeft}',
                large: false,
              ),
            ),
            Expanded(
              child: PrimaryNumber(
                label: 'Safe / day',
                value: envelope.safeDaily.format(decimals: false),
                large: false,
                color: envelope.safeDaily.isZero
                    ? BaonColors.risky
                    : BaonColors.ink,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EpisodicBody extends StatelessWidget {
  const _EpisodicBody({required this.envelope});

  final EnvelopeForecast envelope;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PrimaryNumber(label: 'Money left', value: envelope.balance.format()),
        const SizedBox(height: Space.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: PrimaryNumber(
                label: 'Typical cost',
                value: envelope.eventSizeMedian.format(decimals: false),
                large: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// BUILD_PLAN.md Section 13: never show a red screen without a next action.
/// Tapping FIX jumps to Balances, the screen that actually lets the user
/// correct an envelope or account figure.
class _FixEnvelopesBanner extends ConsumerWidget {
  const _FixEnvelopesBanner({required this.unallocated});

  final Money unallocated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WarningBanner(
      message:
          'Your envelopes claim ${unallocated.abs().format()} more '
          'than your accounts hold.',
      actionLabel: 'FIX',
      onAction: () => ref.read(selectedTabProvider.notifier).state = 1,
    );
  }
}

/// Jumps to Balances so the user can enter a fresh figure for the stale
/// account named in the banner.
class _StaleAccountsBanner extends ConsumerWidget {
  const _StaleAccountsBanner({required this.staleAccounts});

  final List<String> staleAccounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WarningBanner(
      message:
          '${staleAccounts.join(", ")} '
          '${staleAccounts.length == 1 ? "hasn't" : "haven't"} '
          'been updated in a while.',
      actionLabel: 'REFRESH',
      onAction: () => ref.read(selectedTabProvider.notifier).state = 1,
      color: BaonColors.tightSoft,
    );
  }
}

/// The dashboard's per-envelope "log one now" shortcut. Opens the same
/// add-transaction screen the Activity tab's FAB opens, pre-filtered to this
/// envelope's own categories, so a quick tap from a card and a deliberate
/// visit from Activity land in the identical flow rather than two different
/// ones.
class _QuickLogButton extends StatelessWidget {
  const _QuickLogButton({required this.envelopeId});

  final String envelopeId;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: BaonColors.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
      ),
      tooltip: 'Log an expense',
      onPressed: () =>
          showAddTransactionScreen(context, envelopeId: envelopeId),
      icon: const Icon(Icons.add, size: 24),
    );
  }
}
