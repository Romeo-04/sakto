/// Transactions. BUILD_PLAN.md Section 13, screen 6.
///
/// A list. "Unaccounted" items sit at the top and need a label.
library;

import 'package:baon/app_providers.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/features/transactions/add_transaction_screen.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TxnRow>> unaccounted = ref.watch(unaccountedProvider);
    final AsyncValue<List<TxnRow>> recent = ref.watch(recentTxnsProvider);

    return Scaffold(
      backgroundColor: BaonColors.paper,
      floatingActionButton: FloatingActionButton(
        backgroundColor: BaonColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.soft),
          side: const BorderSide(
            color: BaonColors.border,
            width: BorderWeight.bold,
          ),
        ),
        onPressed: () => showAddTransactionScreen(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.lg,
            Space.lg,
            Space.lg,
            Space.xxxl,
          ),
          children: <Widget>[
            const Text('ACTIVITY', style: BaonType.h1),
            const SizedBox(height: Space.lg),
            unaccounted.when(
              loading: () => const SizedBox.shrink(),
              error: (Object e, StackTrace s) => const SizedBox.shrink(),
              data: (List<TxnRow> rows) {
                if (rows.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Text('NEEDS A LABEL', style: BaonType.label),
                        const SizedBox(width: Space.xs),
                        GlassBadge(
                          label: '${rows.length}',
                          color: BaonColors.riskySoft,
                          foreground: BaonColors.risky,
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.sm),
                    for (final TxnRow t in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.sm),
                        child: _UnaccountedTile(txn: t),
                      ),
                    const SizedBox(height: Space.lg),
                  ],
                );
              },
            ),
            const Text('RECENT', style: BaonType.label),
            const SizedBox(height: Space.sm),
            recent.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(Space.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, StackTrace s) => Text('$e'),
              data: (List<TxnRow> rows) {
                final List<TxnRow> shown = rows
                    .where(
                      (TxnRow t) =>
                          t.source != TxnSource.reconciled || t.userCorrected,
                    )
                    .toList();
                if (shown.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    message: 'Spending will show up here as you go.',
                  );
                }
                return Column(
                  children: shown
                      .map(
                        (TxnRow t) => Padding(
                          padding: const EdgeInsets.only(bottom: Space.sm),
                          child: _TxnTile(txn: t),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UnaccountedTile extends ConsumerWidget {
  const _UnaccountedTile({required this.txn});

  final TxnRow txn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      color: BaonColors.tightSoft,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${txn.direction == TxnDirection.moneyOut ? '-' : '+'}'
                  '${txn.amountCents.format()}',
                  style: BaonType.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                Text(
                  'Unaccounted • ${_formatDate(txn.occurredAt)}',
                  style: BaonType.bodyMuted,
                ),
              ],
            ),
          ),
          GlassButton(
            label: 'LABEL',
            onPressed: () => _showLabelSheet(context, ref, txn),
          ),
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.txn});

  final TxnRow txn;

  @override
  Widget build(BuildContext context) {
    final bool out = txn.direction == TxnDirection.moneyOut;
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  txn.categoryKey.replaceAll('_', ' ').toUpperCase(),
                  style: BaonType.label,
                ),
                Text(_formatDate(txn.occurredAt), style: BaonType.bodyMuted),
              ],
            ),
          ),
          Text(
            '${out ? '-' : '+'}${txn.amountCents.format()}',
            style: BaonType.body.copyWith(
              fontWeight: FontWeight.w700,
              fontVariations: const [FontVariation('wght', 700)],
              color: out ? BaonColors.ink : BaonColors.safe,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<void> _showLabelSheet(
  BuildContext context,
  WidgetRef ref,
  TxnRow txn,
) async {
  final AsyncValue<List<CategoryRow>> categories = ref.read(categoriesProvider);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: BaonColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.sheet)),
      side: BorderSide(color: BaonColors.border, width: BorderWeight.bold),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: categories.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, StackTrace s) => Text('$e'),
            data: (List<CategoryRow> rows) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('WHAT WAS THIS?', style: BaonType.h2),
                  const SizedBox(height: Space.md),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: rows
                        .where((CategoryRow c) => c.key != 'other')
                        .map(
                          (CategoryRow c) => GlassChoice(
                            label: c.displayName,
                            selected: false,
                            onTap: () async {
                              await ref
                                  .read(txnRepositoryProvider)
                                  .relabel(txnId: txn.id, categoryKey: c.key);
                              ref.invalidate(forecastProvider);
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
