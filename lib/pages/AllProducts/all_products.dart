import 'package:beauty_app/components/products_List.dart';
import 'package:beauty_app/components/secondaryscaffold.dart';
import 'package:beauty_app/models/product_model.dart';
import 'package:beauty_app/services/api.dart';
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
  late Future<List<Productsmodel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = APIService.fetchAllProducts();
  }
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
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.1, end: 0),
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
           child:   FutureBuilder<List<Productsmodel>>(
  future: _productsFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      return const Center(child: Text("Error loading products"));
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    final products = snapshot.data!;

    return GridView.builder(
      shrinkWrap: true, // Crucial: Allows GridView to live inside a ScrollView
      physics: const NeverScrollableScrollPhysics(), // Let the parent handle scrolling
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,          // 2 items per row
        mainAxisSpacing: 20,        // Vertical space between cards
        crossAxisSpacing: 15,       // Horizontal space between cards
        childAspectRatio: 0.75,     // Adjust this to fit your card's height/width ratio
      ),
      itemBuilder: (context, index) {
        final p = products[index];

        return GestureDetector(
         onTap: () => context.push('/productview', extra: p),
          child: ProductsList(
            id: p.id.toString(),
            name: p.name,
            imageUrl: p.image,
            regularPrice: p.regularPrice,
            onAddToCart: () {
              print("Added ${p.name} to cart");
            },
          ),
        );
      },
    );
  },
)
              ),

              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}
