import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glowfit/pages/splashscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Cart',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.5,
                  color: Colors.black,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 30),
              _buildCartOverlay(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartOverlay(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login to view your cart"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 20),
                Text(
                  "Your cart is empty",
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        // --- CALCULATION LOGIC ---
        double subtotal = 0;
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          // Ensure we handle both int and double from Firestore
          double price =
              double.tryParse(data['salePrice']?.toString() ?? '0') ?? 0.0;
          int qty = (data['quantity'] ?? 0).toInt();
          subtotal += price * qty;
        }

        double shipping = (subtotal == 0)
            ? 0.0
            : (subtotal >= 500 ? 29.0 : 49.0);

        double tax = subtotal * 0.05;
        double total = subtotal + shipping + tax;

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String docId = docs[index].id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildCartItem(
                    name: data['name']?.toString() ?? 'Unnamed Product',
                    price: "₹${data['salePrice']?.toString() ?? '0'}",
                    imageUrl: data['image']?.toString() ?? '',
                    quantity: (data['quantity'] ?? 1).toInt(),
                    onIncrement: () => _updateQty(docId, 1),
                    onDecrement: () => _updateQty(docId, -1),
                    onRemove: () => _removeItem(docId),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    "Subtotal",
                    "₹${subtotal.toStringAsFixed(0)}",
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow("Tax (5%)", "₹${tax.toStringAsFixed(0)}"),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    "Shipping",
                    "₹${shipping.toStringAsFixed(0)}",
                  ),
                  const Divider(height: 40, thickness: 1),
                  _buildSummaryRow(
                    "Total",
                    "₹${total.toStringAsFixed(0)}",
                    isTotal: true,
                  ),
                ],
              ),
            ),
            _buildCheckoutButton(),
          ],
        );
      },
    );
  }

  Widget _buildCartItem({
    required String name,
    required String price,
    required String imageUrl,
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : Container(width: 80, height: 80, color: Colors.grey[100]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: onRemove,
                    ),
                  ],
                ),
                Text(
                  price,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _quantityBtn(
                      quantity <= 1 ? Icons.delete_outline : Icons.remove,
                      onDecrement, // Transaction will handle removal if it hits 0
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "$quantity",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _quantityBtn(Icons.add, onIncrement),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: Colors.black),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: (){
       Navigator.push(context,MaterialPageRoute(builder: (context)=>SuccessSplashScreen()));
          
        },

        child: Text(
          "PROCEED TO CHECKOUT",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // --- DATABASE OPERATIONS ---

  void _updateQty(String docId, int delta) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .doc(docId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        int currentQty =
            (snapshot.data() as Map<String, dynamic>)['quantity'] ?? 1;
        int newQty = currentQty + delta;

        if (newQty <= 0) {
          transaction.delete(docRef);
        } else {
          transaction.update(docRef, {'quantity': newQty});
        }
      });
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  void _removeItem(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .doc(docId)
        .delete();
  }
}
