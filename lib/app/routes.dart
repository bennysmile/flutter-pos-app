import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/role_access.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/pos/presentation/pos_screen.dart';
import '../features/products/presentation/products_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/sales/presentation/receipt_screen.dart';
import '../features/sales/presentation/sales_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../shared/widgets/app_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const signup = '/signup';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const pos = '/pos';
  static const sales = '/sales';
  static const receipt = '/sales/:saleId/receipt';
  static const reports = '/reports';
  static const settings = '/settings';

  static String receiptPath(String saleId) => '/sales/$saleId/receipt';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      if (auth.isLoading) {
        return null;
      }

      final path = state.uri.path;
      final user = auth.currentUser;

      if (user == null) {
        return path == AppRoutes.login || path == AppRoutes.signup
            ? null
            : AppRoutes.login;
      }

      if (path == AppRoutes.login || path == AppRoutes.signup) {
        return RoleAccess.landingPath(user.role);
      }

      if (!RoleAccess.canAccess(user.role, path)) {
        return RoleAccess.landingPath(user.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.products,
            name: 'products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: AppRoutes.pos,
            name: 'pos',
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: AppRoutes.sales,
            name: 'sales',
            builder: (context, state) => const SalesScreen(),
            routes: [
              GoRoute(
                path: ':saleId/receipt',
                name: 'receipt',
                builder: (context, state) {
                  return ReceiptScreen(
                    saleId: state.pathParameters['saleId'] ?? '',
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
