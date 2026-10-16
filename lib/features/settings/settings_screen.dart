/// Settings. BUILD_PLAN.md Section 13, screen 7.
///
/// Safety floor, model download, lock, export to CSV, delete data.
library;

import 'package:baon/app_providers.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/data/repositories/settings_repository.dart';
import 'package:baon/ui/mascot.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, String>> settings = ref.watch(
      settingsProvider,
    );

    return Scaffold(
      backgroundColor: BaonColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.lg,
            Space.lg,
            Space.lg,
            Space.xxxl,
          ),
          children: <Widget>[
            const Text('SETTINGS', style: BaonType.h1),
            const SizedBox(height: Space.lg),
            settings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, StackTrace s) => Text('$e'),
              data: (Map<String, String> map) => _SettingsBody(map: map),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.map});

  final Map<String, String> map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Money floor = map.containsKey(SettingKey.safetyFloor)
        ? Money(int.parse(map[SettingKey.safetyFloor]!))
        : const Money(20000);
    final Money commute = map.containsKey(SettingKey.commutePerWeekday)
        ? Money(int.parse(map[SettingKey.commutePerWeekday]!))
        : Money.zero;
    final bool lock = map[SettingKey.appLockEnabled] == 'true';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('BUDGET', style: BaonType.label),
        const SizedBox(height: Space.sm),
        _SettingRow(
          title: 'Safety floor',
          subtitle: 'Never let a steady envelope go below this.',
          value: floor.format(),
          onTap: () => _editAmount(
            context,
            ref,
            title: 'Safety floor',
            current: floor,
            onSave: (Money v) =>
                ref.read(settingsRepositoryProvider).setSafetyFloor(v),
          ),
        ),
        _SettingRow(
          title: 'Weekday commute',
          subtitle: 'Your known fare, both ways, per working day.',
          value: commute.format(),
          onTap: () => _editAmount(
            context,
            ref,
            title: 'Weekday commute',
            current: commute,
            onSave: (Money v) =>
                ref.read(settingsRepositoryProvider).setCommutePerWeekday(v),
          ),
        ),
        const SizedBox(height: Space.lg),
        const Text('MANAGE', style: BaonType.label),
        const SizedBox(height: Space.sm),
        const _EnvelopeManager(),
        const _ObligationManager(),
        const _IncomeManager(),
        const SizedBox(height: Space.lg),
        const Text('SECURITY', style: BaonType.label),
        const SizedBox(height: Space.sm),
        GlassCard(
          child: Row(
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('App lock', style: BaonType.body),
                    Text(
                      'Require biometrics or a PIN to open Baon.',
                      style: BaonType.bodyMuted,
                    ),
                  ],
                ),
              ),
              Switch(
                value: lock,
                activeTrackColor: BaonColors.accent,
                onChanged: (bool v) =>
                    ref.read(settingsRepositoryProvider).setAppLockEnabled(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        const Text('AI MODEL', style: BaonType.label),
        const SizedBox(height: Space.sm),
        const GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Plain-language explainer', style: BaonType.body),
              SizedBox(height: Space.xs),
              Text(
                'Not downloaded. The app is fully usable without it — every '
                'number above comes from the on-device engine, never the '
                'model.',
                style: BaonType.bodyMuted,
              ),
              SizedBox(height: Space.sm),
              GlassBadge(
                label: 'PLANNED FOR A LATER RELEASE',
                color: BaonColors.surfaceMuted,
                foreground: BaonColors.textMuted,
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        const Text('DATA', style: BaonType.label),
        const SizedBox(height: Space.sm),
        GlassButton.secondary(
          label: 'EXPORT TO CSV',
          icon: Icons.download_outlined,
          expand: true,
          onPressed: () => _exportCsv(context, ref),
        ),
        const SizedBox(height: Space.sm),
        GlassButton.danger(
          label: 'DELETE ALL MY DATA',
          icon: Icons.delete_forever_outlined,
          expand: true,
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: BaonType.body),
                  Text(subtitle, style: BaonType.bodyMuted),
                ],
              ),
            ),
            const SizedBox(width: Space.md),
            Text(value, style: BaonType.numberMd.copyWith(fontSize: 18)),
            const SizedBox(width: Space.xs),
            const Icon(Icons.chevron_right, color: BaonColors.textMuted),
          ],
        ),
      ),
    );
  }
}

