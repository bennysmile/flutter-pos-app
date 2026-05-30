import 'shop.dart';

enum UserRole {
  owner,
  admin,
  manager,
  cashier;

  String get label {
    return switch (this) {
      UserRole.owner => 'Owner',
      UserRole.admin => 'Admin',
      UserRole.manager => 'Manager',
      UserRole.cashier => 'Cashier',
    };
  }

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.cashier,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.shopId,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String username;
  final String passwordHash;
  final UserRole role;
  final String shopId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get name => fullName;
  bool get isAdmin => role == UserRole.admin;
  bool get isOwner => role == UserRole.owner;
  bool get isManager => role == UserRole.manager;
  bool get isCashier => role == UserRole.cashier;
  bool get isValid => validate().isEmpty;

  List<String> validate() {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('User id is required.');
    }
    if (fullName.trim().isEmpty) {
      errors.add('User name is required.');
    }
    if (phone.trim().isEmpty) {
      errors.add('User phone is required.');
    }
    if (email.trim().isEmpty && username.trim().isEmpty) {
      errors.add('Email or username is required.');
    }
    if (email.trim().isNotEmpty && !_emailPattern.hasMatch(email.trim())) {
      errors.add('A valid user email is required.');
    }
    if (passwordHash.trim().isEmpty) {
      errors.add('User password is required.');
    }
    if (shopId.trim().isEmpty) {
      errors.add('User shop id is required.');
    }

    return errors;
  }

  AppUser copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? username,
    String? passwordHash,
    UserRole? role,
    String? shopId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      shopId: shopId ?? this.shopId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'username': username,
      'passwordHash': passwordHash,
      'role': role.name,
      'shopId': shopId,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      fullName: map['fullName'] as String? ?? map['name'] as String? ?? 'User',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      passwordHash: map['passwordHash'] as String? ?? '',
      role: UserRole.fromValue(map['role'] as String? ?? UserRole.cashier.name),
      shopId: map['shopId'] as String? ?? Shop.defaultShopId,
      isActive: _boolFromDatabase(map['isActive']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: _dateTimeOrNull(map['updatedAt']),
    );
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
}

bool _boolFromDatabase(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }
  return false;
}

DateTime? _dateTimeOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value.toString());
}
