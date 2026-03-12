import 'package:gladskin/components/Floating_Navbar.dart';
import 'package:flutter/material.dart';

class ShellPage extends StatelessWidget {
  final Widget child;

  const ShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure the background color matches the design
      backgroundColor: const Color(0xFFFEF7E7),
      body: Stack(
        children: [
          // 1. The actual page content (Home, Shop, etc.)
          Positioned.fill(
            child: child,
          ),

          // 2. The NavBar positioned at the bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavBar(),
          ),
        ],
      ),
    );
  }
}