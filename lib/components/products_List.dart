import 'package:gladskin/models/product_model.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsList extends StatefulWidget {
  final String? id;
  final String? imageUrl;
  final String name;
  final double? regularPrice;
  final VoidCallback? onAddToCart;
  
  final Productsmodel product;

  const ProductsList({
    super.key,
    this.id,
    this.imageUrl,
    required this.name,
    this.regularPrice,
    this.onAddToCart,
   required this.product,
  });

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Only one decoration for the entire card
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Area
          Expanded(
            flex: 6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: widget.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),

          // 2. Info Area (No second Container/Stack)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centers text vertically
                children: [
                  Text(
                    widget.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${widget.regularPrice?.toStringAsFixed(0) ?? '--'}",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
          
                    ],
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
