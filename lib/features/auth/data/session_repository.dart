import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/database_provider.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
});

class SessionRepository {
  const SessionRepository(this._database);

  static const currentSessionId = 'current';

  final db.AppDatabase _database;

  Future<AppSessionData?> getCurrentSession() async {
    final row = await (_database.select(
      _database.appSessions,
    )..where((table) => table.id.equals(currentSessionId))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return AppSessionData(
      currentUserId: row.currentUserId,
      currentShopId: row.currentShopId,
      currentUserRole: row.currentUserRole,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> saveSession({
    required String userId,
    required String shopId,
    required String role,
  }) async {
    await _database
        .into(_database.appSessions)
        .insertOnConflictUpdate(
          db.AppSessionsCompanion(
            id: const Value(currentSessionId),
            currentUserId: Value(userId),
            currentShopId: Value(shopId),
            currentUserRole: Value(role),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> clearSession() async {
    await (_database.delete(
      _database.appSessions,
    )..where((table) => table.id.equals(currentSessionId))).go();
  }
}

class AppSessionData {
  const AppSessionData({
    required this.currentUserId,
    required this.currentShopId,
    required this.currentUserRole,
    required this.updatedAt,
  });

  final String currentUserId;
  final String currentShopId;
  final String currentUserRole;
  final DateTime updatedAt;
}
