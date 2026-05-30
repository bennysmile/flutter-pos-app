import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'development_seed_data.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  unawaited(DevelopmentSeedData.seedIfNeeded(database));
  ref.onDispose(database.close);
  return database;
});
