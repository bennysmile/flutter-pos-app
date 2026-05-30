import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/shop.dart';
import '../../../shared/models/store_settings.dart';
import '../../auth/presentation/auth_controller.dart';
import 'store_settings_repository.dart';

final storeSettingsProvider = StreamProvider<StoreSettings>((ref) {
  final shopId =
      ref.watch(
        authControllerProvider.select((state) => state.currentUser?.shopId),
      ) ??
      Shop.defaultShopId;

  return ref.watch(storeSettingsRepositoryProvider).watchSettings(shopId);
});
