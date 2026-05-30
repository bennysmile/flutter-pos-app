import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/shop.dart';
import '../../../shared/models/store_settings.dart';
import '../../settings/data/shop_repository.dart';
import '../../settings/data/store_settings_repository.dart';
import '../data/app_user_repository.dart';
import '../data/session_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      users: ref.watch(appUserRepositoryProvider),
      sessions: ref.watch(sessionRepositoryProvider),
      shops: ref.watch(shopRepositoryProvider),
      settings: ref.watch(storeSettingsRepositoryProvider),
    );
  },
);

class AuthState {
  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  final AppUser? currentUser;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    AppUser? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SignupInput {
  const SignupInput({
    required this.fullName,
    required this.phone,
    required this.identifier,
    required this.password,
    required this.confirmPassword,
    required this.shopName,
    required this.shopPhone,
    required this.shopAddress,
    this.branchName = '',
  });

  final String fullName;
  final String phone;
  final String identifier;
  final String password;
  final String confirmPassword;
  final String shopName;
  final String shopPhone;
  final String shopAddress;
  final String branchName;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AppUserRepository users,
    required SessionRepository sessions,
    required ShopRepository shops,
    required StoreSettingsRepository settings,
  }) : _users = users,
       _sessions = sessions,
       _shops = shops,
       _settings = settings,
       super(const AuthState(isLoading: true)) {
    _bootstrap();
  }

  static const defaultAdminEmail = 'admin@simplepos.local';
  static const defaultAdminPassword = 'admin123';
  static const _defaultAdminPhone = '0000000000';

  final AppUserRepository _users;
  final SessionRepository _sessions;
  final ShopRepository _shops;
  final StoreSettingsRepository _settings;

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final user = await _users.getUserByLogin(identifier);
    final passwordHash = hashPassword(password);

    if (user == null || user.passwordHash != passwordHash || !user.isActive) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid username/email or password.',
      );
      return;
    }

    await _sessions.saveSession(
      userId: user.id,
      shopId: user.shopId,
      role: user.role.name,
    );
    state = AuthState(currentUser: user);
  }

  Future<void> signup(SignupInput input) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final error = await _validateSignup(input);
    if (error != null) {
      state = state.copyWith(isLoading: false, errorMessage: error);
      return;
    }

    final now = DateTime.now();
    final shopId = 'shop-${now.microsecondsSinceEpoch}';
    final userId = 'user-${now.microsecondsSinceEpoch}';
    final identifier = input.identifier.trim().toLowerCase();
    final isEmail = _isEmail(identifier);
    final username = isEmail ? '' : identifier;
    final email = isEmail ? identifier : '$identifier@local.simplepos';

    final shop = Shop(
      id: shopId,
      shopName: input.shopName.trim(),
      phone: input.shopPhone.trim(),
      address: input.shopAddress.trim(),
      email: isEmail ? identifier : '',
      branchName: input.branchName.trim(),
      currencyCode: 'GHS',
      currencySymbol: 'GHS',
      receiptFooter: 'Thank you for shopping with us.',
      taxEnabled: false,
      taxRate: 0,
      lowStockThreshold: 5,
      createdByUserId: userId,
      createdAt: now,
    );
    final user = AppUser(
      id: userId,
      fullName: input.fullName.trim(),
      phone: input.phone.trim(),
      email: email,
      username: username,
      passwordHash: hashPassword(input.password),
      role: UserRole.owner,
      shopId: shopId,
      isActive: true,
      createdAt: now,
    );
    final storeSettings = StoreSettings.defaultSettings(shopId: shopId)
        .copyWith(
          storeName: shop.shopName,
          address: shop.address,
          phone: shop.phone,
          email: shop.email,
          branchName: shop.branchName,
          currencyCode: 'GHS',
          currencySymbol: 'GHS',
          createdAt: now,
        );

    try {
      await _shops.upsertShop(shop);
      await _users.upsertUser(user);
      await _settings.saveSettings(storeSettings);
      await _sessions.saveSession(
        userId: user.id,
        shopId: user.shopId,
        role: user.role.name,
      );
      state = AuthState(currentUser: user);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> logout() async {
    await _sessions.clearSession();
    state = const AuthState();
  }

  Future<void> _bootstrap() async {
    try {
      await _ensureDefaultShop();
      await _ensureDefaultAdmin();
      await _restoreSession();
    } catch (error) {
      state = AuthState(errorMessage: error.toString());
    }
  }

  Future<void> _restoreSession() async {
    final session = await _sessions.getCurrentSession();
    if (session == null) {
      state = const AuthState();
      return;
    }

    final user = await _users.getUserById(session.currentUserId);
    if (user == null ||
        !user.isActive ||
        user.shopId != session.currentShopId) {
      await _sessions.clearSession();
      state = const AuthState();
      return;
    }

    state = AuthState(currentUser: user);
  }

  Future<void> _ensureDefaultShop() async {
    await _shops.ensureDefaultShop();

    final settings = await _settings.getSettings(Shop.defaultShopId);
    if (settings.id == StoreSettings.idForShop(Shop.defaultShopId)) {
      await _settings.saveSettings(settings);
    }
  }

  Future<void> _ensureDefaultAdmin() async {
    final existing = await _users.getUserByEmail(defaultAdminEmail);
    final now = DateTime.now();

    if (existing == null) {
      await _users.upsertUser(
        AppUser(
          id: 'default-admin',
          fullName: 'Default Admin',
          phone: _defaultAdminPhone,
          email: defaultAdminEmail,
          username: 'admin',
          passwordHash: hashPassword(defaultAdminPassword),
          role: UserRole.admin,
          shopId: Shop.defaultShopId,
          isActive: true,
          createdAt: now,
        ),
      );
      return;
    }

    final repaired = existing.copyWith(
      fullName: existing.fullName.trim().isEmpty
          ? 'Default Admin'
          : existing.fullName,
      phone: existing.phone.trim().isEmpty
          ? _defaultAdminPhone
          : existing.phone,
      username: existing.username.trim().isEmpty ? 'admin' : existing.username,
      shopId: existing.shopId.trim().isEmpty
          ? Shop.defaultShopId
          : existing.shopId,
      passwordHash: existing.passwordHash.isEmpty
          ? hashPassword(defaultAdminPassword)
          : existing.passwordHash,
      updatedAt: now,
    );

    await _users.upsertUser(repaired);
  }

  Future<String?> _validateSignup(SignupInput input) async {
    if (input.fullName.trim().isEmpty) {
      return 'Full name is required.';
    }
    if (input.phone.trim().isEmpty) {
      return 'Phone number is required.';
    }
    if (input.identifier.trim().isEmpty) {
      return 'Email or username is required.';
    }
    if (input.password.trim().isEmpty) {
      return 'Password is required.';
    }
    if (input.password != input.confirmPassword) {
      return 'Passwords do not match.';
    }
    if (input.shopName.trim().isEmpty) {
      return 'Shop name is required.';
    }
    if (input.shopPhone.trim().isEmpty) {
      return 'Shop phone number is required.';
    }
    if (input.shopAddress.trim().isEmpty) {
      return 'Shop address is required.';
    }

    final identifier = input.identifier.trim().toLowerCase();
    if (identifier.contains('@') && !_isEmail(identifier)) {
      return 'Enter a valid email address.';
    }

    final existing = await _users.getUserByLogin(identifier);
    if (existing != null) {
      return 'An account with that email or username already exists.';
    }

    return null;
  }

  static bool _isEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  static String hashPassword(String password) {
    return base64Url.encode(utf8.encode('simple_pos:${password.trim()}'));
  }
}
