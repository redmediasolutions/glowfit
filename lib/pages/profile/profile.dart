import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glowfit/Auth/mobilelogin.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Text(
                  'Profile',
                  style: GoogleFonts.tenorSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                  ),
                ),

              
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileHeader(),
                  ],
                ),
                const SizedBox(height: 35),

              

                // 3. Calling the Active Routine Card (The one that fetches from Cart)
                _buildActiveRoutineCard(context),
                const SizedBox(height: 30),

                // --- Recent Activity Section ---
                _buildOrderHistorySection(context),

                const SizedBox(height: 40),
                _buildAccountSettings(context),
                const SizedBox(height: 40),
                // --- Sign Out Button ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Sign Out"),
                          content: const Text(
                            "Are you sure you want to log out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              },
                              child: const Text(
                                "LOGOUT",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: Color(0xFFEEEEEE)),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      "SIGN OUT",
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _deleteUserAccount(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MobileLogin()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: Color(0xFFEEEEEE)),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      "DELETE ACCOUNT",
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;

    // Logic to get full date (e.g., October 2023)
    final String fullDate = user?.metadata.creationTime != null
        ? "${_getMonth(user!.metadata.creationTime!.month)} ${user.metadata.creationTime!.year}"
        : "March 2026";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Profile Image with Glow ---
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8A206E).withOpacity(0.2),
                blurRadius: 50,
                spreadRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              60,
            ), // Half of width/height for perfect circle
            child: Container(
              width: 120,
              height: 120,
              color: const Color(0xFF1A1A1A),
              child: Image.network(
                user?.photoURL ??
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                fit: BoxFit.cover,
                // Error handling for broken links
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.white, size: 50),
              ),
            ),
          ),
        ),



        const SizedBox(height: 10),

        // --- Reactive Name Loader ---
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            // Use Auth name as initial value, then Firestore name once loaded
            String displayName = "Guest User";

            if (snapshot.hasData && snapshot.data!.exists) {
              displayName =
                  snapshot.data!.get('name') ??
                  user?.displayName ??
                  "Guest User";
            } else {
              displayName = user?.displayName ?? "Guest User";
            }

            return Text(
              displayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 32, // Adjusted size for better fit
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Colors.black,
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        Text(
          "Member since $fullDate • 450 Points",
          style: GoogleFonts.inter(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Helper function to convert month number to Name
  String _getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  

  

  Widget _buildActiveRoutineCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF2F0F0,
        ), // The soft gray background from the image
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Section ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Active\nRoutine",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFF5E2A66),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('carts')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('items')
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$count",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: const Color(0xFF5E2A66)),
                      ),
                      Text(
                        "PRODUCTS",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 25),

          // --- Products Grid ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('carts')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('items')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No products in routine"));
              }

              final cartItems = snapshot.data!.docs;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final data = cartItems[index].data() as Map<String, dynamic>;
                  return _buildRoutineTile(
                    data['name'] ?? 'Product',
                    data['image'] ?? '',

                    // You can add a 'timeOfDay' field to your cart items in Firestore
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineTile(String name, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: const Color(0xFF1D212C),
          ),
        ),
        // Text(
        //   subtitle,
        //   style: GoogleFonts.inter(
        //     color: Colors.black38,
        //     fontSize: 11,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildOrderHistorySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Matching your soft gray background
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order History",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1D212C),
            )
              ),
              TextButton(
                onPressed: () {}, // Navigate to full history
                child: Text(
                  "VIEW ALL",
                  style:Theme.of(context).textTheme.labelLarge?.copyWith(
                   fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: const Color(0xFF8A206E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List of orders
          _buildOrderRow(
            "OE-9821",
            "Nov 12, 2023",
            "142.00",
            Icons.local_shipping_outlined,
            context,
          ),
          const SizedBox(height: 20),
          _buildOrderRow(
            "OE-9455",
            "Sep 28, 2023",
            "89.00",
            Icons.check_circle_outline,
            context,
          ),
          const SizedBox(height: 20),
          _buildOrderRow(
            "OE-9102",
            "Aug 05, 2023",
            "215.50",
            Icons.check_circle_outline,
            context,
          ),
        ],
      ),
    );
  }

//==========================Order History Row==========================
  Widget _buildOrderRow(
    String orderId,
    String date,
    String price,
    IconData icon,
    BuildContext context,
  ) {
    return Row(
      children: [
        // 1. Icon Container (The gray square)
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB), // Soft gray from the image
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6B6B6B), size: 24),
        ),
        const SizedBox(width: 15),

        // 2. Order Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order #$orderId",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 2),
              Text(
                "Delivered • $date",
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),

        // 3. Price
        Text(
          "\₹$price",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: 15, color: Colors.black),
        ),
      ],
    );
  }


 
  //===================Acount Deletion Logic===================
  Future<void> _deleteUserAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        // 1. DELETE FROM BACKEND (Firestore Example)
        // Do this FIRST while the user is still authenticated
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // 2. DELETE AUTHENTICATION
        await user.delete();

        // 3. NAVIGATE & CLEAN STACK
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MobileLogin()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showReauthDialog(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  Future<void> _showReauthDialog(BuildContext context) async {
    // Show a snackbar or dialog explaining they need to log in again
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please log out and log back in to verify it's you."),
      ),
    );
  }
//==========================Account Settings Section==========================
  Widget _buildAccountSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 20),
          child: Text(
            "Account Settings",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1D212C),
            )
          ),
        ),
        _settingsTile(
          icon: Icons.person_outline,
          title: "Create Profile",
          isActive: false,
          onTap: () {
           context.go('/editprofile');
          },
        ),
        _settingsTile(
          icon: Icons.location_on_outlined,
          title: "Shipping Addresses",
          isActive: true,
          onTap: () {
            context.go('/address');
          },
        ),
        _settingsTile(
          icon: Icons.notifications_none_outlined,
          title: "Orders",
          isActive: false,
          onTap: () => (),
        ),
        _settingsTile(
          icon: Icons.card_membership_outlined,
          title: "Loyalty Points",
          isActive: false,
           onTap: () {
            context.go('/points');
          },
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap, // 1. Added this required parameter
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF5F5F5) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap, // 2. Connected the function here
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: const Color(0xFF5E2A66), size: 26),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF1D212C),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isActive ? const Color(0xFF5E2A66) : Colors.black12,
          size: 16,
        ),
      ),
    );
  }
}
