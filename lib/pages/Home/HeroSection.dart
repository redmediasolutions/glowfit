import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 0.78,
              child: Image.network(
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80',
                fit: BoxFit.cover,
              )
                  .animate()
                  .fadeIn(duration: 1200.ms)
                  .scale(begin: const Offset(1.02, 1.02), end: const Offset(1, 1)),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "The\nMicrobiome\nRevolution",
                    style: GoogleFonts.tenorSans(
                      fontSize: 36,
                      height: 1.05,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 150.ms).moveY(begin: 10, end: 0),
                  const SizedBox(height: 10),
                  Text(
                    "Science-backed solutions for eczema-prone skin.\nRestoring balance, one drop at a time.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/AllProducts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C2F67),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "EXPLORE COLLECTION",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
