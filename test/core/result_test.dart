import 'package:baon/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Result<int> ok = Result<int>.ok(7);
  const Result<int> err = Result<int>.err('too small');

  test('reports which case it holds', () {
    expect(ok.isOk, isTrue);
    expect(ok.isErr, isFalse);
    expect(err.isErr, isTrue);
    expect(err.isOk, isFalse);
  });

  test('exposes the value or the message, never both', () {
    expect(ok.valueOrNull, 7);
    expect(ok.errorOrNull, isNull);
    expect(err.valueOrNull, isNull);
    expect(err.errorOrNull, 'too small');
  });

  test('valueOr falls back only on failure', () {
    expect(ok.valueOr(0), 7);
    expect(err.valueOr(0), 0);
  });

  test('map transforms a success and passes a failure through', () {
    expect(ok.map((int v) => v * 2), const Ok<int>(14));
    expect(err.map((int v) => v * 2), const Err<int>('too small'));
  });

  test('flatMap chains a second failable step', () {
    expect(
      ok.flatMap((int v) => Result<String>.ok('$v')),
      const Ok<String>('7'),
    );
    expect(
      ok.flatMap((int v) => const Result<String>.err('second step failed')),
      const Err<String>('second step failed'),
    );
    expect(
      err.flatMap((int v) => Result<String>.ok('$v')),
      const Err<String>('too small'),
      reason: 'a failure must short-circuit the chain',
    );
  });

  test('fold collapses both cases', () {
    expect(ok.fold((int v) => 'got $v', (String m) => 'failed: $m'), 'got 7');
    expect(
      err.fold((int v) => 'got $v', (String m) => 'failed: $m'),
      'failed: too small',
    );
  });

  test('carries a cause that never reaches the user message', () {
    final Exception boom = Exception('disk full');
    final Result<int> failure = Result<int>.err('could not save', cause: boom);
    expect(failure.errorOrNull, 'could not save');
    expect((failure as Err<int>).cause, boom);
    expect(failure.toString(), 'Err(could not save)');
  });

  test('equality follows the payload', () {
    expect(const Ok<int>(7), const Ok<int>(7));
    expect(const Ok<int>(7) == const Ok<int>(8), isFalse);
    expect(const Err<int>('a'), const Err<int>('a'));
    expect(const Err<int>('a') == const Err<int>('b'), isFalse);
    expect(const Ok<int>(7).hashCode, const Ok<int>(7).hashCode);
    expect(const Err<int>('a').hashCode, const Err<int>('a').hashCode);
    expect(const Ok<int>(7).toString(), 'Ok(7)');
  });
}
