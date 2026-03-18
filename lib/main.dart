import 'package:firebase_core/firebase_core.dart';
import 'package:gladskin/firebase_options.dart';
import 'package:gladskin/navbar.dart';
import 'package:flutter/material.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEEEEE),
          thickness: 1,
        ),
        textTheme: TextTheme(
          // For "Radiance Redefined" and "Collections"
          displayLarge: GoogleFonts.tenorSans(
            color: const Color(0xFF1A1A1A),
            fontSize: 52,
            height: 1.05,
          ),
          // For "NEW ARRIVAL" / "PHILOSOPHY" labels
          labelLarge: GoogleFonts.inter(
            color: Colors.black.withOpacity(0.4),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
          // For Descriptions
          bodyLarge: GoogleFonts.inter(
            color: Colors.black.withOpacity(0.5),
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
