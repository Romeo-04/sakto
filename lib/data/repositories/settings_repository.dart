import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';

/// Setting keys. Held as constants so a typo cannot silently create a second
/// setting under a slightly different name.
abstract final class SettingKey {
  static const String safetyFloor = 'safety_floor_cents';
  static const String commutePerWeekday = 'commute_per_weekday_cents';
  static const String appLockEnabled = 'app_lock_enabled';
  static const String horizonOverrideDays = 'horizon_override_days';
  static const String onboardingDone = 'onboarding_done';
}

/// A small key and value store for user preferences.
///
/// BUILD_PLAN.md Section 13, screen 7: safety floor, model download, lock,
/// export, delete. This repository holds the ones that are plain settings
/// rather than a whole table of their own.
class SettingsRepository {
  SettingsRepository(this._db);

  final BaonDatabase _db;

  Future<String?> _read(String key) async {
    final SettingRow? row = await (_db.select(
      _db.settings,
    )..where(($SettingsTable t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _write(String key, String value) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<Money> safetyFloor({Money fallback = const Money(20000)}) async {
    final String? raw = await _read(SettingKey.safetyFloor);
    if (raw == null) {
      return fallback;
    }
    return Money(int.parse(raw));
  }

  Future<void> setSafetyFloor(Money value) =>
      _write(SettingKey.safetyFloor, value.centavos.toString());

  Future<Money> commutePerWeekday() async {
    final String? raw = await _read(SettingKey.commutePerWeekday);
    return raw == null ? Money.zero : Money(int.parse(raw));
  }

  Future<void> setCommutePerWeekday(Money value) =>
      _write(SettingKey.commutePerWeekday, value.centavos.toString());

  Future<bool> appLockEnabled() async {
    final String? raw = await _read(SettingKey.appLockEnabled);
    return raw == 'true';
  }

  Future<void> setAppLockEnabled(bool value) =>
      _write(SettingKey.appLockEnabled, value.toString());

  Future<bool> onboardingDone() async {
    final String? raw = await _read(SettingKey.onboardingDone);
    return raw == 'true';
  }

  Future<void> setOnboardingDone(bool value) =>
      _write(SettingKey.onboardingDone, value.toString());

  Stream<Map<String, String>> watchAll() {
    return _db
        .select(_db.settings)
        .watch()
        .map(
          (List<SettingRow> rows) => <String, String>{
            for (final SettingRow r in rows) r.key: r.value,
          },
        );
  }
}
