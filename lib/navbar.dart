import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glowfit/Auth/mobilelogin.dart';
import 'package:glowfit/models/product_model.dart';
import 'package:glowfit/pages/AllProducts/Products_view.dart';
import 'package:glowfit/pages/AllProducts/all_products.dart';
import 'package:glowfit/pages/Home/home.dart';
import 'package:glowfit/pages/Search/searchPage.dart';
import 'package:glowfit/pages/profile/profile.dart';
import 'package:glowfit/shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Start here
    navigatorKey: rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    // Pointing to your Authcheck logic
    redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
  final bool loggingIn = state.matchedLocation == '/login';

  // If Firebase is still initializing, we might get a null user incorrectly.
  // Add a print here to see what's happening in your debug console:
  debugPrint("Router Redirect: User: ${user?.uid}, Location: ${state.matchedLocation}");

  if (user == null) {
    return loggingIn ? null : '/login';
  }

  // If logged in but on login page, go home
  if (loggingIn) {
    return '/home';
  }

  return null;
    },
    routes: [
      // OUTSIDE the Shell (No bottom nav here)
      GoRoute(
        path: '/login',
        builder: (context, state) => const EmailLoginPage(),
      ),
      GoRoute(
        path: '/productview',
        builder: (context, state) {
          if (state.extra is Productsmodel) {
            return ProductsView(product: state.extra as Productsmodel);
          }
          return const Scaffold(body: Center(child: Text("Product data missing")));
        },
      ),

      // INSIDE the Shell (Bottom nav exists here)
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final categoryId = state.extra as int?;
              return Homepage(categoryId: categoryId.toString());
            },
          ),
          GoRoute(
            path: '/AllProducts',
            builder: (context, state) => const AllProducts(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const Searchpage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Profile(),
          ),
        ],
      ),
    ],
  );
}

/// 🔁 Forces GoRouter to refresh when Supabase auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}