import 'package:beauty_app/navbar.dart'; // Ensure this contains your appRouter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Beauty App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFEF7E7), // Your cream background
        
        // Define Global Text Styles here
        textTheme:  TextTheme(
          // 1. For "Radiance Redefined" (Large Headings)
          displayLarge: GoogleFonts.inter( 
  textStyle:  TextStyle(
    color: Color(0xFF1A1A1A),
    fontSize: 52,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.5,
  ),
),
          // 2. For "NEW ARRIVAL" / "WELCOME BACK" (Small Labels)
          labelLarge: TextStyle(
            color: Colors.blueGrey, 
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 4,
          ),
          
          // 3. For Descriptions / Body text
          bodyLarge: TextStyle(
            color: Color(0x99000000), 
            fontSize: 16,
            height: 1.5,
          ),
          
          // 4. For Button Text
          labelMedium: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}