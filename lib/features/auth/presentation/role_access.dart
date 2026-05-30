import '../../../app/routes.dart';
import '../../../shared/models/app_user.dart';

class RoleAccess {
  const RoleAccess._();

  static bool canAccess(UserRole role, String path) {
    if (path == AppRoutes.login) {
      return true;
    }

    if (path == AppRoutes.signup) {
      return true;
    }

    if (role == UserRole.owner || role == UserRole.admin) {
      return true;
    }

    if (role == UserRole.manager) {
      return path.startsWith(AppRoutes.dashboard) ||
          path.startsWith(AppRoutes.sales) ||
          path.startsWith(AppRoutes.reports) ||
          path.startsWith(AppRoutes.settings);
    }

    return path.startsWith(AppRoutes.pos) || path.startsWith(AppRoutes.sales);
  }

  static String landingPath(UserRole role) {
    return switch (role) {
      UserRole.owner => AppRoutes.dashboard,
      UserRole.admin => AppRoutes.dashboard,
      UserRole.manager => AppRoutes.dashboard,
      UserRole.cashier => AppRoutes.pos,
    };
  }
}
