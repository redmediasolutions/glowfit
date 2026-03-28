import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grey Block background for the image
        Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 200),
          color: const Color(0xFFF5F5F7),
          child: Center(
            child: Image.network(
              'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=1000&auto=format&fit=crop',
              height: 380,
              fit: BoxFit.contain,
            ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
          ),
        ),

        // Text Content anchored to the bottom of this section
        Positioned(
          bottom: 20,
          left: 25,
          right: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NEW ARRIVAL",
                style: GoogleFonts.inter(
                  letterSpacing: 3,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Radiance\nRedefined",
                style: GoogleFonts.tenorSans(
                  fontSize: 58,
                  height: 1.0,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 25),
              Text(
                "Experience transformative luxury with our\nsignature serum, crafted for luminous skin.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  context.go('/AllProducts');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45,
                    vertical: 25,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "DISCOVER",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}