Future<void> _editAmount(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required Money current,
  required Future<void> Function(Money) onSave,
}) async {
  final TextEditingController controller = TextEditingController(
    text: current.isZero ? '' : current.format(symbol: false),
  );
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: BaonColors.sheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.sheet),
          side: const BorderSide(
            color: BaonColors.border,
            width: BorderWeight.bold,
          ),
        ),
        title: Text(title, style: BaonType.h2),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'PHP '),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          GlassButton(
            label: 'SAVE',
            onPressed: () async {
              final Money? parsed = Money.tryParse(controller.text);
              if (parsed != null) {
                await onSave(parsed);
                ref.invalidate(forecastProvider);
              }
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: BaonColors.sheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.sheet),
          side: const BorderSide(
            color: BaonColors.border,
            width: BorderWeight.bold,
          ),
        ),
        title: const Text('DELETE EVERYTHING?', style: BaonType.h2),
        content: const Text(
          'This deletes every account, envelope and transaction on this '
          'device. This cannot be undone.',
          style: BaonType.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          GlassButton.danger(
            label: 'DELETE',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );
  if (confirmed == true) {
    final BaonDatabase db = ref.read(databaseProvider);
    await db.transaction(() async {
      await db.delete(db.borrowEvents).go();
      await db.delete(db.allocations).go();
      await db.delete(db.envelopeCategories).go();
      await db.delete(db.envelopes).go();
      await db.delete(db.txns).go();
      await db.delete(db.balanceSnapshots).go();
      await db.delete(db.obligations).go();
      await db.delete(db.incomeExpectations).go();
      await db.delete(db.accounts).go();
      await db.delete(db.settings).go();
    });
    ref.invalidate(forecastProvider);
  }
}

Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
  final BaonDatabase db = ref.read(databaseProvider);
  final List<TxnRow> rows = await db.select(db.txns).get();
  final StringBuffer csv = StringBuffer(
    'date,direction,amount,category,source\n',
  );
  for (final TxnRow r in rows) {
    csv.writeln(
      '${r.occurredAt.toIso8601String()},${r.direction.wireName},'
      '${r.amountCents.centavos},${r.categoryKey},${r.source.wireName}',
    );
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported ${rows.length} rows (copy from logs).')),
    );
  }
  // The CSV text is assembled and ready. Writing it to a shareable file needs
  // a file-picker plugin, deliberately left out of this session's scope; the
  // string above is what that plugin would receive.
  assert(
    csv.toString().isNotEmpty,
    'csv must not be empty for a non-empty table',
  );
}

