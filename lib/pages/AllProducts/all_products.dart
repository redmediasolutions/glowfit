import 'package:gladskin/components/products_List.dart';
import 'package:gladskin/components/secondaryscaffold.dart';
import 'package:gladskin/models/product_model.dart';
import 'package:gladskin/services/api.dart';
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
   final categories = [
    {'name': 'Serums', 'count': '12 Products', 'image': 'https://www.drsheths.com/cdn/shop/files/1_Website.jpg?v=1746015642'},
    {'name': 'Moisturizers', 'count': '8 Products', 'image': 'https://vibrantskinbar.com/wp-content/uploads/what-is-moisturizer.jpg'},
    {'name': 'Cleansers', 'count': '6 Products', 'image': 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=400'},
    {'name': 'Masks', 'count': '5 Products', 'image': 'https://wowbeauty.co/wp-content/uploads/2023/10/face-mask-web.webp'},
  ];
  @override
  void initState() {
    super.initState();
    _productsFuture = APIService.fetchProducts();
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

              //category list

           

            SizedBox(
  height: 100,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: categories.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(categories[index]['image']!),
            ),
            const SizedBox(height: 6),
            Text(
              categories[index]['name']!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    },
  ),
),

              // --- Grid Section ---
              GestureDetector(
                onTap: () {
                 
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
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
  itemCount: products.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,      
    mainAxisSpacing: 30,        
    crossAxisSpacing: 20,       
    childAspectRatio: 0.65,    
  ),
  itemBuilder: (context, index) {
    final p = products[index];
    return GestureDetector(
      onTap: () => context.push('/productview', extra: p),
      child: ProductsList(
        id: p.id.toString(),
        name: p.name,
        imageUrl: p.image,
        regularPrice: p.salePrice,
        product: p,
        onAddToCart: () => print("Added ${p.name}"), 
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
