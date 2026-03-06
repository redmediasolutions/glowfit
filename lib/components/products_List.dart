import 'package:glowfit/models/product_model.dart';
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
  //==================ADD TO CART==========================

 
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
            //           CircleAvatar(
            //             radius: 20,
            //             backgroundColor: Colors.amber,
            //             child: IconButton(
            //               onPressed: () async{
            //                   try {
            //   print('➡️ Add to cart clicked');

             
            //   if (widget.product.canAddToCart) {
            //     print('⛔ Product not allowed in cart');
            //     return;
            //   }
            //   final user = FirebaseAuth.instance.currentUser;

            //   /// 🔐 Guest → show login
            //   if (user == null || user.isAnonymous) {
            //     await showModalBottomSheet(
            //       context: context,
            //       isScrollControlled: true,
            //       backgroundColor: Colors.transparent,
            //       enableDrag: false,
            //       builder: (context) {
            //         return Padding(
            //           padding: MediaQuery.viewInsetsOf(context),
            //           child: EmailLoginPage(),
            //         );
            //       },
            //     );
            //     return;
            //   }

            //   final String uid = user.uid;
            //   // final String uid = user.uid;
            //   final String productId = widget.product.id.toString();

            //   final cartItemRef = FirebaseFirestore.instance
            //       .collection('carts')
            //       .doc(uid)
            //       .collection('items')
            //       .doc(productId);

            //   final cartSnap = await cartItemRef.get();

            //   final double parsedSalePrice =
            //       widget.product.salePrice ?? widget.product.regularPrice ?? 0.0;

            //   if (cartSnap.exists) {
            //     /// ➕ Increment
            //     await cartItemRef.update({
            //       'quantity': FieldValue.increment(1),
            //       'updatedAt': FieldValue.serverTimestamp(),
            //     });
            //   } else {
            //     /// 🆕 Create
            //     await cartItemRef.set({
            //       'productId':  widget.product.id,
            //       'image': widget.product.image,
            //       'name': widget.product.name,
            //       'brand': widget.product.brand,
            //       // 'packing': widget.product.packing,
            //       'mrp': widget.product.regularPrice,
            //       'salePrice': parsedSalePrice,
            //       'quantity': 1,
            //       'addedBy': 'user',
            //       'createdAt': FieldValue.serverTimestamp(),
            //       'updatedAt': FieldValue.serverTimestamp(),
            //     });
            //   }

            //   if (context.mounted) {
            //     ScaffoldMessenger.of(
            //       context,
            //     ).showSnackBar(const SnackBar(content: Text('Added to cart')));
            //   }
            // } catch (e, stack) {
            //   print('❌ Add to cart error: $e');
            //   print(stack);
            // }
          
                           
            //               },
            //               icon: Icon(Icons.add),
            //               color: Colors.black,
            //               iconSize: 20,
            //             ),
            //           ),
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
