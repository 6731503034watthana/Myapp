import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_pantry/core/constants/app_routes.dart';
import 'package:smart_pantry/core/constants/app_colors.dart';
import 'package:smart_pantry/features/auth/screens/login_screen.dart';
import 'package:smart_pantry/features/auth/screens/register_screen.dart';
import 'package:smart_pantry/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_pantry/features/categories/screens/categories_screen.dart';
import 'package:smart_pantry/features/add_item/screens/add_item_screen.dart';
import 'package:smart_pantry/features/add_item/screens/add_item_form_screen.dart';
import 'package:smart_pantry/features/settings/screens/settings_screen.dart';
import 'package:smart_pantry/features/item_detail/screens/item_detail_screen.dart';
import 'package:smart_pantry/models/food_category.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isAuthRoute = state.uri.path == AppRoutes.login || state.uri.path == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      // Auth routes (ไม่มี bottom nav)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.categories,
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: AppRoutes.addItem,
            builder: (context, state) => const AddItemScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Item Detail (ซ่อน bottom nav)
      GoRoute(
        path: '${AppRoutes.itemDetail}/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ItemDetailScreen(itemId: id);
        },
      ),

      // Add Item Form (ซ่อน bottom nav)
      GoRoute(
        path: AppRoutes.addItemForm,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final category = state.extra as FoodCategory;
          return AddItemFormScreen(initialCategory: category);
        },
      ),
    ],
  );
}

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const _ScaffoldWithNavBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, '🏠', 'Dashboard', AppRoutes.dashboard),
                _navItem(context, '📂', 'Categories', AppRoutes.categories),
                _navItem(context, '➕', 'Add Item', AppRoutes.addItem),
                _navItem(context, '⚙️', 'Settings', AppRoutes.settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String emoji, String label, String route) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final isActive = currentRoute == route;
    return GestureDetector(
      onTap: () => context.go(route),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 24, color: isActive ? AppColors.primary : AppColors.inactive)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w600, color: isActive ? AppColors.primary : AppColors.inactive)),
          ],
        ),
      ),
    );
  }
}
