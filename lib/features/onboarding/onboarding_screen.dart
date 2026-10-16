/// Onboarding. BUILD_PLAN.md Section 13, screen 1.
///
/// Pick providers, enter the first balance for each, build envelopes, ask for
/// the weekday commute. The steps are linear because there is no useful
/// dashboard until all four exist.
library;

import 'package:baon/app_providers.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _SelectedAccount {
  _SelectedAccount({required this.provider});

  final ProviderRow provider;
  Money balance = Money.zero;
}

class _EnvelopeDraft {
  _EnvelopeDraft({
    required this.label,
    required this.shape,
    required this.refill,
    required this.cadence,
    required this.opening,
  });

  final String label;
  final EnvelopeShape shape;
  final Money refill;
  final Cadence cadence;
  Money opening;
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  final List<_SelectedAccount> _accounts = <_SelectedAccount>[];
  final List<_EnvelopeDraft> _envelopes = <_EnvelopeDraft>[
    _EnvelopeDraft(
      label: 'Food and transport',
      shape: EnvelopeShape.steady,
      refill: const Money(200000),
      cadence: Cadence.weekly,
      opening: Money.zero,
    ),
    _EnvelopeDraft(
      label: 'Dates',
      shape: EnvelopeShape.episodic,
      refill: const Money(300000),
      cadence: Cadence.monthly,
      opening: Money.zero,
    ),
    _EnvelopeDraft(
      label: 'Savings',
      shape: EnvelopeShape.reserve,
      refill: Money.zero,
      cadence: Cadence.none,
      opening: Money.zero,
    ),
  ];

  Money _commute = Money.zero;
  bool _saving = false;

  static const int _totalSteps = 4;

