import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Reads and writes money the user expects to receive: an allowance, a
/// stipend, a salary.
class IncomeRepository {
  IncomeRepository(this._db, this._clock, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final BaonDatabase _db;
  final Clock _clock;
  final Uuid _uuid;

  Future<List<IncomeExpectationRow>> active() {
    return (_db.select(_db.incomeExpectations)
          ..where(($IncomeExpectationsTable t) => t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$IncomeExpectationsTable>>[
            ($IncomeExpectationsTable t) => OrderingTerm.asc(t.nextExpectedOn),
          ]))
        .get();
  }

  Stream<List<IncomeExpectationRow>> watchActive() {
    return (_db.select(_db.incomeExpectations)
          ..where(($IncomeExpectationsTable t) => t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$IncomeExpectationsTable>>[
            ($IncomeExpectationsTable t) => OrderingTerm.asc(t.nextExpectedOn),
          ]))
        .watch();
  }

  Future<String> create({
    required String label,
    required Money amount,
    required Cadence cadence,
    required DateTime nextExpectedOn,
    required IncomeConfidence confidence,
  }) async {
    final String id = 'inc_${_uuid.v4()}';
    await _db
        .into(_db.incomeExpectations)
        .insert(
          IncomeExpectationsCompanion.insert(
            id: id,
            label: label,
            amountCents: amount,
            cadence: cadence,
            nextExpectedOn: nextExpectedOn,
            confidence: confidence,
            updatedAt: _clock.nowUtc(),
          ),
        );
    return id;
  }

  Future<void> softDelete(String id) async {
    final DateTime now = _clock.nowUtc();
    await (_db.update(
      _db.incomeExpectations,
    )..where(($IncomeExpectationsTable t) => t.id.equals(id))).write(
      IncomeExpectationsCompanion(
        deletedAt: Value<DateTime>(now),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }
}
