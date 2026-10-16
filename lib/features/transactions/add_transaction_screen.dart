/// Log one expense or one bit of income right now.
///
/// Not one of the seven screens BUILD_PLAN.md Section 13 names outright —
/// the plan's primary flow is balance entry plus reconciliation (Section
/// 8.1), because "the user will not log every jeepney fare." This screen is
/// for the moment a user *does* want to log one on the spot, and it is built
/// to resonate with everything else rather than sit beside it:
///
/// - The merchant text field runs through the same Tier 1 rule categorizer
///   (Section 9.2) that scores every other transaction, so typing "Jollibee"
///   suggests `food_daily` here exactly as it would if the spend had come in
///   through a bank notification.
/// - The envelope preview reuses [TxnRepository.previewEnvelopeFor], the same
///   routing rule [TxnRepository.record] itself applies — there is only one
///   place that decides which envelope a category belongs to.
/// - Saving invalidates [forecastProvider], so the Dashboard and Forecast
///   screens reflect the new envelope balance immediately.
/// - Logging it now is not busywork: BUILD_PLAN.md Section 8.1 has the
///   reconciler subtract every logged transaction from the next balance gap.
///   A transaction logged here is one the reconciler already knows about, so
///   it will not show up as "Unaccounted" later.
library;

import 'package:baon/ai/categorizer/rule_categorizer.dart';
import 'package:baon/app_providers.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the screen. [envelopeId] pre-filters the category list to that
/// envelope's own categories — how the dashboard's per-card "+" resonates
/// with this screen instead of dropping the user into an unfiltered form.
Future<void> showAddTransactionScreen(
  BuildContext context, {
  String? envelopeId,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AddTransactionScreen(envelopeId: envelopeId),
    ),
  );
}

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.envelopeId});

  /// When set, the category chips are filtered to this envelope's own
  /// categories, and it is preselected as the target.
  final String? envelopeId;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  TxnDirection _direction = TxnDirection.moneyOut;
  String? _accountId;
  String? _categoryKey;
  DateTime? _occurredAt;
  CategorySuggestion? _suggestion;
  bool _categoryTouchedByUser = false;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  /// Runs the merchant text through the rule categorizer as the user types.
  ///
  /// Mirrors BUILD_PLAN.md Section 9.2 exactly: a rule match is confidence
  /// 1.0 and applies automatically above 0.85, but only while the user has
  /// not already picked a category by hand — a person's own choice always
  /// wins over a keyword guess.
  void _onMerchantChanged(String text, RuleCategorizer categorizer) {
    final CategorySuggestion? suggestion = categorizer.suggest(text);
    setState(() {
      _suggestion = suggestion;
      if (suggestion != null &&
          suggestion.canAutoApply &&
          !_categoryTouchedByUser) {
        _categoryKey = suggestion.categoryKey;
      }
    });
  }

  Future<void> _save(DateTime today) async {
    final Money? amount = Money.tryParse(_amountController.text);
    if (amount == null ||
        amount.isZero ||
        _accountId == null ||
        _categoryKey == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(txnRepositoryProvider)
          .record(
            accountId: _accountId!,
            amount: amount,
            direction: _direction,
            categoryKey: _categoryKey!,
            occurredAt: _occurredAt ?? today,
            merchantRaw: _merchantController.text.trim().isEmpty
                ? null
                : _merchantController.text.trim(),
            categoryConfidence: _suggestion?.canAutoApply == true ? 1 : 0,
          );
      ref.invalidate(forecastProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Logged. This won't show up as Unaccounted next balance update.",
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AccountWithBalance>> accounts = ref.watch(
      accountsProvider,
    );
    final AsyncValue<List<CategoryRow>> categories = ref.watch(
      categoriesProvider,
    );
    final AsyncValue<List<EnvelopeWithState>> envelopes = ref.watch(
      envelopesProvider,
    );
    final AsyncValue<RuleCategorizer> categorizer = ref.watch(
      categorizerProvider,
    );
    final DateTime today = ref.read(clockProvider).today();

    return Scaffold(
      backgroundColor: BaonColors.paper,
      appBar: AppBar(
        title: Text(
          _direction == TxnDirection.moneyOut ? 'LOG AN EXPENSE' : 'LOG INCOME',
        ),
      ),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('$e')),
        data: (List<AccountWithBalance> accountRows) {
          if (accountRows.isEmpty) {
            return const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No accounts yet',
              message: 'Add an account from Settings first.',
            );
          }
          _accountId ??= accountRows.first.account.id;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.xxxl,
            ),
            children: <Widget>[
              _DirectionToggle(
                direction: _direction,
                onChanged: (TxnDirection d) => setState(() => _direction = d),
              ),
              const SizedBox(height: Space.lg),
              GlassAmountField(
                label: 'Amount',
                controller: _amountController,
                autofocus: true,
                onSubmitted: (_) => setState(() {}),
              ),
              const SizedBox(height: Space.lg),
              const Text('FROM', style: BaonType.label),
              const SizedBox(height: Space.sm),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: accountRows.map((AccountWithBalance a) {
                  final bool selected = a.account.id == _accountId;
                  return _Chip(
                    label: a.account.label,
                    selected: selected,
                    onTap: () => setState(() => _accountId = a.account.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: Space.lg),
              const Text('WHAT WAS IT?', style: BaonType.label),
              const SizedBox(height: Space.sm),
              TextField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Jollibee, Grab, 7-Eleven',
                ),
                onChanged: (String text) {
                  categorizer.whenData(
                    (RuleCategorizer c) => _onMerchantChanged(text, c),
                  );
                },
              ),
              if (_suggestion != null) ...<Widget>[
                const SizedBox(height: Space.xs),
                Text(
                  _suggestion!.canAutoApply
                      ? 'Recognised as "${_suggestion!.matchedKeyword}" → auto-filed below.'
                      : 'Might be "${_suggestion!.matchedKeyword}" — confirm below.',
                  style: BaonType.bodyMuted,
                ),
              ],
              const SizedBox(height: Space.lg),
              const Text('CATEGORY', style: BaonType.label),
              const SizedBox(height: Space.sm),
              categories.when(
                loading: () => const _InlineLoading(),
                error: (Object e, StackTrace s) => Text('$e'),
                data: (List<CategoryRow> allCategories) {
                  // When opened from a specific envelope's "+", narrow the
                  // chips to that envelope's own categories. Falls back to
                  // the full list once envelopes are loaded and either no
                  // envelope was named or it turns out to route nothing.
                  final List<String>? allowedKeys = widget.envelopeId == null
                      ? null
                      : envelopes.maybeWhen(
                          data: (List<EnvelopeWithState> envRows) => envRows
                              .where(
                                (EnvelopeWithState e) =>
                                    e.id == widget.envelopeId,
                              )
                              .firstOrNull
                              ?.categoryKeys,
                          orElse: () => null,
                        );
                  final List<CategoryRow> filtered = allowedKeys == null
                      ? allCategories
                      : allCategories
                            .where(
                              (CategoryRow c) => allowedKeys.contains(c.key),
                            )
                            .toList();
                  final List<CategoryRow> visible = filtered.isEmpty
                      ? allCategories
                      : filtered;

                  return Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: visible.map((CategoryRow c) {
                      final bool selected = c.key == _categoryKey;
                      return _Chip(
                        label: c.displayName,
                        selected: selected,
                        onTap: () => setState(() {
                          _categoryKey = c.key;
                          _categoryTouchedByUser = true;
                        }),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: Space.lg),
              if (_categoryKey != null)
                _EnvelopePreview(
                  categoryKey: _categoryKey!,
                  amount: Money.tryParse(_amountController.text),
                  direction: _direction,
                ),
              const SizedBox(height: Space.xl),
              GlassButton(
                label: _saving ? 'SAVING...' : 'LOG IT',
                expand: true,
                onPressed: _saving || _categoryKey == null || _accountId == null
                    ? null
                    : () => _save(today),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DirectionToggle extends StatelessWidget {
  const _DirectionToggle({required this.direction, required this.onChanged});

  final TxnDirection direction;
  final ValueChanged<TxnDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _Chip(
            label: 'EXPENSE',
            selected: direction == TxnDirection.moneyOut,
            onTap: () => onChanged(TxnDirection.moneyOut),
            expand: true,
            color: BaonColors.risky,
          ),
        ),
        const SizedBox(width: Space.sm),
        Expanded(
          child: _Chip(
            label: 'INCOME',
            selected: direction == TxnDirection.moneyIn,
            onTap: () => onChanged(TxnDirection.moneyIn),
            expand: true,
            color: BaonColors.safe,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.expand = false,
    this.color = BaonColors.ink,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassChoice(
      label: label,
      selected: selected,
      onTap: onTap,
      expand: expand,
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

/// Shows which envelope this will hit and what it leaves behind, before the
/// user commits. Ties the form back to the envelope system rather than
/// treating the category as a label with no consequence.
///
/// Reads [envelopePreviewProvider], a cached `family` provider, rather than
/// calling the repository directly inside `build()`. This widget's parent
/// rebuilds often — it watches several providers that resolve at different
/// times — and a raw `FutureBuilder` given a freshly created `Future` on
/// every rebuild would keep resetting to "loading" and rarely get a chance
/// to show data.
class _EnvelopePreview extends ConsumerWidget {
  const _EnvelopePreview({
    required this.categoryKey,
    required this.amount,
    required this.direction,
  });

  final String categoryKey;
  final Money? amount;
  final TxnDirection direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> preview = ref.watch(
      envelopePreviewProvider(categoryKey),
    );
    final AsyncValue<List<EnvelopeWithState>> envelopes = ref.watch(
      envelopesProvider,
    );
    final String? envelopeId = preview.valueOrNull;
    if (preview.hasValue && envelopeId == null) {
      return const GlassCard(
        color: BaonColors.tightSoft,
        child: Text(
          'No envelope covers this category yet. It will not be tracked '
          'toward any forecast.',
          style: BaonType.bodyMuted,
        ),
      );
    }
    if (envelopeId == null) {
      return const SizedBox.shrink();
    }

    final EnvelopeWithState? envelope = envelopes.valueOrNull
        ?.where((EnvelopeWithState e) => e.id == envelopeId)
        .firstOrNull;
    if (envelope == null) {
      return const SizedBox.shrink();
    }

    final Money delta = amount == null
        ? Money.zero
        : (direction == TxnDirection.moneyOut ? -amount! : amount!);
    final Money after = envelope.balance + delta;

    return GlassCard(
      color: MascotPalette.forSeed(envelope.label).pane,
      child: Row(
        children: <Widget>[
          Mascot(
            seed: envelope.label,
            mood: envelope.shape == EnvelopeShape.reserve
                ? MascotMood.sleepy
                : MascotMood.happy,
            size: 48,
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              'Comes out of ${envelope.label}, leaving ${after.format()}.',
              style: BaonType.body,
            ),
          ),
        ],
      ),
    );
  }
}
