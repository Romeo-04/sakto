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
- The Android SDK is at `%LOCALAPPDATA%\Android\Sdk` (command-line tools, no
  emulator, no device attached). Gradle needs Android Studio's Java:
  `JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"`. The global
  `JAVA_HOME` points at a placeholder path. Verify UI with
  `flutter run -d windows`.
- The database is encrypted with SQLCipher. `pubspec.yaml` selects it
  (`hooks: user_defines: sqlite3: source: sqlcipher`), and
  `lib/data/db/connection.dart` is the single seam that applies the key.
- After changing the `hooks:` section, run `flutter clean` before the next
  app build. A stale `sqlite3.dll` left in `build/` gets loaded instead of
  SQLCipher. The tests do not catch this; only a real app run does.
