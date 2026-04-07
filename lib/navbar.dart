import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glowfit/Auth/mobilelogin.dart';
import 'package:glowfit/models/product_model.dart';
import 'package:glowfit/pages/AllProducts/Products_view.dart';
import 'package:glowfit/pages/AllProducts/all_products.dart';
import 'package:glowfit/pages/Home/home.dart';
import 'package:glowfit/pages/Search/searchPage.dart';
import 'package:glowfit/pages/profile/account/editprofile.dart';
import 'package:glowfit/pages/profile/account/loyalitypoints.dart';
import 'package:glowfit/pages/profile/profile.dart';
import 'package:glowfit/pages/splashscreen.dart';
import 'package:glowfit/shell.dart';

import 'package:go_router/go_router.dart';

class AppRouter {
  static final AuthStateNotifier authStateNotifier = AuthStateNotifier();

  /// ROOT NAVIGATOR
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// ROUTER
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,

    /// Start from splash to wait for auth state restoration
    initialLocation: '/splash',

    /// Refresh router when auth changes
    refreshListenable: authStateNotifier,

    /// AUTH REDIRECT
    redirect: (context, state) {
      final bool isInitialized = authStateNotifier.isInitialized;
      final user = authStateNotifier.user;

      final isLoginPage = state.matchedLocation == '/login';
      final isSplashPage = state.matchedLocation == '/splash';

      /// Wait for FirebaseAuth to restore the session
      if (!isInitialized) {
        return isSplashPage ? null : '/splash';
      }

      /// If NOT logged in → go to login
      if (user == null) {
        return isLoginPage ? null : '/login';
      }

      /// If logged in and trying to open login or splash → go home
      if ((isLoginPage || isSplashPage)) {
        return '/home';
      }

      return null;
    },

    routes: [

      /// SPLASH
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SuccessSplashScreen(),
      ),
      GoRoute(
        path: '/points',
        builder: (context, state) => const LoyaltyPointsPage(),
      ),

      /// LOGIN PAGE
      GoRoute(
        path: '/login',
        builder: (context, state) => const MobileLogin(),
      ),
         GoRoute(
        path: '/editprofile',
        builder: (context, state) => const Editprofile(),
      ),
      GoRoute(
        path: '/address',
        builder: (context, state) => const Editprofile(),
      ),
      /// PRODUCT VIEW (outside bottom nav)
      GoRoute(
        path: '/productview',
        builder: (context, state) {

          if (state.extra is Productsmodel) {
            return ProductsView(product: state.extra as Productsmodel);
          }

          return const Scaffold(
            body: Center(
              child: Text("Product data missing"),
            ),
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
          GoRoute(
            path: '/home',
            builder: (context, state) {

              final int categoryId =
                  (state.extra is int) ? state.extra as int : 0;

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

/// AUTH STATE NOTIFIER (so we can wait for the first auth event)
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      if (!_isInitialized) {
        _isInitialized = true;
      }
      notifyListeners();
    });
  }

  bool _isInitialized = false;
  User? _user;

  bool get isInitialized => _isInitialized;
  User? get user => _user;

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
