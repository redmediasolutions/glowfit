import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class Collectionheader extends StatelessWidget {
  const Collectionheader({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our\nCollections",
            style: GoogleFonts.tenorSans(
              fontSize: 48,
              height: 1.1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Curated essentials for your daily ritual",
            style: GoogleFonts.inter(fontSize: 17, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}