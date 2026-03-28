import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ValueBadges extends StatelessWidget {
  const ValueBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      'GLAD BACK',
      'GLYCERIN',
      'CERAMIDES',
      'PREBIOTICS',
      'HYALURONIC ACID',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pure. Potent. Proven.',
            style: GoogleFonts.tenorSans(
              fontSize: 22,
              color: const Color(0xFF2D2424),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: badges
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAF2A5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3C5A1A),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
