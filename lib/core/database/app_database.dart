import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

const _defaultShopId = 'default-shop';

class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get shopName => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get branchName => text().withDefault(const Constant(''))();
  TextColumn get currencyCode => text().withDefault(const Constant('GHS'))();
  TextColumn get currencySymbol => text().withDefault(const Constant('GHS'))();
  TextColumn get receiptFooter => text()();
  BoolColumn get taxEnabled => boolean().withDefault(const Constant(false))();
  RealColumn get taxRate => real().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();
  TextColumn get createdByUserId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().withDefault(const Constant(_defaultShopId))();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  RealColumn get price => real()();
  IntColumn get stockQuantity => integer()();
  IntColumn get reorderLevel => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().withDefault(const Constant(_defaultShopId))();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get username => text().withDefault(const Constant(''))();
  TextColumn get passwordHash => text().withDefault(const Constant(''))();
  TextColumn get role => text()();
  TextColumn get shopId => text().withDefault(const Constant(_defaultShopId))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().withDefault(const Constant(_defaultShopId))();
  TextColumn get receiptNumber => text().unique()();
  TextColumn get cashierId => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get status => text()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  RealColumn get subtotal => real()();
  RealColumn get discountTotal => real().withDefault(const Constant(0))();
  RealColumn get taxTotal => real().withDefault(const Constant(0))();
  RealColumn get grandTotal => real()();
  RealColumn get amountReceived => real().withDefault(const Constant(0))();
  RealColumn get changeAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().withDefault(const Constant(_defaultShopId))();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get lineTotal => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class StoreSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().withDefault(const Constant(_defaultShopId))();
  TextColumn get storeName => text()();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get taxId => text().withDefault(const Constant(''))();
  TextColumn get receiptFooter => text()();
  TextColumn get currencyCode => text().withDefault(const Constant('GHS'))();
  TextColumn get currencySymbol => text().withDefault(const Constant('GHS '))();
  BoolColumn get taxEnabled => boolean().withDefault(const Constant(false))();
  RealColumn get taxRate => real().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();
  TextColumn get branchName => text().withDefault(const Constant(''))();
  TextColumn get logoPath => text().nullable()();
  BoolColumn get cashEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get mobileMoneyEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get bankTransferEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get cardEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().withDefault(const Constant(_defaultShopId))();
  TextColumn get saleId => text()();
  TextColumn get paymentMethod => text()();
  RealColumn get amount => real()();
  RealColumn get amountReceived => real()();
  RealColumn get changeAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSessions extends Table {
  TextColumn get id => text()();
  TextColumn get currentUserId => text()();
  TextColumn get currentShopId => text()();
  TextColumn get currentUserRole => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Shops,
    Products,
    Customers,
    AppUsers,
    Sales,
    SaleItems,
    StoreSettingsTable,
    Payments,
    AppSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(products, products.reorderLevel);
        }
        if (from < 3) {
          await migrator.addColumn(sales, sales.paymentMethod);
        }
        if (from < 4) {
          await migrator.addColumn(appUsers, appUsers.passwordHash);
        }
        if (from < 5) {
          await migrator.addColumn(sales, sales.amountReceived);
          await migrator.addColumn(sales, sales.changeAmount);
        }
        if (from < 6) {
          await migrator.createTable(storeSettingsTable);
        }
        if (from < 7) {
          await migrator.addColumn(products, products.imagePath);
        }
        if (from < 8) {
          await migrator.createTable(shops);
          await migrator.createTable(payments);
          await migrator.createTable(appSessions);
          await migrator.addColumn(products, products.shopId);
          await migrator.addColumn(customers, customers.shopId);
          await migrator.addColumn(appUsers, appUsers.phone);
          await migrator.addColumn(appUsers, appUsers.username);
          await migrator.addColumn(appUsers, appUsers.shopId);
          await migrator.addColumn(sales, sales.shopId);
          await migrator.addColumn(saleItems, saleItems.shopId);
          await migrator.addColumn(
            storeSettingsTable,
            storeSettingsTable.shopId,
          );
        }
      },
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'simple_pos');
}
