import 'package:glowfit/models/cartitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        physics: const BouncingScrollPhysics( ),
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
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
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

Widget _buildCartOverlay(BuildContext context) {

  // 1. Calculate dynamic totals using the CORRECT list name
 double subtotal = 0;
  
  for (var item in globalCart) {
    // This logic cleans the price string (removes ₹) and converts it to a number
    double itemPrice = double.tryParse(item.price.replaceAll(RegExp(r'[^0-9 .]'), '')) ?? 0;
    subtotal += itemPrice * item.quantity;
  }

  // 2. CALCULATE TOTAL (Subtotal + Shipping)
  double shipping = globalCart.isEmpty ? 0 : 15; // No shipping if cart is empty
  double total = subtotal + shipping;

  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30), bottom: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2. Map from _cartItems
            if (globalCart.isEmpty) // Changed from _currentCart
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
              )
            else
              ...globalCart.map((item) => Padding( // Changed from _currentCart
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildCartItem(
                      name: item.name,
                      price: item.price,
                      imageUrl: item.imageUrl,
                      quantity: item.quantity,
                      onIncrement: () => setState(() => item.quantity++),
                      onDecrement: () => setState(() {
                        if (item.quantity > 1) item.quantity--;
                      }),
                      onRemove: () => setState(() => globalCart.remove(item)), // Changed from _currentCart
                    ),
                  )),

            if (globalCart.isNotEmpty) ...[ // Changed from _currentCart
              const Divider(thickness: 0.5),
              const SizedBox(height: 20),
              _buildSummaryRow("Subtotal", "₹ ${subtotal.toInt()}"),
              const SizedBox(height: 12),
              _buildSummaryRow("Shipping", "₹ 15"),
              const SizedBox(height: 25),
              _buildSummaryRow("Total", "₹ ${total.toInt()}", isTotal: true),
            ],
          ],
        ),
      ),
      
      // 3. Checkout Button Visibility
      if (globalCart.isNotEmpty) // Changed from _currentCart
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 75),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () {
              // Handle Checkout
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
        ),
    ],
  );
}
Widget _buildCartItem({
  required String name,
  required String price,
  required String imageUrl,
  required int quantity,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  required VoidCallback onRemove, // New callback for removing the item
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
        )
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              softWrap: true,    
              maxLines: 2,        
              overflow: TextOverflow.ellipsis, 
            ),
          ),
               
                  GestureDetector(
                    onTap: onRemove, 
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(price, style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _quantityBtn(Icons.remove, onDecrement),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("$quantity", style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  _quantityBtn(Icons.add, onIncrement),
                ],
              )
            ],
          ),
        )
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
}