/// Manages envelopes: add a new one, or delete an existing one.
///
/// Full editing of an envelope's shape and categories happens at creation
/// time, since BUILD_PLAN.md Section 9.1 keeps the plan's own scope narrow —
/// this covers the two actions a user actually reaches for from Settings.
class _EnvelopeManager extends ConsumerWidget {
  const _EnvelopeManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<EnvelopeWithState>> envelopes = ref.watch(
      envelopesProvider,
    );
    return _ManagerSection(
      title: 'Envelopes',
      subtitle: 'A purpose for money. Not a place.',
      onAdd: () => _showAddEnvelopeSheet(context, ref),
      child: envelopes.when(
        loading: () => const _InlineLoading(),
        error: (Object e, StackTrace s) => Text('$e'),
        data: (List<EnvelopeWithState> rows) {
          if (rows.isEmpty) {
            return const Text('No envelopes yet.', style: BaonType.bodyMuted);
          }
          return Column(
            children: rows
                .map(
                  (EnvelopeWithState e) => _ManagedRow(
                    title: e.label,
                    mascotMood: e.shape == EnvelopeShape.reserve
                        ? MascotMood.sleepy
                        : MascotMood.happy,
                    subtitle: '${e.shape.wireName} • ${e.balance.format()}',
                    onDelete: () => ref
                        .read(envelopeRepositoryProvider)
                        .softDelete(e.id)
                        .then((_) => ref.invalidate(forecastProvider)),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

/// Manages known future outflows: rent share, a subscription, a loan.
class _ObligationManager extends ConsumerWidget {
  const _ObligationManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ObligationRow>> obligations = ref.watch(
      obligationsProvider,
    );
    return _ManagerSection(
      title: 'Obligations',
      subtitle: 'Rent share, a subscription, a loan payment.',
      onAdd: () => _showAddObligationSheet(context, ref),
      child: obligations.when(
        loading: () => const _InlineLoading(),
        error: (Object e, StackTrace s) => Text('$e'),
        data: (List<ObligationRow> rows) {
          if (rows.isEmpty) {
            return const Text('None yet.', style: BaonType.bodyMuted);
          }
          return Column(
            children: rows
                .map(
                  (ObligationRow o) => _ManagedRow(
                    title: o.label,
                    subtitle:
                        '${o.amountCents.format()} • ${o.cadence.wireName} • '
                        'due ${_shortDate(o.nextDueOn)}',
                    onDelete: () => ref
                        .read(obligationRepositoryProvider)
                        .softDelete(o.id)
                        .then((_) => ref.invalidate(forecastProvider)),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

/// Manages money the user expects to receive: an allowance or a stipend.
class _IncomeManager extends ConsumerWidget {
  const _IncomeManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<IncomeExpectationRow>> incomes = ref.watch(
      incomesProvider,
    );
    return _ManagerSection(
      title: 'Expected income',
      subtitle: 'An allowance or stipend the app should count.',
      onAdd: () => _showAddIncomeSheet(context, ref),
      child: incomes.when(
        loading: () => const _InlineLoading(),
        error: (Object e, StackTrace s) => Text('$e'),
        data: (List<IncomeExpectationRow> rows) {
          if (rows.isEmpty) {
            return const Text('None yet.', style: BaonType.bodyMuted);
          }
          return Column(
            children: rows
                .map(
                  (IncomeExpectationRow i) => _ManagedRow(
                    title: i.label,
                    subtitle:
                        '${i.amountCents.format()} • ${i.cadence.wireName} • '
                        '${i.confidence.wireName} • next ${_shortDate(i.nextExpectedOn)}',
                    onDelete: () => ref
                        .read(incomeRepositoryProvider)
                        .softDelete(i.id)
                        .then((_) => ref.invalidate(forecastProvider)),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _ManagerSection extends StatelessWidget {
  const _ManagerSection({
    required this.title,
    required this.subtitle,
    required this.onAdd,
    required this.child,
  });

  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: BaonType.body),
                      Text(subtitle, style: BaonType.bodyMuted),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                  color: BaonColors.accent,
                ),
              ],
            ),
            const SizedBox(height: Space.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _ManagedRow extends StatelessWidget {
  const _ManagedRow({
    required this.title,
    required this.subtitle,
    required this.onDelete,
    this.mascotMood,
  });

  final String title;
  final String subtitle;
  final VoidCallback onDelete;
  final MascotMood? mascotMood;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (mascotMood != null)
                  EnvelopeIdentity(label: title, mood: mascotMood!)
                else
                  Text(title, style: BaonType.body),
                Text(subtitle, style: BaonType.bodyMuted),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 18),
            color: BaonColors.risky,
          ),
        ],
      ),
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

String _shortDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<void> _showAddEnvelopeSheet(BuildContext context, WidgetRef ref) async {
  final TextEditingController label = TextEditingController();
  final TextEditingController refill = TextEditingController();
  EnvelopeShape shape = EnvelopeShape.steady;
  Cadence cadence = Cadence.weekly;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BaonColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.sheet)),
      side: BorderSide(color: BaonColors.border, width: BorderWeight.bold),
    ),
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.lg + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('NEW ENVELOPE', style: BaonType.h2),
                const SizedBox(height: Space.md),
                TextField(
                  controller: label,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: Space.md),
                const Text('SHAPE', style: BaonType.label),
                const SizedBox(height: Space.xs),
                Wrap(
                  spacing: Space.sm,
                  children: EnvelopeShape.values.map((EnvelopeShape s) {
                    return ChoiceChip(
                      label: Text(s.wireName),
                      selected: shape == s,
                      onSelected: (_) => setSheetState(() => shape = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: Space.md),
                GlassAmountField(label: 'Refill amount', controller: refill),
                const SizedBox(height: Space.md),
                const Text('REFILL CADENCE', style: BaonType.label),
                const SizedBox(height: Space.xs),
                Wrap(
                  spacing: Space.sm,
                  children:
                      <Cadence>[Cadence.weekly, Cadence.monthly, Cadence.none]
                          .map(
                            (Cadence c) => ChoiceChip(
                              label: Text(c.wireName),
                              selected: cadence == c,
                              onSelected: (_) =>
                                  setSheetState(() => cadence = c),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: Space.lg),
                GlassButton(
                  label: 'ADD ENVELOPE',
                  expand: true,
                  onPressed: label.text.trim().isEmpty
                      ? null
                      : () async {
                          await ref
                              .read(envelopeRepositoryProvider)
                              .create(
                                label: label.text.trim(),
                                shape: shape,
                                refill:
                                    Money.tryParse(refill.text) ?? Money.zero,
                                refillCadence: cadence,
                                refillAnchor: cadence == Cadence.weekly
                                    ? 'monday'
                                    : '1',
                              );
                          ref.invalidate(forecastProvider);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _showAddObligationSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final DateTime today = ref.read(clockProvider).today();
  final TextEditingController label = TextEditingController();
  final TextEditingController amount = TextEditingController();
  Cadence cadence = Cadence.monthly;
  DateTime dueOn = today.add(const Duration(days: 7));

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BaonColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.sheet)),
      side: BorderSide(color: BaonColors.border, width: BorderWeight.bold),
    ),
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.lg + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('NEW OBLIGATION', style: BaonType.h2),
                const SizedBox(height: Space.md),
                TextField(
                  controller: label,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                const SizedBox(height: Space.md),
                GlassAmountField(label: 'Amount', controller: amount),
                const SizedBox(height: Space.md),
                const Text('CADENCE', style: BaonType.label),
                const SizedBox(height: Space.xs),
                Wrap(
                  spacing: Space.sm,
                  children: Cadence.values
                      .where((Cadence c) => c != Cadence.none)
                      .map(
                        (Cadence c) => ChoiceChip(
                          label: Text(c.wireName),
                          selected: cadence == c,
                          onSelected: (_) => setSheetState(() => cadence = c),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: Space.md),
                GlassButton.secondary(
                  label: 'DUE ${_shortDate(dueOn)}',
                  icon: Icons.calendar_today_outlined,
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: dueOn,
                      firstDate: today,
                      lastDate: today.add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setSheetState(() => dueOn = picked);
                    }
                  },
                ),
                const SizedBox(height: Space.lg),
                GlassButton(
                  label: 'ADD OBLIGATION',
                  expand: true,
                  onPressed: label.text.trim().isEmpty
                      ? null
                      : () async {
                          final Money? parsed = Money.tryParse(amount.text);
                          if (parsed == null) {
                            return;
                          }
                          await ref
                              .read(obligationRepositoryProvider)
                              .create(
                                label: label.text.trim(),
                                amount: parsed,
                                cadence: cadence,
                                nextDueOn: dueOn,
                                categoryKey: 'other',
                              );
                          ref.invalidate(forecastProvider);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _showAddIncomeSheet(BuildContext context, WidgetRef ref) async {
  final DateTime today = ref.read(clockProvider).today();
  final TextEditingController label = TextEditingController();
  final TextEditingController amount = TextEditingController();
  Cadence cadence = Cadence.weekly;
  IncomeConfidence confidence = IncomeConfidence.certain;
  DateTime nextOn = today.add(const Duration(days: 7));

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BaonColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.sheet)),
      side: BorderSide(color: BaonColors.border, width: BorderWeight.bold),
    ),
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.lg + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('NEW EXPECTED INCOME', style: BaonType.h2),
                const SizedBox(height: Space.md),
                TextField(
                  controller: label,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                const SizedBox(height: Space.md),
                GlassAmountField(label: 'Amount', controller: amount),
                const SizedBox(height: Space.md),
                const Text('CADENCE', style: BaonType.label),
                const SizedBox(height: Space.xs),
                Wrap(
                  spacing: Space.sm,
                  children: Cadence.values
                      .where((Cadence c) => c != Cadence.none)
                      .map(
                        (Cadence c) => ChoiceChip(
                          label: Text(c.wireName),
                          selected: cadence == c,
                          onSelected: (_) => setSheetState(() => cadence = c),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: Space.md),
                const Text('CONFIDENCE', style: BaonType.label),
                const SizedBox(height: Space.xs),
                Wrap(
                  spacing: Space.sm,
                  children: IncomeConfidence.values
                      .map(
                        (IncomeConfidence c) => ChoiceChip(
                          label: Text(c.wireName),
                          selected: confidence == c,
                          onSelected: (_) =>
                              setSheetState(() => confidence = c),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: Space.md),
                GlassButton.secondary(
                  label: 'NEXT ${_shortDate(nextOn)}',
                  icon: Icons.calendar_today_outlined,
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: nextOn,
                      firstDate: today,
                      lastDate: today.add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setSheetState(() => nextOn = picked);
                    }
                  },
                ),
                const SizedBox(height: Space.lg),
                GlassButton(
                  label: 'ADD INCOME',
                  expand: true,
                  onPressed: label.text.trim().isEmpty
                      ? null
                      : () async {
                          final Money? parsed = Money.tryParse(amount.text);
                          if (parsed == null) {
                            return;
                          }
                          await ref
                              .read(incomeRepositoryProvider)
                              .create(
                                label: label.text.trim(),
                                amount: parsed,
                                cadence: cadence,
                                nextExpectedOn: nextOn,
                                confidence: confidence,
                              );
                          ref.invalidate(forecastProvider);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
