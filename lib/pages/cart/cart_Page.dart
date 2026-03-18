import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Function to handle adding items

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget scrollTriggered(Widget Function(bool) builder, String key) {
    ValueNotifier<bool> isVisible = ValueNotifier(false);

    return VisibilityDetector(
      key: Key(key),
      onVisibilityChanged: (info) {
        // Trigger when 15% of the widget is visible to ensure a smooth start
        if (info.visibleFraction > 0.15 && !isVisible.value) {
          isVisible.value = true;
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isVisible,
        builder: (context, visible, _) {
          return builder(visible);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = kToolbarHeight + 20;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Cart',
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1.5,
                          color: Colors.black,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: screenHeight - appBarHeight - 60,
                    child: _buildCartOverlay(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //=======================CART DISPLAY ITEMS & SUMMARY===============================
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
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Something went wrong");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // 1. Handle Empty State First
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                "Your cart is empty",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // 2. Calculate Totals (Initialize variables once)
        double subtotal = 0;
        int totalQuantity = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          double price = (data['salePrice'] ?? 0).toDouble();
          int qty = (data['quantity'] ?? 1).toInt();

          subtotal += price * qty;
          totalQuantity += qty; // Now tracking total items correctly
        }
        double shipping = subtotal >= 500 ? 29.0 : 49.0;
double taxRate = (subtotal + shipping) * 0.05;

        double total = subtotal + shipping + taxRate;

        return Column(
          children: [
            // Optional: Add a small badge showing the totalQuantity here if you like
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // List of Items
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final String docId = docs[index].id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildCartItem(
                          name: data['name'] ?? 'Unknown',
                          price: "₹${data['salePrice']}",
                          imageUrl: data['image'] ?? '',
                          quantity: (data['quantity'] ?? 1).toInt(),
                          onIncrement: () => _updateQty(docId, 1),
                          onDecrement: () => _updateQty(docId, -1),
                          onRemove: () => _removeItem(docId),
                        ),
                      );
                    },
                  ),

                  const Divider(thickness: 0.5),
                  const SizedBox(height: 20),
                  _buildSummaryRow("Subtotal", "₹ ${subtotal.toInt()}"),
                  const SizedBox(height: 12),
                  _buildSummaryRow("Tax (5%)", "₹ ${taxRate.toInt()}"),
                  const SizedBox(height: 12),
                  _buildSummaryRow("Shipping", "₹ ${shipping.toInt()}"),
                  const SizedBox(height: 25),
                  _buildSummaryRow(
                    "Total",
                    "₹ ${total.toInt()}",
                    isTotal: true,
                  ),
                ],
              ),
            ),
            // Checkout Button
            _buildCheckoutButton(),
          ],
        );
      },
    );
  }

  //================PROCEED TO CHECKOUT===============================
  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: () {
          context.go('/splash');
        },
        child: Text(
          "PROCEED TO CHECKOUT",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  //================CART ITEM WIDGET===============================
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
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _quantityBtn(
                      quantity <= 1 ? Icons.delete_outline : Icons.remove,
                      quantity <= 1 ? onRemove : onDecrement,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "$quantity",
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  //================SUMMARY ROW WIDGET(SUBTOTAL)===============================
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 22 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? Colors.black : Colors.black45,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  //================UPDATE CART===============================

  void _updateQty(String docId, int delta) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(uid)
        .collection('items')
        .doc(docId);

    final doc = await docRef.get();
    int currentQty = doc.data()?['quantity'] ?? 1;

    if (currentQty + delta > 0) {
      await docRef.update({'quantity': currentQty + delta});
    }
  }

  //================REMOVE ITEM FROM CART===============================
  void _removeItem(String docId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(uid)
        .collection('items')
        .doc(docId)
        .delete();
  }
}
