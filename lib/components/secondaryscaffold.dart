import 'package:beauty_app/models/cartitem.dart';
import 'package:beauty_app/pages/cart/cart_Page.dart' hide globalCart;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Secondaryscaffold extends StatelessWidget {
  final Widget body;
  const Secondaryscaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'GLOW & FIT',
          style: GoogleFonts.tenorSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              letterSpacing: 6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
       actions: [
  Padding(
    padding: const EdgeInsets.only(right: 15),
    child: IconButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
      },
      icon: Badge(
        label: Text(
          // Calculates total quantity of all items in the cart
          globalCart.fold(0, (sum, item) => sum + item.quantity).toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        // Only show the badge if the cart is not empty
        isLabelVisible: globalCart.isNotEmpty,
        backgroundColor: Colors.redAccent, // Luxury black badge
        child: const Icon(
          Icons.shopping_bag_outlined,
          color: Colors.black,
          size: 26,
        ),
      ),
    ),
  ),
],
      ),
      body: body,
    );
    
  }
}