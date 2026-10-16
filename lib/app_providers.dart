/// The Riverpod wiring that connects the database, the repositories and the
/// engine to the widget tree.
///
/// This file is the one seam allowed to import both Flutter (Riverpod) and
/// the pure engine/data layers. Screens depend on these providers, never on
/// `BaonDatabase` directly, so a screen never has to know how a repository is
/// built.
library;

import 'package:baon/ai/categorizer/rule_categorizer.dart';
import 'package:baon/core/clock.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/balance_repository.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/data/repositories/forecast_repository.dart';
import 'package:baon/data/repositories/income_repository.dart';
import 'package:baon/data/repositories/obligation_repository.dart';
import 'package:baon/data/repositories/settings_repository.dart';
import 'package:baon/data/repositories/txn_repository.dart';
import 'package:baon/engine/engine.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The wall clock. Overridden with a [FixedClock] in widget tests.
final Provider<Clock> clockProvider = Provider<Clock>((Ref ref) {
  return const SystemClock();
});

/// The single database instance for the app's lifetime.
///
/// Kept open for the whole app rather than per-screen, because closing and
/// reopening SQLite between screens would drop the in-flight write queue.
final Provider<BaonDatabase> databaseProvider = Provider<BaonDatabase>((
  Ref ref,
) {
  final BaonDatabase db = BaonDatabase();
  ref.onDispose(db.close);
  return db;
});

final Provider<AccountRepository> accountRepositoryProvider =
    Provider<AccountRepository>((Ref ref) {
      return AccountRepository(
        ref.watch(databaseProvider),
        ref.watch(clockProvider),
      );
    });

final Provider<EnvelopeRepository> envelopeRepositoryProvider =
    Provider<EnvelopeRepository>((Ref ref) {
      return EnvelopeRepository(
        ref.watch(databaseProvider),
        ref.watch(clockProvider),
      );
    });

final Provider<TxnRepository> txnRepositoryProvider = Provider<TxnRepository>((
  Ref ref,
) {
  return TxnRepository(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
    ref.watch(envelopeRepositoryProvider),
  );
});

final Provider<BalanceRepository> balanceRepositoryProvider =
    Provider<BalanceRepository>((Ref ref) {
      return BalanceRepository(
        ref.watch(databaseProvider),
        ref.watch(clockProvider),
        ref.watch(accountRepositoryProvider),
        ref.watch(txnRepositoryProvider),
      );
    });

final Provider<ObligationRepository> obligationRepositoryProvider =
    Provider<ObligationRepository>((Ref ref) {
      return ObligationRepository(
        ref.watch(databaseProvider),
        ref.watch(clockProvider),
      );
    });

final Provider<IncomeRepository> incomeRepositoryProvider =
    Provider<IncomeRepository>((Ref ref) {
      return IncomeRepository(
        ref.watch(databaseProvider),
        ref.watch(clockProvider),
      );
    });

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
      return SettingsRepository(ref.watch(databaseProvider));
    });

final Provider<ForecastRepository> forecastRepositoryProvider =
    Provider<ForecastRepository>((Ref ref) {
      return ForecastRepository(
        db: ref.watch(databaseProvider),
        clock: ref.watch(clockProvider),
        accounts: ref.watch(accountRepositoryProvider),
        envelopes: ref.watch(envelopeRepositoryProvider),
        balances: ref.watch(balanceRepositoryProvider),
        obligations: ref.watch(obligationRepositoryProvider),
        incomes: ref.watch(incomeRepositoryProvider),
        settings: ref.watch(settingsRepositoryProvider),
      );
    });

/// True once the database has been seeded and the app can build its screens.
///
/// The provider seeds the provider registry from the bundled asset on first
/// run. Reseeding on every launch is safe: `seedProvidersFromJson` upserts
/// rather than duplicates.
final FutureProvider<void> databaseReadyProvider = FutureProvider<void>((
  Ref ref,
) async {
  final BaonDatabase db = ref.watch(databaseProvider);
  await db.seedProvidersFromAsset();
});

/// Whether the user has finished onboarding, judged by whether any account
/// exists yet. Re-evaluates whenever an account is added or removed.
final StreamProvider<bool> hasCompletedOnboardingProvider =
    StreamProvider<bool>((Ref ref) {
      final BaonDatabase db = ref.watch(databaseProvider);
      return db
          .select(db.accounts)
          .watch()
          .map((List<AccountRow> rows) => rows.isNotEmpty);
    });

