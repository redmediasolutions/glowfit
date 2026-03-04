import 'package:beauty_app/components/products_List.dart';
import 'package:beauty_app/components/search.dart';
import 'package:beauty_app/components/secondaryscaffold.dart';
import 'package:beauty_app/models/product_model.dart';
import 'package:beauty_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  'Search',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: SearchField(), // Updated search component
              ),
              const SizedBox(height: 35),
              const ActionChoiceExample(), // The Category chips
              const SizedBox(height: 40),
              
              // Results counter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  "18 RESULTS",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              
              // GestureDetector(
              //   onTap: (){
              //     context.go('/productview');
              //   },
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
          onTap: () => context.go('/productview'),
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
            ],
          ),
        ),
      ),
    );
  }
}





class ActionChoiceExample extends StatefulWidget {
  const ActionChoiceExample({super.key});

  @override
  State<ActionChoiceExample> createState() => _ActionChoiceExampleState();
}

class _ActionChoiceExampleState extends State<ActionChoiceExample> {
  int? _value = 0;

  final List<String> categories = [
    'All',
    'Skincare',
    'Makeup',
    'Serums',
    'Haircare',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      // Add padding to the start so the first item isn't touching the screen edge
      padding: const EdgeInsets.symmetric(horizontal: 20), 
      child: Row(
        children: categories.asMap().entries.map((entry) {
          int index = entry.key;
          String name = entry.value;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              // 1. Convert to Uppercase to match the screenshot
              label: Text(name.toUpperCase()), 
              selected: _value == index,
              showCheckmark: false,

              // 2. Exact Typography Match
              labelStyle: GoogleFonts.montserrat(
                fontSize: 12,
                letterSpacing: 1.5, // Essential for that luxury look
                fontWeight: FontWeight.w600,
                color: _value == index ? Colors.white : Colors.black,
              ),

              // 3. Match Screenshot Colors
              selectedColor: Colors.black,
              // This is the neutral grey seen in your image
              backgroundColor: const Color(0xFFEBEBEB), 

              // 4. Sharp Corners (Zero Radius)
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide.none,
              ),

              // 5. Box Proportions
              // Increased horizontal padding makes the boxes wider
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              
              // Remove default Material behavior that adds extra padding
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,

              onSelected: (bool selected) {
                setState(() {
                  _value = selected ? index : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}