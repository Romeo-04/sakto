/// Update balances. BUILD_PLAN.md Section 13, screen 3.
///
/// A single list, one number field per account. This is the main daily
/// action and must stay under fifteen seconds.
library;

import 'package:baon/app_providers.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/balance_repository.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceEntryScreen extends ConsumerStatefulWidget {
  const BalanceEntryScreen({super.key});

  @override
  ConsumerState<BalanceEntryScreen> createState() => _BalanceEntryScreenState();
}

class _BalanceEntryScreenState extends ConsumerState<BalanceEntryScreen> {
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  bool _saving = false;

  TextEditingController _controllerFor(String accountId, Money current) {
    return _controllers.putIfAbsent(
      accountId,
      () => TextEditingController(
        text: current.isZero ? '' : current.format(symbol: false),
      ),
    );
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAll(List<AccountWithBalance> accounts) async {
    setState(() => _saving = true);
    try {
      final Map<String, Money> updates = <String, Money>{};
      for (final AccountWithBalance a in accounts) {
        final TextEditingController? c = _controllers[a.account.id];
        if (c == null || c.text.trim().isEmpty) {
          continue;
        }
        final Money? parsed = Money.tryParse(c.text);
        if (parsed == null) {
          continue;
        }
        updates[a.account.id] = parsed;
      }
      if (updates.isEmpty) {
        return;
      }
      final List<SavedBalance> results = await ref
          .read(balanceRepositoryProvider)
          .saveMany(updates);
      ref.invalidate(forecastProvider);

      if (!mounted) {
        return;
      }
      final int unaccounted = results
          .where((SavedBalance r) => r.createdUnaccounted)
          .length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unaccounted == 0
                ? 'Balances saved.'
                : 'Balances saved. $unaccounted item'
                      '${unaccounted == 1 ? '' : 's'} need${unaccounted == 1 ? 's' : ''} '
                      'a label in Activity.',
          ),
        ),
      );
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

    return Scaffold(
      backgroundColor: BaonColors.paper,
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('$e')),
        data: (List<AccountWithBalance> rows) {
          if (rows.isEmpty) {
            return const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No accounts yet',
              message: 'Add an account from Settings first.',
            );
          }
          return Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.lg,
                  Space.lg,
                  Space.md,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('UPDATE BALANCES', style: BaonType.h1),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Space.md),
                  itemBuilder: (BuildContext context, int i) {
                    final AccountWithBalance a = rows[i];
                    final bool stale = a.isStaleAt(
                      ref.read(clockProvider).nowUtc(),
                    );
                    return GlassCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(a.account.label, style: BaonType.body),
                                const SizedBox(height: 2),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Last: ${a.balance.format()}',
                                      style: BaonType.bodyMuted,
                                    ),
                                    if (stale) ...<Widget>[
                                      const SizedBox(width: Space.xs),
                                      const GlassBadge(
                                        label: 'STALE',
                                        color: BaonColors.tightSoft,
                                        foreground: BaonColors.tight,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Space.md),
                          SizedBox(
                            width: 164,
                            child: TextField(
                              controller: _controllerFor(
                                a.account.id,
                                a.balance,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.right,
                              style: BaonType.numberMd.copyWith(fontSize: 18),
                              decoration: const InputDecoration(
                                prefixText: 'PHP ',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: GlassButton(
                  label: _saving ? 'SAVING...' : 'SAVE ALL BALANCES',
                  expand: true,
                  onPressed: _saving ? null : () => _saveAll(rows),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
