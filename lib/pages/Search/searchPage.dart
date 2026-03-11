import 'package:flutter/material.dart';
import 'package:glowfit/components/products_List.dart';
import 'package:glowfit/models/product_model.dart';
import 'package:glowfit/services/api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';


class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  late Future<List<Productsmodel>> _productsFuture;
  int? _selectedCategoryId;
  int _resultCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchFilteredProducts(); 
  }

  // Handles Category Selection
  void _fetchFilteredProducts({int? categoryId}) {
    setState(() {
      _selectedCategoryId = categoryId;
      _productsFuture = APIService.fetchProducts(categoryId: _selectedCategoryId).then((list) {
        setState(() => _resultCount = list.length);
        return list;
      });
    });
  }

  // Handles Custom Search (Name, Salt, Brand)
  void _performSearch(String query) {
    if (query.isEmpty) {
      _fetchFilteredProducts(categoryId: _selectedCategoryId);
      return;
    }

   setState(() {
  _productsFuture = APIService().searchProducts(query).then((list) {
    _resultCount = list.length;
    return list;
  });
});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
              // SEARCH FIELD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  onChanged: _performSearch,
                  decoration: InputDecoration(
                    hintText: "Search name, salt, or brand...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              // CATEGORY CHIPS
              // ActionChoiceExample(
              //   onCategorySelected: (id) => _fetchFilteredProducts(categoryId: id),
              // ),
              const SizedBox(height: 40),
              // RESULT COUNTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  "$_resultCount RESULTS",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              // PRODUCT GRID
              FutureBuilder<List<Productsmodel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(50), child: Text("No products found")));
                  }

                  final products = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.7,
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
                          onAddToCart: () {},
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}