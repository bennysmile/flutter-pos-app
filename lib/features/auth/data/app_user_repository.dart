import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/database_provider.dart';
import '../../../shared/models/app_user.dart';

final appUserRepositoryProvider = Provider<AppUserRepository>((ref) {
  return AppUserRepository(ref.watch(appDatabaseProvider));
});

class AppUserRepository {
  const AppUserRepository(this._database);

  final db.AppDatabase _database;

  Stream<List<AppUser>> watchUsers({String? shopId}) {
    final query = _database.select(_database.appUsers)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    if (shopId != null) {
      query.where((table) => table.shopId.equals(shopId));
    }

    return query.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<List<AppUser>> getUsers({String? shopId}) async {
    final query = _database.select(_database.appUsers)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    if (shopId != null) {
      query.where((table) => table.shopId.equals(shopId));
    }

    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  Future<AppUser?> getUserById(String id) async {
    final row = await (_database.select(
      _database.appUsers,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final row = await (_database.select(
      _database.appUsers,
    )..where((table) => table.email.equals(email))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<AppUser?> getUserByLogin(String identifier) async {
    final normalized = identifier.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    final rows = await _database.select(_database.appUsers).get();
    for (final row in rows) {
      if (row.email.toLowerCase() == normalized ||
          row.username.toLowerCase() == normalized) {
        return _fromRow(row);
      }
    }

    return null;
  }

  Future<void> upsertUser(AppUser user) async {
    _ensureValid(user);
    await _database
        .into(_database.appUsers)
        .insertOnConflictUpdate(_toCompanion(user));
  }

  Future<int> deleteUser(String id) {
    return (_database.delete(
      _database.appUsers,
    )..where((table) => table.id.equals(id))).go();
  }

  AppUser _fromRow(db.AppUser row) {
    return AppUser(
      id: row.id,
      fullName: row.name,
      phone: row.phone,
      email: row.email,
      username: row.username,
      passwordHash: row.passwordHash,
      role: UserRole.fromValue(row.role),
      shopId: row.shopId,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.AppUsersCompanion _toCompanion(AppUser user) {
    return db.AppUsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email),
      phone: Value(user.phone),
      username: Value(user.username),
      passwordHash: Value(user.passwordHash),
      role: Value(user.role.name),
      shopId: Value(user.shopId),
      isActive: Value(user.isActive),
      createdAt: Value(user.createdAt),
      updatedAt: Value(user.updatedAt),
    );
  }

  void _ensureValid(AppUser user) {
    final errors = user.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }
  }
}
