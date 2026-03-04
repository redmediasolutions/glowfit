
import 'package:beauty_app/components/products_List.dart';
import 'package:beauty_app/components/secondaryscaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  @override
  Widget build(BuildContext context) {
    return Secondaryscaffold(
     
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Products',
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.5,
                        color: Colors.black,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      '18 exclusive creations',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Grid Section ---
              GestureDetector(
              onTap: () {
               /// Navigator.push(context,MaterialPageRoute(builder: (context)=>ProductsView()));
               context.go('/productview');
              },
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // Adjusted ratio to match the taller, rounded cards in screenshot
                    childAspectRatio: 0.62, 
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: 6, // Match your data length
                  itemBuilder: (context, index) {
                    // Using the ProductsList component we refined earlier
                    return const ProductsList()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
                        .moveY(begin: 30, end: 0, curve: Curves.easeOutCubic);
                  },
                ),
              ),
              
              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}