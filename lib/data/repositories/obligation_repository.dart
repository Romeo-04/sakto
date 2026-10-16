import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Reads and writes known future outflows: rent share, a subscription, a
/// loan payment.
class ObligationRepository {
  ObligationRepository(this._db, this._clock, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final BaonDatabase _db;
  final Clock _clock;
  final Uuid _uuid;

  Future<List<ObligationRow>> active() {
    return (_db.select(_db.obligations)
          ..where(($ObligationsTable t) => t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ObligationsTable>>[
            ($ObligationsTable t) => OrderingTerm.asc(t.nextDueOn),
          ]))
        .get();
  }

  Stream<List<ObligationRow>> watchActive() {
    return (_db.select(_db.obligations)
          ..where(($ObligationsTable t) => t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ObligationsTable>>[
            ($ObligationsTable t) => OrderingTerm.asc(t.nextDueOn),
          ]))
        .watch();
  }

  Future<String> create({
    required String label,
    required Money amount,
    required Cadence cadence,
    required DateTime nextDueOn,
    required String categoryKey,
  }) async {
    final String id = 'obl_${_uuid.v4()}';
    await _db
        .into(_db.obligations)
        .insert(
          ObligationsCompanion.insert(
            id: id,
            label: label,
            amountCents: amount,
            cadence: cadence,
            nextDueOn: nextDueOn,
            categoryKey: categoryKey,
            updatedAt: _clock.nowUtc(),
          ),
        );
    return id;
  }

  Future<void> softDelete(String id) async {
    final DateTime now = _clock.nowUtc();
    await (_db.update(
      _db.obligations,
    )..where(($ObligationsTable t) => t.id.equals(id))).write(
      ObligationsCompanion(
        deletedAt: Value<DateTime>(now),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }
}
