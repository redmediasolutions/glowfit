import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:glowfit/firebase_options.dart';
import 'package:glowfit/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // 1. This must be the first line
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. This starts the "engine" for your database/auth
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
   routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'Glow & Fit',
      theme: ThemeData()
    );
  }
}
