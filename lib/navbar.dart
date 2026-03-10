import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glowfit/pages/auth/login.dart';
import 'package:glowfit/pages/splashscreen.dart';
import 'package:go_router/go_router.dart';

import 'package:glowfit/Auth/mobilelogin.dart';
import 'package:glowfit/models/product_model.dart';
import 'package:glowfit/pages/AllProducts/Products_view.dart';
import 'package:glowfit/pages/AllProducts/all_products.dart';
import 'package:glowfit/pages/Home/home.dart';
import 'package:glowfit/pages/Search/searchPage.dart';
import 'package:glowfit/pages/profile/profile.dart';
import 'package:glowfit/shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',

    /// helps debug routing
    debugLogDiagnostics: true,

    /// refresh when firebase auth changes
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    /// AUTH REDIRECT
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoginPage = state.matchedLocation == '/login';

      /// If not logged in → go to login
      if (user == null) {
        return isLoginPage ? null : '/login';
      }

      /// If logged in and on login page → go to home
      if (isLoginPage) {
        return '/home';
      }

      return null;
    },

    routes: [
      /// LOGIN PAGE (outside bottom nav)
      GoRoute(
        path: '/login',
        builder: (context, state) => const MobileLogin(),
      ),
GoRoute(
        path: '/splash',
        builder: (context, state) => const SuccessSplashScreen(),
      ),
      /// PRODUCT VIEW (outside shell)
      GoRoute(
        path: '/productview',
        builder: (context, state) {
          if (state.extra is Productsmodel) {
            return ProductsView(product: state.extra as Productsmodel);
          }

          return const Scaffold(
            body: Center(child: Text("Product data missing")),
          );
        },
      ),

      /// SHELL ROUTE (BOTTOM NAV)
      ShellRoute(
        builder: (context, state, child) {
          return ShellPage(child: child);
        },
        routes: [
          /// HOME
      /// HOME
GoRoute(
  path: '/home',
  builder: (context, state) {
    // Check if extra is an int, otherwise default to a safe value like 0
    final int categoryId = (state.extra is int) ? (state.extra as int) : 0;
    
    return Homepage(categoryId: categoryId.toString());
  },
),

          /// ALL PRODUCTS
          GoRoute(
            path: '/AllProducts',
            builder: (context, state) => const AllProducts(),
          ),

          /// SEARCH
          GoRoute(
            path: '/search',
            builder: (context, state) => const Searchpage(),
          ),

          /// PROFILE
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Profile(),
          ),
        ],
      ),
    ],
  );
}

/// REFRESH ROUTER WHEN AUTH STATE CHANGES
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