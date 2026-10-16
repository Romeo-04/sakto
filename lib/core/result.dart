/// A success-or-failure value, used where a caller must handle the failure.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

/// The outcome of an operation that can fail in an expected way.
///
/// Use this for failures the user can act on, such as a rejected amount or a
/// broken envelope invariant. Keep `throw` for programmer errors.
sealed class Result<T> {
  const Result();

  /// A success carrying [value].
  const factory Result.ok(T value) = Ok<T>;

  /// A failure carrying a [message] the user can read.
  const factory Result.err(String message, {Object? cause}) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// The value on success, or null on failure.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final T value) => value,
    Err<T>() => null,
  };

  /// The message on failure, or null on success.
  String? get errorOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final String message) => message,
  };

  /// The value on success, or [fallback] on failure.
  T valueOr(T fallback) => valueOrNull ?? fallback;

  /// Applies [transform] to a success value, passing a failure through.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final T value) => Ok<R>(transform(value)),
    Err<T>(:final String message, :final Object? cause) => Err<R>(
      message,
      cause: cause,
    ),
  };

  /// Chains another failable step onto a success, passing a failure through.
  Result<R> flatMap<R>(Result<R> Function(T value) next) => switch (this) {
    Ok<T>(:final T value) => next(value),
    Err<T>(:final String message, :final Object? cause) => Err<R>(
      message,
      cause: cause,
    ),
  };

  /// Collapses both cases into one value.
  R fold<R>(R Function(T value) onOk, R Function(String message) onErr) =>
      switch (this) {
        Ok<T>(:final T value) => onOk(value),
        Err<T>(:final String message) => onErr(message),
      };
}

/// A successful [Result].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  String toString() => 'Ok($value)';

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// A failed [Result]. [message] is safe to show to the user.
final class Err<T> extends Result<T> {
  const Err(this.message, {this.cause});

  final String message;

  /// The underlying exception, when there was one. Never shown to the user.
  final Object? cause;

  @override
  String toString() => 'Err($message)';

  @override
  bool operator ==(Object other) =>
      other is Err<T> && other.message == message && other.cause == cause;

  @override
  int get hashCode => Object.hash(message, cause);
}
