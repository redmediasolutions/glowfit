import 'package:beauty_app/components/products_List.dart';
import 'package:beauty_app/components/search.dart';
import 'package:beauty_app/components/secondaryscaffold.dart';
import 'package:beauty_app/models/product_model.dart';
import 'package:beauty_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  late Future<List<Productsmodel>> _productsFuture;
  int? _currentCategoryId;
  // Track the current search and category
  String _searchQuery = "";
  int? _selectedCategoryId; 

 @override
  void initState() {
    super.initState();
    _fetchFilteredProducts();
  }
  // Helper to trigger the API fetch with current filters
  void _loadProducts() {
    setState(() {
      _productsFuture = APIService.fetchProducts(
     
        // search: _searchQuery, // Ensure your APIService supports a 'search' param
        categoryId: _selectedCategoryId,
      );
    });
  }


  // This function handles the API refresh logic
  void _fetchFilteredProducts({int? categoryId}) {
    setState(() {
      _currentCategoryId = categoryId;
      // We pass the categoryId to your existing API service
      _productsFuture = APIService.fetchProducts(
        categoryId: _currentCategoryId,
       
      );
    });
  }
  // This will be called by the Category Chips
  void _performSearch(String query) {
  setState(() {
  
    _productsFuture = APIService.fetchProducts(
     search: query, 
      categoryId: _selectedCategoryId, 
   
    );
  });
}
  // This will be called by the Search Field
  
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SearchField(
                  onSearchChanged: (query) => _performSearch(query),
                ), // Updated search component
              ),
              const SizedBox(height: 35),
              ActionChoiceExample(
                onCategorySelected: (id) {
                _fetchFilteredProducts(categoryId: id);
              },
              ), // The Category chips
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
          onTap: () => context.push('/productview', extra: p),
          child: ProductsList(
            id: p.id.toString(),
            name: p.name,
            imageUrl: p.image,
            regularPrice: p.regularPrice,
            product: p,
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
  final Function(int? categoryId) onCategorySelected;  
  const ActionChoiceExample({super.key, required this.onCategorySelected});
  @override
  State<ActionChoiceExample> createState() => _ActionChoiceExampleState();
}

class _ActionChoiceExampleState extends State<ActionChoiceExample> {
  int? _value = 0;

  // IMPORTANT: Map your names to your actual Backend Category IDs
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'id': null},
    {'name': 'Products', 'id': 17}, 
    {'name': 'HomePage', 'id': 19},
    {'name': 'Serums', 'id': 20},
    {'name': 'Haircare', 'id': 22},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20), 
      child: Row(
        children: categories.asMap().entries.map((entry) {
          int index = entry.key;
          String name = entry.value['name'];
          int? catId = entry.value['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(name.toUpperCase()), 
              selected: _value == index,
              showCheckmark: false,
              labelStyle: GoogleFonts.montserrat(
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: _value == index ? Colors.white : Colors.black,
              ),
              selectedColor: Colors.black,
              backgroundColor: const Color(0xFFEBEBEB), 
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              onSelected: (bool selected) {
                setState(() {
                  _value = selected ? index : null;
                });
              
                widget.onCategorySelected(selected ? catId : null);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

}