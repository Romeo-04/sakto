/// Derives spending from a change in balance.
///
/// BUILD_PLAN.md Section 8.1. The user will not log every jeepney fare, so the
/// app must still know the spend rate. It compares the balance the user typed
/// against the balance the logged transactions predict, and books the gap.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';

/// A change in balance that no logged transaction explains.
///
/// The UI shows this as "Unaccounted" and invites the user to label it. Each
/// label becomes a training row for the categorizer.
class ReconciledDelta {
  const ReconciledDelta({
    required this.accountId,
    required this.amount,
    required this.direction,
    required this.occurredAt,
  });

  final String accountId;

  /// Always positive. [direction] carries the sign.
  final Money amount;
  final TxnDirection direction;

  /// Placed at the midpoint of the gap, because the exact moment is unknown.
  final DateTime occurredAt;

  /// The amount as a signed figure: negative for money out.
  Money get signedAmount =>
      direction == TxnDirection.moneyOut ? -amount : amount;
}

/// One logged movement of money, as the reconciler needs to see it.
class LoggedTxn {
  const LoggedTxn({
    required this.amount,
    required this.direction,
    required this.occurredAt,
  });

  /// Always positive.
  final Money amount;
  final TxnDirection direction;
  final DateTime occurredAt;

  Money get signedAmount =>
      direction == TxnDirection.moneyOut ? -amount : amount;
}

/// A balance the user reported, with the moment it was true.
class SnapshotPoint {
  const SnapshotPoint({required this.balance, required this.capturedAt});

  final Money balance;
  final DateTime capturedAt;
}

/// The result of comparing a new balance against the expected one.
class ReconcileResult {
  const ReconcileResult({
    required this.expected,
    required this.actual,
    required this.delta,
    required this.derived,
  });

  /// What the balance should have been, given the logged transactions.
  final Money expected;

  /// What the user actually reported.
  final Money actual;

  /// `actual - expected`. Negative means unexplained spending.
  final Money delta;

  /// The transaction to book, or null when the gap is inside the tolerance.
  final ReconciledDelta? derived;

  bool get hasDerivedTxn => derived != null;
}

/// Balance changes smaller than this are ignored as noise.
///
/// BUILD_PLAN.md Section 8.1 sets the tolerance at 100 centavos. Booking a
/// PHP 0.50 "Unaccounted" row would train the user to ignore the list.
const Money reconcileTolerance = Money(100);

/// Compares a new balance against the one the logged transactions predict.
///
/// [previous] is the last snapshot for the account, or null on the very first
/// entry. On a first entry there is nothing to compare against, so no
/// transaction is derived; the opening balance is simply a fact.
///
/// [logged] should hold the transactions for this account that fall inside the
/// window. Transactions outside the window are ignored, so a late-entered
/// receipt from last week cannot distort this period.
ReconcileResult reconcile({
  required String accountId,
  required SnapshotPoint? previous,
  required SnapshotPoint current,
  required List<LoggedTxn> logged,
  Money tolerance = reconcileTolerance,
}) {
  if (previous == null) {
    return ReconcileResult(
      expected: current.balance,
      actual: current.balance,
      delta: Money.zero,
      derived: null,
    );
  }

  final Money loggedSum = Money.sum(
    logged
        .where(
          (LoggedTxn t) =>
              !t.occurredAt.isBefore(previous.capturedAt) &&
              !t.occurredAt.isAfter(current.capturedAt),
        )
        .map((LoggedTxn t) => t.signedAmount),
  );

  final Money expected = previous.balance + loggedSum;
  final Money delta = current.balance - expected;

  if (delta.abs() <= tolerance) {
    return ReconcileResult(
      expected: expected,
      actual: current.balance,
      delta: delta,
      derived: null,
    );
  }

  return ReconcileResult(
    expected: expected,
    actual: current.balance,
    delta: delta,
    derived: ReconciledDelta(
      accountId: accountId,
      amount: delta.abs(),
      direction: delta.isNegative
          ? TxnDirection.moneyOut
          : TxnDirection.moneyIn,
      occurredAt: midpoint(previous.capturedAt, current.capturedAt),
    ),
  );
}
