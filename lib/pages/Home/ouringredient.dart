import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class Ouringredient extends StatelessWidget {
  final bool visible;

  const Ouringredient({super.key, 
  required this.visible});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&q=80',
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
              .animate(target: visible ? 0 : 1)
              .fadeIn()
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 30),

          Text(
            'OUR INGREDIENTS',
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 2.0,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 15),

          Text(
                "Nature's Finest,\nScientifically Refined",
                style: GoogleFonts.tenorSans(
                  fontSize: 34,
                  height: 1.2,
                  color: Colors.black,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(delay: 200.ms)
              .moveY(begin: 20),

          const SizedBox(height: 20),

          Text(
            "We source rare botanicals from around the world and pair them with cutting-edge science to create formulations that deliver visible results.",
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF6B7280), // Neutral grey
            ),
          ),

          const SizedBox(height: 30),

          // Bullet points with clean circles
          _ingredientPoint("100% Natural Extracts"),
          _ingredientPoint("Clinically Tested"),
          _ingredientPoint("Cruelty-Free"),
        ],
      ),
    );
  }
}


  Widget _ingredientPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.black),
          const SizedBox(width: 15),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }