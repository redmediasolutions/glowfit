import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gladskin/Auth/mobilelogin.dart';
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
              
                const SizedBox(height: 35),

                // --- Quick Stats Row ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem("12", "ORDERS"),
                    _buildStatItem("24", "WISHLIST"),
                    _buildStatItem("8", "REVIEWS"),
                  ],
                ),
                const SizedBox(height: 25),

                // --- Membership Card ---
                _buildMemberCard(),
                const SizedBox(height: 25),

                // --- Grid Menu ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    _buildGridTile(Icons.inventory_2_outlined, "Order History", "3 ACTIVE"),
                    _buildGridTile(Icons.favorite_border, "Saved Items", "24"),
                    _buildGridTile(Icons.credit_card_outlined, "Payment Methods", ""),
                    _buildGridTile(Icons.settings_outlined, "Settings", ""),
                  ],
                ),
                const SizedBox(height: 30),

                // --- Recent Activity Section ---
                _buildActivitySection(),

                const SizedBox(height: 40),

                // --- Sign Out Button ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                     // context.push('/login'); 
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>MobileLogin()) );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: Color(0xFFEEEEEE)),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                      
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>MobileLogin()) );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: Color(0xFFEEEEEE)),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: Text(
                      " DELETE ACCOUNT",
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

  Widget _buildStatItem(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.tenorSans(fontSize: 32)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildMemberCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(35),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/black-linen.png'), // Subtle texture
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("MEMBER SINCE", style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text("2024", style: GoogleFonts.tenorSans(color: Colors.white, fontSize: 44)),
          const SizedBox(height: 8),
          Text("Platinum Member", style: GoogleFonts.inter(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 25),
          Row(
            children: [
              Text("View Benefits", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
            ],
          )
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildGridTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: GoogleFonts.inter(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
          )
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("RECENT ACTIVITY", style: GoogleFonts.inter(letterSpacing: 2, fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600)),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivityRow("Order Delivered", "Radiance Serum", "Mar 1"),
          const Divider(height: 30, color: Colors.black12),
          _buildActivityRow("Review Posted", "Youth Cream", "Feb 28"),
          const Divider(height: 30, color: Colors.black12),
          _buildActivityRow("Item Saved", "Velvet Lipstick", "Feb 26"),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String title, String desc, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(desc, style: GoogleFonts.inter(color: Colors.black45, fontSize: 13)),
          ],
        ),
        Text(date, style: GoogleFonts.inter(color: Colors.black38, fontSize: 12)),
      ],
    );
  }

//===================Acount Deletion Logic===================
  Future<void> _deleteUserAccount(BuildContext context) async {
  try {
    // 1. Get the current user
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 2. Delete the user from the Auth service
      await user.delete();

      // 3. Navigate away to the login screen
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MobileLogin()),
          (route) => false, // Clears the navigation stack
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      // Security measure: The user must have logged in recently to delete their account
      print('The user must re-authenticate before this operation can be executed.');
    }
  } catch (e) {
    print("Error deleting account: $e");
  }
}
}