  void _next() {
    if (_step >= _totalSteps - 1) {
      _finish();
      return;
    }
    setState(() => _step++);
    _pageController.animateToPage(
      _step,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_step == 0) {
      return;
    }
    setState(() => _step--);
    _pageController.animateToPage(
      _step,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _accounts.isNotEmpty;
      case 1:
        return true;
      case 2:
        return _envelopes.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final Map<String, String> accountIds = <String, String>{};
      for (final _SelectedAccount a in _accounts) {
        final String id = await ref
            .read(accountRepositoryProvider)
            .create(providerKey: a.provider.key, label: a.provider.displayName);
        accountIds[a.provider.key] = id;
        await ref
            .read(balanceRepositoryProvider)
            .saveBalance(accountId: id, balance: a.balance);
      }

      // Steady envelopes are created first, so their real ids exist by the
      // time an episodic envelope needs to name one as a borrow target.
      String? firstSteadyId;
      final List<_EnvelopeDraft> ordered = <_EnvelopeDraft>[
        ..._envelopes.where(
          (_EnvelopeDraft e) => e.shape == EnvelopeShape.steady,
        ),
        ..._envelopes.where(
          (_EnvelopeDraft e) => e.shape != EnvelopeShape.steady,
        ),
      ];

      for (final _EnvelopeDraft e in ordered) {
        final String id = await ref
            .read(envelopeRepositoryProvider)
            .create(
              label: e.label,
              shape: e.shape,
              refill: e.refill,
              refillCadence: e.cadence,
              refillAnchor: e.cadence == Cadence.weekly ? 'monday' : '1',
              openingBalance: e.opening,
              categoryKeys: switch (e.shape) {
                EnvelopeShape.steady => const <String>[
                  'transport',
                  'food_daily',
                  'groceries',
                  'load_data',
                ],
                EnvelopeShape.episodic => const <String>['dates_leisure'],
                EnvelopeShape.reserve => const <String>[],
              },
              allowBorrowFrom:
                  e.shape == EnvelopeShape.episodic && firstSteadyId != null
                  ? <String>[firstSteadyId]
                  : const <String>[],
            );
        if (e.shape == EnvelopeShape.steady) {
          firstSteadyId ??= id;
        }
      }

      await ref.read(settingsRepositoryProvider).setCommutePerWeekday(_commute);
      await ref.read(settingsRepositoryProvider).setOnboardingDone(true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaonColors.paper,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.lg,
                Space.lg,
                Space.md,
              ),
              child: Row(
                children: <Widget>[
                  const Text('BAON', style: BaonType.h1),
                  const Spacer(),
                  Text(
                    'STEP ${_step + 1} OF $_totalSteps',
                    style: BaonType.label,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: _StepProgress(step: _step, total: _totalSteps),
            ),
            const SizedBox(height: Space.md),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _AccountsStep(
                    accounts: _accounts,
                    onChanged: () => setState(() {}),
                  ),
                  _EnvelopesStep(
                    envelopes: _envelopes,
                    onChanged: () => setState(() {}),
                  ),
                  _CommuteStep(
                    commute: _commute,
                    onChanged: (Money m) => setState(() => _commute = m),
                  ),
                  _ReviewStep(accounts: _accounts, envelopes: _envelopes),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                children: <Widget>[
                  if (_step > 0)
                    Expanded(
                      child: GlassButton.secondary(
                        label: 'BACK',
                        onPressed: _saving ? null : _back,
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: Space.md),
                  Expanded(
                    flex: 2,
                    child: GlassButton(
                      label: _step == _totalSteps - 1 ? 'FINISH' : 'NEXT',
                      expand: true,
                      onPressed: _saving || !_canProceed ? null : _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(total, (int i) {
        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : Space.xs),
            decoration: BoxDecoration(
              color: i <= step ? BaonColors.accent : BaonColors.surfaceMuted,
              borderRadius: BorderRadius.circular(Corner.pill),
              border: Border.all(
                color: BaonColors.border,
                width: BorderWeight.hairline,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AccountsStep extends ConsumerWidget {
  const _AccountsStep({required this.accounts, required this.onChanged});

  final List<_SelectedAccount> accounts;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProviderRow>> providers = ref.watch(
      providersProvider,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('WHERE DO YOU KEEP MONEY?', style: BaonType.h2),
          const SizedBox(height: Space.xs),
          const Text(
            'Pick every account and wallet you use. You can enter today\'s '
            'balance for each right after.',
            style: BaonType.bodyMuted,
          ),
          const SizedBox(height: Space.lg),
          providers.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(Space.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, StackTrace s) => Text('$e'),
            data: (List<ProviderRow> rows) => Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: rows.map((ProviderRow p) {
                final bool selected = accounts.any(
                  (_SelectedAccount a) => a.provider.key == p.key,
                );
                return _ProviderChip(
                  provider: p,
                  selected: selected,
                  onTap: () {
                    if (selected) {
                      accounts.removeWhere(
                        (_SelectedAccount a) => a.provider.key == p.key,
                      );
                    } else {
                      accounts.add(_SelectedAccount(provider: p));
                    }
                    onChanged();
                  },
                );
              }).toList(),
            ),
          ),
          if (accounts.isNotEmpty) ...<Widget>[
            const SizedBox(height: Space.xl),
            const Text('TODAY\'S BALANCE', style: BaonType.label),
            const SizedBox(height: Space.sm),
            for (final _SelectedAccount a in accounts)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.md),
                child: GlassCard(
                  padding: const EdgeInsets.all(Space.md),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          a.provider.displayName,
                          style: BaonType.body,
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            prefixText: 'PHP ',

                            isDense: true,
                          ),
                          onChanged: (String v) {
                            a.balance = Money.tryParse(v) ?? Money.zero;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProviderChip extends StatelessWidget {
  const _ProviderChip({
    required this.provider,
    required this.selected,
    required this.onTap,
  });

  final ProviderRow provider;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassChoice(
      label: provider.displayName,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _EnvelopesStep extends StatelessWidget {
  const _EnvelopesStep({required this.envelopes, required this.onChanged});

  final List<_EnvelopeDraft> envelopes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('SPLIT YOUR MONEY BY PURPOSE', style: BaonType.h2),
          const SizedBox(height: Space.xs),
          const Text(
            'An envelope is a purpose, not a place. These three cover most '
            'people. Set the money already set aside for each.',
            style: BaonType.bodyMuted,
          ),
          const SizedBox(height: Space.lg),
          for (final _EnvelopeDraft e in envelopes)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: GlassCard(
                color: MascotPalette.forSeed(e.label).pane,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EnvelopeIdentity(
                            label: e.label,
                            mood: e.shape == EnvelopeShape.reserve
                                ? MascotMood.sleepy
                                : MascotMood.happy,
                          ),
                          const SizedBox(height: Space.sm),
                          GlassBadge(
                            label: e.shape.wireName.toUpperCase(),
                            color: MascotPalette.forSeed(e.label).plate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          prefixText: 'PHP ',
                          isDense: true,
                        ),
                        onChanged: (String v) {
                          envelopes[envelopes.indexOf(e)].opening =
                              Money.tryParse(v) ?? Money.zero;
                          onChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommuteStep extends StatefulWidget {
  const _CommuteStep({required this.commute, required this.onChanged});

  final Money commute;
  final ValueChanged<Money> onChanged;

  @override
  State<_CommuteStep> createState() => _CommuteStepState();
}

class _CommuteStepState extends State<_CommuteStep> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.commute.isZero ? '' : widget.commute.format(symbol: false),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('YOUR DAILY COMMUTE', style: BaonType.h2),
          const SizedBox(height: Space.xs),
          const Text(
            'A known weekday fare is not a random cost. Telling the app about '
            'it makes every forecast sharper. Leave it at zero if you don\'t '
            'commute on a schedule.',
            style: BaonType.bodyMuted,
          ),
          const SizedBox(height: Space.lg),
          GlassAmountField(
            label: 'Fare per weekday, both ways',
            controller: _controller,
            onSubmitted: (String v) =>
                widget.onChanged(Money.tryParse(v) ?? Money.zero),
          ),
          const SizedBox(height: Space.sm),
          TextButton(
            onPressed: () => widget.onChanged(
              Money.tryParse(_controller.text) ?? Money.zero,
            ),
            child: const Text('CONFIRM AMOUNT', style: BaonType.label),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.accounts, required this.envelopes});

  final List<_SelectedAccount> accounts;
  final List<_EnvelopeDraft> envelopes;

  @override
  Widget build(BuildContext context) {
    final Money total = Money.sum(
      accounts.map((_SelectedAccount a) => a.balance),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('READY TO GO', style: BaonType.h2),
          const SizedBox(height: Space.xs),
          const Text(
            'Baon will track your accounts and envelopes from here, and start '
            'learning your spending pattern.',
            style: BaonType.bodyMuted,
          ),
          const SizedBox(height: Space.lg),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PrimaryNumber(
                  label: 'Total across accounts',
                  value: total.format(),
                ),
                const SizedBox(height: Space.md),
                Text(
                  '${accounts.length} accounts, ${envelopes.length} envelopes',
                  style: BaonType.bodyMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
