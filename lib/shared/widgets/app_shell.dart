import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/role_access.dart';
import '../../shared/models/app_user.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _items = [
    _NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      route: AppRoutes.dashboard,
    ),
    _NavigationItem(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      route: AppRoutes.products,
    ),
    _NavigationItem(
      label: 'POS',
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
      route: AppRoutes.pos,
    ),
    _NavigationItem(
      label: 'Sales',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      route: AppRoutes.sales,
    ),
    _NavigationItem(
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      route: AppRoutes.reports,
    ),
    _NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      route: AppRoutes.settings,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).currentUser;
    final items = _itemsFor(user?.role);
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(path, items);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopNavigation(
                  items: items,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      _goTo(context, items, index),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _goTo(context, items, index),
            destinations: [
              for (final item in items)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          ),
        );
      },
    );
  }

  List<_NavigationItem> _itemsFor(UserRole? role) {
    if (role == null) {
      return const [];
    }
    return _items
        .where((item) => RoleAccess.canAccess(role, item.route))
        .toList();
  }

  int _selectedIndex(String path, List<_NavigationItem> items) {
    final index = items.indexWhere((item) => path.startsWith(item.route));
    return index == -1 ? 0 : index;
  }

  void _goTo(BuildContext context, List<_NavigationItem> items, int index) {
    final route = items[index].route;
    if (GoRouterState.of(context).uri.path != route) {
      context.go(route);
    }
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<_NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        children: [
          const _BrandHeader(),
          Expanded(
            child: NavigationRail(
              extended: true,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final item in items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simple POS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text('Offline-first checkout'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}
