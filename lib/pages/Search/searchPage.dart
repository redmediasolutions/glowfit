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
  final ScrollController _scrollController=ScrollController();
   final List<Productsmodel> _products = [];
   int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  late Future<List<Productsmodel>> _productsFuture;
  int? _selectedCategoryId;
  int _resultCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchFilteredProducts(); 
     _productsFuture = APIService.fetchProducts();
    _loadProducts(); // Initial load
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadProducts();
      }
    });
  }
//====================Load Products==========================
Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newProducts = await APIService.fetchProducts(
        page: _currentPage,
        perPage: 10, // Fetch smaller chunks
      );

      setState(() {
        _isLoading = false;
        if (newProducts.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage++;
          _products.addAll(newProducts);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //=====================FILTER & SEARCH LOGIC=====================//
  void _fetchFilteredProducts({int? categoryId}) {
    setState(() {
      _selectedCategoryId = categoryId;
      _productsFuture = APIService.fetchProducts(categoryId: _selectedCategoryId).then((list) {
        setState(() => _resultCount = list.length);
        return list;
      });
    });
  }

// ======================= HANDELS CUSTOM SEARCH QUERIES ====================== //
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
          controller: _scrollController,
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

           
          
            //=====================ITEM COUNT=====================//
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

            //===================== PRODUCT GRID ====================//
              if (_products.isEmpty && _isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_products.isEmpty)
                const Center(child: Text("No products found"))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Keep this as is
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  itemCount: _products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return GestureDetector(
                      onTap: (){
                       context.push('/productview', extra: p);
                      },
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
                ),

              // Loading indicator at the bottom
              if (_isLoading && _products.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}