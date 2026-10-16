import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/balance_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/data/repositories/income_repository.dart';
import 'package:baon/data/repositories/obligation_repository.dart';
import 'package:baon/data/repositories/settings_repository.dart';
import 'package:baon/engine/engine.dart';
import 'package:baon/engine/envelope.dart' as engine;
import 'package:baon/engine/monte_carlo.dart' show defaultRuns;
import 'package:drift/drift.dart';

/// Assembles an [engine.EngineInput] from every repository and runs the
/// forecast.
///
/// This is the one place outside `lib/engine/` that is allowed to know how
/// database rows map onto engine types. Screens ask this repository for a
/// [ForecastResult]; they never touch the engine's `runForecast` directly.
class ForecastRepository {
  ForecastRepository({
    required BaonDatabase db,
    required Clock clock,
    required AccountRepository accounts,
    required EnvelopeRepository envelopes,
    required BalanceRepository balances,
    required ObligationRepository obligations,
    required IncomeRepository incomes,
    required SettingsRepository settings,
  }) : _db = db,
       _clock = clock,
       _accounts = accounts,
       _envelopes = envelopes,
       _balances = balances,
       _obligations = obligations,
       _incomes = incomes,
       _settings = settings;

  final BaonDatabase _db;
  final Clock _clock;
  final AccountRepository _accounts;
  final EnvelopeRepository _envelopes;
  final BalanceRepository _balances;
  final ObligationRepository _obligations;
  final IncomeRepository _incomes;
  final SettingsRepository _settings;

  /// Builds the full engine input from every table and runs the forecast.
  Future<ForecastResult> buildForecast({int runs = defaultRuns}) async {
    final DateTime asOf = _clock.today();

    final List<EnvelopeWithState> envelopeRows = await _envelopes
        .envelopesWithState();
    final Money accountTotal = await _accounts.accountTotal();
    final EnvelopeTotals totals = await _envelopes.totals(accountTotal);
    final List<AccountWithBalance> stale = await _balances.staleAccounts();
    final DateTime? earliest = await _balances.earliestSnapshotAt();
    final Money commute = await _settings.commutePerWeekday();
    final Money floor = await _settings.safetyFloor();

    final List<ObligationRow> obligationRows = await _obligations.active();
    final List<IncomeExpectationRow> incomeRows = await _incomes.active();

    final List<engine.EngineObligation> engineObligations = obligationRows
        .map(
          (ObligationRow o) => engine.EngineObligation(
            label: o.label,
            amount: o.amountCents,
            cadence: o.cadence,
            nextDueOn: o.nextDueOn,
            categoryKey: o.categoryKey,
          ),
        )
        .toList(growable: false);

    final List<engine.EngineIncome> engineIncomes = incomeRows
        .map(
          (IncomeExpectationRow i) => engine.EngineIncome(
            label: i.label,
            amount: i.amountCents,
            cadence: i.cadence,
            nextExpectedOn: i.nextExpectedOn,
            confidence: i.confidence,
          ),
        )
        .toList(growable: false);

    final List<engine.EngineEnvelope> engineEnvelopes =
        <engine.EngineEnvelope>[];
    for (final EnvelopeWithState e in envelopeRows) {
      final bool isFirstSteady =
          e.shape == EnvelopeShape.steady &&
          envelopeRows
                  .where(
                    (EnvelopeWithState x) => x.shape == EnvelopeShape.steady,
                  )
                  .firstOrNull
                  ?.id ==
              e.id;
      engineEnvelopes.add(
        engine.EngineEnvelope(
          id: e.id,
          label: e.label,
          shape: e.shape,
          balance: e.balance,
          refill: e.envelope.refillCents,
          refillCadence: e.envelope.refillCadence,
          categoryKeys: e.categoryKeys,
          allowBorrowFrom: e.envelope.allowBorrowFrom,
          priority: e.envelope.priority,
          safetyFloor: e.shape == EnvelopeShape.steady ? floor : Money.zero,
          commute: isFirstSteady
              ? engine.CommuteCost(perWeekday: commute)
              : engine.CommuteCost.none,
        ),
      );
    }

    final List<engine.EngineTxn> txns = await _readEngineTxns(earliest, asOf);

    final engine.EngineInput input = engine.EngineInput(
      asOf: asOf,
      envelopes: engineEnvelopes,
      txns: txns,
      obligations: engineObligations,
      incomes: engineIncomes,
      accountTotal: accountTotal,
      unallocated: totals.unallocated,
      staleAccountLabels: stale
          .map((AccountWithBalance a) => a.account.label)
          .toList(growable: false),
      historyStartedOn: earliest,
    );

    return runForecast(input, runs: runs);
  }

  /// Reads every non-deleted transaction from the earliest history date, as
  /// plain engine objects.
  Future<List<engine.EngineTxn>> _readEngineTxns(
    DateTime? historyStartedOn,
    DateTime asOf,
  ) async {
    final DateTime from = historyStartedOn ?? asOf;
    final List<TxnRow> rows =
        await (_db.select(_db.txns)
              ..where(($TxnsTable t) => t.deletedAt.isNull())
              ..where(
                ($TxnsTable t) => t.occurredAt.isBiggerOrEqualValue(from),
              ))
            .get();
    return rows
        .map(
          (TxnRow r) => engine.EngineTxn(
            amount: r.amountCents,
            direction: r.direction,
            categoryKey: r.categoryKey,
            occurredAt: r.occurredAt,
          ),
        )
        .toList(growable: false);
  }
}
