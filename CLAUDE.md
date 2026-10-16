# Baon — Agent Instructions

## Rules
- Money is `int` centavos. Never use `double` for money. Use `lib/core/money.dart`.
- `lib/engine/` is pure Dart. It must not import Flutter or any plugin.
- Never call `DateTime.now()` outside `core/clock.dart`. Inject the clock.
- The language model never computes a number. See BUILD_PLAN.md Section 2.
- Write the test before the engine function.
- Do not add a package without a note in the pull request that explains why.

## Commands
- Test: `flutter test`
- Analyse: `flutter analyze`
- Format: `dart format .`
- Run: `flutter run -d windows`
- Regenerate the database code: `dart run build_runner build --force-jit`
  `--force-jit` is required. `sqlite3` ships native build hooks and
  `dart compile` rejects them, so the AOT path fails. `pubspec.yaml` also
  pins `sqlite3` for the same reason.

## Definition of done
1. `flutter analyze` reports zero issues.
2. `flutter test` passes.
3. New engine logic has a test.
4. No balance value appears in any log statement.

`test/architecture_test.dart` enforces rules 2, 3 and 4 of the Rules list
automatically. Do not weaken it to make a change pass.

## Order of work
Follow the milestones M0 to M11 in BUILD_PLAN.md. Do not skip ahead.
Stop and ask before you change the engine output schema in Section 8.8.

## Environment notes
- There is no Android SDK on this machine. Verify with `flutter run -d windows`.
- SQLCipher is not yet wired in. `lib/data/db/connection.dart` holds the single
  seam where the cipher key is applied. See the note in that file.
