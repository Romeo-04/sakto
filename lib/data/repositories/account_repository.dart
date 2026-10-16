import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// An account together with the balance the user last reported for it.
class AccountWithBalance {
  const AccountWithBalance({
    required this.account,
    required this.provider,
    required this.balance,
    required this.capturedAt,
  });

  final AccountRow account;
  final ProviderRow provider;

  /// The latest reported balance, or zero when none has been entered yet.
  final Money balance;

  /// When that balance was reported. Null when there is no snapshot.
  final DateTime? capturedAt;

  /// True when the figure is old enough that a forecast should warn.
  ///
  /// BUILD_PLAN.md Section 8.2: a snapshot is stale after 72 hours.
  bool isStaleAt(DateTime now) {
    if (capturedAt == null) {
      return true;
    }
    return now.difference(capturedAt!) > const Duration(hours: 72);
  }
}

/// Reads and writes accounts, the places that hold money.
class AccountRepository {
  AccountRepository(this._db, this._clock, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final BaonDatabase _db;
  final Clock _clock;
  final Uuid _uuid;

  /// Every account the user has not archived or deleted.
  Future<List<AccountRow>> activeAccounts() {
    return (_db.select(_db.accounts)
          ..where(($AccountsTable t) => t.isArchived.equals(false))
          ..where(($AccountsTable t) => t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$AccountsTable>>[
            ($AccountsTable t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  /// Watches active accounts, each with its latest balance.
  Stream<List<AccountWithBalance>> watchAccountsWithBalances() {
    return _db
        .select(_db.accounts)
        .join(<Join<HasResultSet, dynamic>>[
          innerJoin(
            _db.providers,
            _db.providers.key.equalsExp(_db.accounts.providerKey),
          ),
        ])
        .watch()
        .asyncMap((List<TypedResult> rows) async {
          final List<AccountWithBalance> out = <AccountWithBalance>[];
          for (final TypedResult row in rows) {
            final AccountRow account = row.readTable(_db.accounts);
            if (account.isArchived || account.deletedAt != null) {
              continue;
            }
            final BalanceSnapshotRow? snapshot = await latestSnapshot(
              account.id,
            );
            out.add(
              AccountWithBalance(
                account: account,
                provider: row.readTable(_db.providers),
                balance: snapshot?.balanceCents ?? Money.zero,
                capturedAt: snapshot?.capturedAt,
              ),
            );
          }
          out.sort(
            (AccountWithBalance a, AccountWithBalance b) =>
                a.account.createdAt.compareTo(b.account.createdAt),
          );
          return out;
        });
  }

  /// A one-shot read of active accounts with their latest balances.
  Future<List<AccountWithBalance>> accountsWithBalances() async {
    final List<AccountRow> accounts = await activeAccounts();
    final List<AccountWithBalance> out = <AccountWithBalance>[];
    for (final AccountRow account in accounts) {
      final ProviderRow provider =
          await (_db.select(_db.providers)..where(
                ($ProvidersTable t) => t.key.equals(account.providerKey),
              ))
              .getSingle();
      final BalanceSnapshotRow? snapshot = await latestSnapshot(account.id);
      out.add(
        AccountWithBalance(
          account: account,
          provider: provider,
          balance: snapshot?.balanceCents ?? Money.zero,
          capturedAt: snapshot?.capturedAt,
        ),
      );
    }
    return out;
  }

  /// The most recent balance snapshot for one account, or null when the user
  /// has never entered a balance for it.
  Future<BalanceSnapshotRow?> latestSnapshot(String accountId) {
    return (_db.select(_db.balanceSnapshots)
          ..where(($BalanceSnapshotsTable t) => t.accountId.equals(accountId))
          ..orderBy(<OrderClauseGenerator<$BalanceSnapshotsTable>>[
            ($BalanceSnapshotsTable t) => OrderingTerm.desc(t.capturedAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Adds an account and returns its id.
  Future<String> create({
    required String providerKey,
    required String label,
    AccountRole role = AccountRole.spending,
    bool includeInSpendable = true,
  }) async {
    final String id = 'acc_${_uuid.v4()}';
    final DateTime now = _clock.nowUtc();
    await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: id,
            providerKey: providerKey,
            label: label,
            role: role,
            includeInSpendable: Value<bool>(includeInSpendable),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> rename(String id, String label) async {
    await (_db.update(
      _db.accounts,
    )..where(($AccountsTable t) => t.id.equals(id))).write(
      AccountsCompanion(
        label: Value<String>(label),
        updatedAt: Value<DateTime>(_clock.nowUtc()),
      ),
    );
  }

  Future<void> setIncludeInSpendable(String id, {required bool include}) async {
    await (_db.update(
      _db.accounts,
    )..where(($AccountsTable t) => t.id.equals(id))).write(
      AccountsCompanion(
        includeInSpendable: Value<bool>(include),
        updatedAt: Value<DateTime>(_clock.nowUtc()),
      ),
    );
  }

  /// Hides an account without losing its history.
  Future<void> archive(String id) async {
    await (_db.update(
      _db.accounts,
    )..where(($AccountsTable t) => t.id.equals(id))).write(
      AccountsCompanion(
        isArchived: const Value<bool>(true),
        updatedAt: Value<DateTime>(_clock.nowUtc()),
      ),
    );
  }

  /// Marks an account deleted. Kept as a soft delete so sync can carry the
  /// removal to another device instead of resurrecting the row.
  Future<void> softDelete(String id) async {
    final DateTime now = _clock.nowUtc();
    await (_db.update(
      _db.accounts,
    )..where(($AccountsTable t) => t.id.equals(id))).write(
      AccountsCompanion(
        deletedAt: Value<DateTime>(now),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  /// The total across every active account marked as spendable.
  ///
  /// BUILD_PLAN.md Section 8.2: `account_total_cents` is the sum of the latest
  /// snapshot for every active account.
  Future<Money> accountTotal() async {
    final List<AccountWithBalance> accounts = await accountsWithBalances();
    return Money.sum(
      accounts
          .where((AccountWithBalance a) => a.account.includeInSpendable)
          .map((AccountWithBalance a) => a.balance),
    );
  }

  /// Every provider in the registry, ready for the onboarding picker.
  Future<List<ProviderRow>> allProviders() =>
      (_db.select(_db.providers)
            ..orderBy(<OrderClauseGenerator<$ProvidersTable>>[
              ($ProvidersTable t) => OrderingTerm.asc(t.displayName),
            ]))
          .get();
}