/// Every account with its latest balance, live.
final StreamProvider<List<AccountWithBalance>> accountsProvider =
    StreamProvider<List<AccountWithBalance>>((Ref ref) {
      return ref.watch(accountRepositoryProvider).watchAccountsWithBalances();
    });

/// Every envelope with its current state, live.
final StreamProvider<List<EnvelopeWithState>> envelopesProvider =
    StreamProvider<List<EnvelopeWithState>>((Ref ref) {
      return ref.watch(envelopeRepositoryProvider).watchEnvelopesWithState();
    });

/// Items the reconciler could not explain, live.
final StreamProvider<List<TxnRow>> unaccountedProvider =
    StreamProvider<List<TxnRow>>((Ref ref) {
      return ref.watch(txnRepositoryProvider).watchUnaccounted();
    });

/// Recent transactions, live.
final StreamProvider<List<TxnRow>> recentTxnsProvider =
    StreamProvider<List<TxnRow>>((Ref ref) {
      return ref.watch(txnRepositoryProvider).watchRecent();
    });

/// Every category, for pickers.
final FutureProvider<List<CategoryRow>> categoriesProvider =
    FutureProvider<List<CategoryRow>>((Ref ref) {
      return ref.watch(txnRepositoryProvider).categories();
    });

/// Every provider in the registry, for the onboarding picker.
final FutureProvider<List<ProviderRow>> providersProvider =
    FutureProvider<List<ProviderRow>>((Ref ref) {
      return ref.watch(accountRepositoryProvider).allProviders();
    });

/// Obligations, live.
final StreamProvider<List<ObligationRow>> obligationsProvider =
    StreamProvider<List<ObligationRow>>((Ref ref) {
      return ref.watch(obligationRepositoryProvider).watchActive();
    });

/// Income expectations, live.
final StreamProvider<List<IncomeExpectationRow>> incomesProvider =
    StreamProvider<List<IncomeExpectationRow>>((Ref ref) {
      return ref.watch(incomeRepositoryProvider).watchActive();
    });

/// Settings, live, as a raw key-value map.
final StreamProvider<Map<String, String>> settingsProvider =
    StreamProvider<Map<String, String>>((Ref ref) {
      return ref.watch(settingsRepositoryProvider).watchAll();
    });

/// The full forecast. BUILD_PLAN.md Section 8.6: invalidate the cache on any
/// new snapshot, transaction, obligation, or borrow event.
///
/// Watching the four underlying streams (accounts, envelopes, obligations,
/// incomes) means any of those writes causes this provider to recompute,
/// which is the "invalidate on change" rule expressed through Riverpod.
final FutureProvider<ForecastResult> forecastProvider =
    FutureProvider<ForecastResult>((Ref ref) async {
      ref.watch(accountsProvider);
      ref.watch(envelopesProvider);
      ref.watch(obligationsProvider);
      ref.watch(incomesProvider);
      ref.watch(settingsProvider);
      return ref.watch(forecastRepositoryProvider).buildForecast();
    });

/// Which tab of [HomeShell] is showing. Held here, not as private state on
/// `HomeShell`, so another screen can switch tabs — for example, the
/// dashboard's "Fix your envelopes" banner jumping to Balances.
final StateProvider<int> selectedTabProvider = StateProvider<int>(
  (Ref ref) => 0,
);

/// The Tier 1 rule categorizer. BUILD_PLAN.md Section 9.2: the rule layer
/// runs before any model and the app must never block on a model, so this
/// loads once from the bundled asset and is reused everywhere a merchant
/// string needs a category guess — currently the manual "add transaction"
/// flow.
final FutureProvider<RuleCategorizer> categorizerProvider =
    FutureProvider<RuleCategorizer>((Ref ref) async {
      final String raw = await rootBundle.loadString(
        'assets/categorizer_rules.json',
      );
      return RuleCategorizer.fromJson(raw);
    });

/// Which envelope a category currently routes to, cached per category key.
///
/// Backs [_EnvelopePreview] in the add-transaction screen. A plain
/// `FutureBuilder` calling the repository directly inside `build()` would
/// create a new `Future` on every rebuild — and this screen rebuilds often,
/// since it watches several providers that resolve at different times — so
/// the preview would keep resetting to "loading" and rarely get a chance to
/// show data. A `family` provider caches the result per key instead.
final FutureProviderFamily<String?, String> envelopePreviewProvider =
    FutureProvider.family<String?, String>((Ref ref, String categoryKey) {
      return ref.watch(txnRepositoryProvider).previewEnvelopeFor(categoryKey);
    });
