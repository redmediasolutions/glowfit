import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsList extends StatefulWidget {
  
  const ProductsList({super.key});

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Light neutral grey
        borderRadius: BorderRadius.circular(35), // Large rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            flex: 6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.network(
                  'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTVrKMVhejKmRt88UaHOv_mpTmfDBKlOZUW_xoQl09QZ9_4tPdj',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // Info Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKINCARE',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Radiance Serum',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ 245',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          
        ],
      ),
    );
  }
}