import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glowfit/pages/cart/cart_Page.dart' hide globalCart;
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
    child: StreamBuilder<QuerySnapshot>(
      // 1. Listen to the current user's cart items
      stream: FirebaseFirestore.instance
          .collection('carts')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        // 2. Calculate the total quantity from the snapshot
        int totalItems = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalItems += (data['quantity'] ?? 0) as int;
          }
        }

        return IconButton(
          onPressed: () {
        
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
          icon: Badge(
          
            label: Text(
              '$totalItems',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          
            isLabelVisible: totalItems > 0,
            backgroundColor: Colors.redAccent,
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black,
              size: 26,
            ),
          ),
        );
      },
    ),
  ),
],
      ),
      body: body,
    );
    
  }
}