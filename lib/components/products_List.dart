import 'package:flutter/material.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    return         Container(
              width: 300,
              padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(32),

  gradient:  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
        Color(0xFFFDFDFD),       
      Colors.white70,
      Colors.white,             
           
    ],
    stops: [0.0, 0.5, 1.0],     
  ),
 
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 35,
      offset: const Offset(0, 5),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 15,
      offset: const Offset(0, 15),
    ),
  ],
),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section with white background
                  Stack(
                    children: [
                      Center(
                        child: Image.network(
                          'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTVrKMVhejKmRt88UaHOv_mpTmfDBKlOZUW_xoQl09QZ9_4tPdj',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Positioned(
                      //   top: 0,
                      //   right: 0,
                      //   child: CircleAvatar(
                      //     radius: 18,
                      //     backgroundColor: Colors.white,
                      //     child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category Text
                  Text(
                    'SKINCARE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.grey[400],
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Title
                  Text(
                    'Radiance Serum',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '\$245',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10,)
                ],
              ),
            );
            
  }
}