import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Authcheck {
  static String? redirect(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Check if we are currently at the login page
    final bool isLoggingIn = state.matchedLocation == '/login';

    // 1. If user is NOT logged in and NOT on the login page, force them to Login
    if (user == null) {
      return isLoggingIn ? null : '/login';
    }

    // 2. If user IS logged in and trying to access the login page, send them Home
    if (isLoggingIn) {
      return '/home';
    }

    // 3. Otherwise, let them go where they want (Home, Search, Profile, etc.)
    return null; 
  }
}