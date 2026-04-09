import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glowfit/pages/cart/cart_Page.dart';

class PrimaryHeader extends StatelessWidget {
  final Widget body;
  final Color background;

  const PrimaryHeader({
    super.key,
    required this.body,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/images/app-header.svg',
          height: 24,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                int totalItems = 0;
                
               if (snapshot.hasData) {
  for (var doc in snapshot.data!.docs) {
    // 1. Cast the document data safely
    final data = doc.data() as Map<String, dynamic>;
    
    // 2. Access 'quantity', default to 0 if null, and force to int
    final int itemQty = (data['quantity'] ?? 0).toInt();
    
    // 3. Add to your total
    totalItems += itemQty;
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
                    backgroundColor: const Color(0xFF8A206E),
                    isLabelVisible: totalItems > 0,
                    label: Text(
                      '$totalItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
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