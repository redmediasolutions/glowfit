import 'dart:async';
import 'package:beauty_app/AllProducts/all_products.dart';
import 'package:beauty_app/Home/home.dart';
import 'package:beauty_app/Search/searchPage.dart';
import 'package:beauty_app/profile/profile.dart';
import 'package:beauty_app/shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



//final supabase = Supabase.instance.client;

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
 
  // redirect: (context, state) {
  //   final session = supabase.auth.currentSession;
  //   final loggedIn = session != null;
  //   final isLogin = state.uri.path == '/login';

  //   if (!loggedIn && !isLogin) return '/login';
  //   if (loggedIn && isLogin) return '/dashboard';

  //   return null;
  // },
  routes: [
    // 🔓 AUTH (NO SHELL)
    // GoRoute(
    //   path: '/login',
    //   builder: (context, state) => const LoginPage(),
    // ),

    // 🔒 APP (SHELL ONCE)
    ShellRoute(
      builder: (context, state, child) {
        return ShellPage(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, __) => '/home',
        ),
         GoRoute(
          path: '/home',
           builder: (context, state) => Homepage(),
        ),
          GoRoute(
          path: '/AllProducts',
           builder: (context, state) => AllProducts(),
        ),
        GoRoute(
          path: '/search',
           builder: (context, state) => Searchpage(),
        ),
         GoRoute(
          path: '/profile',
           builder: (context, state) => Profile(),
        ),
      
       
      ],
    ),
  ],
);

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