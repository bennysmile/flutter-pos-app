import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/database_provider.dart';
import '../../../shared/models/customer.dart';
import '../../../shared/models/shop.dart';
import '../../auth/presentation/auth_controller.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final shopId =
      ref.watch(
        authControllerProvider.select((state) => state.currentUser?.shopId),
      ) ??
      Shop.defaultShopId;
  return CustomerRepository(ref.watch(appDatabaseProvider), shopId: shopId);
});

class CustomerRepository {
  const CustomerRepository(this._database, {required this.shopId});

  final db.AppDatabase _database;
  final String shopId;

  Future<List<Customer>> getCustomers() async {
    final rows =
        await (_database.select(_database.customers)
              ..where((table) => table.shopId.equals(shopId))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  Future<Customer?> getCustomerById(String id) async {
    final row =
        await (_database.select(_database.customers)..where(
              (table) => table.id.equals(id) & table.shopId.equals(shopId),
            ))
            .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> upsertCustomer(Customer customer) async {
    final scopedCustomer = customer.copyWith(shopId: shopId);
    _ensureValid(scopedCustomer);
    await _database
        .into(_database.customers)
        .insertOnConflictUpdate(_toCompanion(scopedCustomer));
  }

  Future<int> deleteCustomer(String id) {
    return (_database.delete(_database.customers)
          ..where((table) => table.id.equals(id) & table.shopId.equals(shopId)))
        .go();
  }

  Customer _fromRow(db.Customer row) {
    return Customer(
      id: row.id,
      shopId: row.shopId,
      name: row.name,
      phone: row.phone,
      email: row.email,
      address: row.address,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.CustomersCompanion _toCompanion(Customer customer) {
    return db.CustomersCompanion(
      id: Value(customer.id),
      shopId: Value(customer.shopId),
      name: Value(customer.name),
      phone: Value(customer.phone),
      email: Value(customer.email),
      address: Value(customer.address),
      createdAt: Value(customer.createdAt),
      updatedAt: Value(customer.updatedAt),
    );
  }

  void _ensureValid(Customer customer) {
    final errors = customer.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }
  }
}
