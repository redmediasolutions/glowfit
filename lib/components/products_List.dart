import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsList extends StatefulWidget {
   final String? id;
  final String? imageUrl;
  final String name;
  final double? regularPrice;
   final VoidCallback? onAddToCart;
  
  const ProductsList({super.key, this.id, this.imageUrl, 
  required this.name, this.regularPrice, this.onAddToCart});

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
                child: Container(
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    image: widget.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.imageUrl!), // Use widget.imageUrl
                        fit: BoxFit.contain,
                      )
                    : null,
                  ),
                  child: widget.imageUrl == null 
                  ? const Center(child: Icon(Icons.image_not_supported)) 
                  : null,
                )
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
                   widget.name,
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                   widget.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                  "₹${widget.regularPrice?.toStringAsFixed(2) ?? '--'}",
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