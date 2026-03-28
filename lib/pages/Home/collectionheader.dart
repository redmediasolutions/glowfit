import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class Collectionheader extends StatelessWidget {
  const Collectionheader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FEATURED SELECTION",
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFC06A83),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Essentials",
                style: GoogleFonts.tenorSans(
                  fontSize: 28,
                  height: 1.1,
                  color: const Color(0xFF2D2424),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/AllProducts'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB56B7E),
                  textStyle: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text("VIEW ALL"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
