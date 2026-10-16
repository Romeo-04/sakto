import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/reconciler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SnapshotPoint at(int day, int cents, {int hour = 8}) => SnapshotPoint(
    balance: Money(cents),
    capturedAt: DateTime.utc(2026, 9, day, hour),
  );

  LoggedTxn spend(int day, int cents) => LoggedTxn(
    amount: Money(cents),
    direction: TxnDirection.moneyOut,
    occurredAt: DateTime.utc(2026, 9, day, 12),
  );

  LoggedTxn receive(int day, int cents) => LoggedTxn(
    amount: Money(cents),
    direction: TxnDirection.moneyIn,
    occurredAt: DateTime.utc(2026, 9, day, 12),
  );

  ReconcileResult run({
    SnapshotPoint? previous,
    required SnapshotPoint current,
    List<LoggedTxn> logged = const <LoggedTxn>[],
  }) => reconcile(
    accountId: 'acc_1',
    previous: previous,
    current: current,
    logged: logged,
  );

  group('first ever snapshot', () {
    test('derives nothing, because there is nothing to compare', () {
      final ReconcileResult r = run(previous: null, current: at(1, 500000));
      expect(r.hasDerivedTxn, isFalse);
      expect(r.delta, Money.zero);
      expect(r.expected, const Money(500000));
      expect(r.actual, const Money(500000));
    });
  });

  group('unexplained spending', () {
    test('books an outflow when the balance dropped more than expected', () {
      final ReconcileResult r = run(
        previous: at(1, 500000),
        current: at(3, 420000),
      );
      expect(r.delta, const Money(-80000));
      expect(r.derived!.direction, TxnDirection.moneyOut);
      expect(r.derived!.amount, const Money(80000));
      expect(
        r.derived!.amount.isNegative,
        isFalse,
        reason: 'BUILD_PLAN.md Section 7: txn amounts are always positive',
      );
    });

    test('subtracts the logged spending before deciding', () {
      final ReconcileResult r = run(
        previous: at(1, 500000),
        current: at(3, 420000),
        logged: <LoggedTxn>[spend(2, 50000)],
      );
      expect(r.expected, const Money(450000));
      expect(r.delta, const Money(-30000));
      expect(r.derived!.amount, const Money(30000));
    });

    test('places the derived item at the midpoint of the gap', () {
      final ReconcileResult r = run(
        previous: at(1, 500000),
        current: at(5, 400000),
      );
      expect(r.derived!.occurredAt, DateTime.utc(2026, 9, 3, 8));
      expect(r.derived!.occurredAt.isUtc, isTrue);
    });

    test('carries the account id through', () {
      final ReconcileResult r = run(
        previous: at(1, 500000),
        current: at(3, 400000),
      );
      expect(r.derived!.accountId, 'acc_1');
    });
  });

  group('unexplained income', () {
    test('books an inflow when the balance rose more than expected', () {
      final ReconcileResult r = run(
        previous: at(1, 100000),
        current: at(3, 350000),
      );
      expect(r.delta, const Money(250000));
      expect(r.derived!.direction, TxnDirection.moneyIn);
      expect(r.derived!.amount, const Money(250000));
    });

    test('accounts for logged income first', () {
      final ReconcileResult r = run(
        previous: at(1, 100000),
        current: at(3, 350000),
        logged: <LoggedTxn>[receive(2, 200000)],
      );
      expect(r.expected, const Money(300000));
      expect(r.delta, const Money(50000));
      expect(r.derived!.direction, TxnDirection.moneyIn);
    });
  });

  group('tolerance', () {
    test('ignores a gap of one peso or less', () {
      expect(
        run(previous: at(1, 500000), current: at(3, 499900)).hasDerivedTxn,
        isFalse,
        reason: '100 centavos is exactly the tolerance',
      );
      expect(
        run(previous: at(1, 500000), current: at(3, 500100)).hasDerivedTxn,
        isFalse,
      );
      expect(
        run(previous: at(1, 500000), current: at(3, 500000)).hasDerivedTxn,
        isFalse,
      );
    });

    test('books a gap one centavo past the tolerance', () {
      final ReconcileResult r = run(
        previous: at(1, 500000),
        current: at(3, 499899),
      );
      expect(r.hasDerivedTxn, isTrue);
      expect(r.derived!.amount, const Money(101));
    });

    test('honours a custom tolerance', () {
      final ReconcileResult r = reconcile(
        accountId: 'acc_1',
        previous: at(1, 500000),
        current: at(3, 490000),
        logged: const <LoggedTxn>[],
        tolerance: const Money(20000),
      );
      expect(r.hasDerivedTxn, isFalse);
    });
  });

  group('the window', () {
    test('ignores a transaction from before the previous snapshot', () {
      final ReconcileResult r = run(
        previous: at(3, 500000),
        current: at(5, 500000),
        logged: <LoggedTxn>[spend(1, 90000)],
      );
      expect(
        r.expected,
        const Money(500000),
        reason: 'last week receipt must not distort this period',
      );
      expect(r.hasDerivedTxn, isFalse);
    });

    test('ignores a transaction dated after the new snapshot', () {
      final ReconcileResult r = run(
        previous: at(1, 500000),
        current: at(3, 500000),
        logged: <LoggedTxn>[spend(9, 90000)],
      );
      expect(r.expected, const Money(500000));
      expect(r.hasDerivedTxn, isFalse);
    });

    test('includes a transaction sitting exactly on either boundary', () {
      final ReconcileResult r = reconcile(
        accountId: 'acc_1',
        previous: at(1, 500000),
        current: at(3, 380000),
        logged: <LoggedTxn>[
          LoggedTxn(
            amount: const Money(60000),
            direction: TxnDirection.moneyOut,
            occurredAt: DateTime.utc(2026, 9, 1, 8),
          ),
          LoggedTxn(
            amount: const Money(60000),
            direction: TxnDirection.moneyOut,
            occurredAt: DateTime.utc(2026, 9, 3, 8),
          ),
        ],
      );
      expect(r.expected, const Money(380000));
      expect(r.hasDerivedTxn, isFalse);
    });
  });

  group('the balance always reconciles', () {
    test('logged plus derived equals the whole balance change', () {
      final SnapshotPoint previous = at(1, 500000);
      final SnapshotPoint current = at(6, 312500);
      final List<LoggedTxn> logged = <LoggedTxn>[
        spend(2, 45000),
        spend(3, 12000),
        receive(4, 20000),
      ];

      final ReconcileResult r = run(
        previous: previous,
        current: current,
        logged: logged,
      );

      final Money loggedSum = Money.sum(
        logged.map((LoggedTxn t) => t.signedAmount),
      );
      final Money derivedSum = r.derived?.signedAmount ?? Money.zero;

      expect(
        previous.balance + loggedSum + derivedSum,
        current.balance,
        reason: 'BUILD_PLAN.md Section 15 property test',
      );
    });

    test('holds across a run of random balance changes', () {
      // A deterministic sweep. Every gap size, positive and negative, must
      // leave the books balanced.
      for (int step = -500000; step <= 500000; step += 12345) {
        final SnapshotPoint previous = at(1, 500000);
        final SnapshotPoint current = at(3, 500000 + step);
        final ReconcileResult r = run(previous: previous, current: current);
        final Money derived = r.derived?.signedAmount ?? Money.zero;
        expect(
          previous.balance + derived,
          current.balance,
          reason: 'failed at step $step',
        );
      }
    });

    test('holds when a negative balance is reported', () {
      final ReconcileResult r = run(
        previous: at(1, 5000),
        current: at(3, -12000),
      );
      expect(r.derived!.direction, TxnDirection.moneyOut);
      expect(r.derived!.amount, const Money(17000));
      expect(const Money(5000) + r.derived!.signedAmount, const Money(-12000));
    });
  });
}
