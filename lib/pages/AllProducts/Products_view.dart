import 'package:beauty_app/models/cartitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

Widget scrollTriggered(Widget child, String key) {
  ValueNotifier<bool> isVisible = ValueNotifier(false);

  return VisibilityDetector(
    key: Key(key),
    onVisibilityChanged: (info) {
      // Trigger when 10% of the widget is visible
      if (info.visibleFraction > 0.1 && !isVisible.value) {
        isVisible.value = true;
      }
    },
    child: ValueListenableBuilder<bool>(
      valueListenable: isVisible,
      builder: (context, visible, _) {
        // If not visible, return the child with 0 opacity to avoid flicker
        // If visible, play the animation
        return visible 
          ? child 
          : Opacity(opacity: 0, child: child);
      },
    ),
  );
}
class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {

  List<CartItem> _cartItems = []; 
void _addToCart() {
  setState(() {
    // We search the GLOBAL list now
    int index = globalCart.indexWhere((item) => item.name == "Radiance Serum");
    
    if (index != -1) {
      globalCart[index].quantity++;
    } else {
      globalCart.add(
        CartItem(
          name: "Radiance Serum",
          price: "₹ 245",
          imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=200', image: '',
        ),
      );
    }
  });
  
  print("Global Cart size: ${globalCart.length}");



  // Optional: Show a success message
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: Colors.green[700], // Professional deep green
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    content: Row(
      children: const [
        Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
        SizedBox(width: 12),
        Text(
          "Added to cart",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  ),

  );
}
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = kToolbarHeight + 20;
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(onPressed: (){
          context.go('/AllProducts');

        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          'LUXĒ',
          style: GoogleFonts.tenorSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              letterSpacing: 6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
       
      ),
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
floatingActionButton: Container(
  // Use margin instead of fixed height for better responsiveness
  margin: const EdgeInsets.only(bottom: 0), 
  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.95),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, -5),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min, // Essential: Makes container wrap the button height
    children: [
      GestureDetector(
        onTap: () {
          _addToCart();
          print("DEBUG: Items in cart now: ${_cartItems.length}");
          
          // Optional: Add the green SnackBar we built earlier here!
        },
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8), // Slightly softer luxury feel
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                "ADD TO CART",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              
            ],
          ),
        ),
      ),
      // Account for the bottom safe area (home indicator on iPhone/Android)
      SizedBox(height: MediaQuery.of(context).padding.bottom),
    ],
  ),
),
      
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- SECTION 1: HERO (Large spacing, occupies most of screen) ---
            SizedBox(
              height: screenHeight - appBarHeight - 60,
              child: _buildHeroSection(context),
            ),
            
           scrollTriggered(_description(context), 'desc'),
            const SizedBox(height: 100,),
         scrollTriggered(_image(context), 'Image')   ,
            const SizedBox(height: 100,),
scrollTriggered(_keyfeaturs(context), 'Features')   ,
          
            const SizedBox(height: 100,),
scrollTriggered(_buildImageSection(context), 'Imagesection')   ,
          
            
            const SizedBox(height: 100,),
scrollTriggered(_buildKeyIngredients(context), 'KeyIngredients')   ,


            const SizedBox(height: 100,),

            _buildUsageAndVolume(context),
           
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      children: [
        // Grey Block background for the image
        Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 200),
          color: const Color(0xFFF5F5F7),
          child: Center(
            child: Image.network(
              'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=1000&auto=format&fit=crop',
              height: 380,
              fit: BoxFit.contain,
            ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
          ),
        ),

        // Text Content anchored to the bottom of this section
        Positioned(
          bottom: 100,
          left: 25,
          right: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Skin Care",
                style: GoogleFonts.inter(
                  letterSpacing: 3,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Radiance\nSerum",
                style: GoogleFonts.tenorSans(
                  fontSize: 58,
                  height: 1.0,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 25),
              Text(
                "\$ 245",
                style: GoogleFonts.tenorSans(
                  fontSize: 20,
                  height: 1.0,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

 Widget _description(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Luminous skin.\nRedefined.",
          textAlign: TextAlign.center, // Added for better centering
          style: GoogleFonts.tenorSans(
            fontSize: 48,
            height: 1.1,
            color: Colors.black,
          )
        ),
        const SizedBox(height: 20),
        Text(
          "A transformative serum that delivers\nunparalleled radiance and clarity. Our\nsignature formula combines cutting-edge\ntechnology with nature's most powerful\ningredients.",
          textAlign: TextAlign.center, // Ensures the block is centered
          style: GoogleFonts.inter(
            fontSize: 16, 
            height: 1.5, // Improved readability
            color: Colors.black45,
          ),
        ),
      ],
    ),
  );
}
  Widget _image(BuildContext context) {
  return Container(
    // Removed height: double.infinity and margin
    padding: const EdgeInsets.symmetric(vertical: 40), // Controlled spacing
    child: Center(
      child: Image.network(
        'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=1000&auto=format&fit=crop',
        height: 380,
        fit: BoxFit.contain,
      ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
    ),
  );
}

  Widget _keyfeaturs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Key Features",
              style: GoogleFonts.inter(
                  letterSpacing: 3,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                       spacing: 10,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFF5f4f4),
                          foregroundColor: Colors.black45,
                          child: Text(
                            '1',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
                        Text('pH - balancing', style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),),
                      ],
                    ),
                    Column(
                       spacing: 10,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFF5F5F7),
                          foregroundColor: Colors.black,
                          child: Text(
                            '2',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(duration: 1300.ms).moveY(begin: 20, end: 0),
                        Text('Alcohol - free',style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                       spacing: 10,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFF5f4f4),
                          foregroundColor: Colors.black45,
                          child: Text(
                            '3',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(duration: 1500.ms).moveY(begin: 20, end: 0),
                        Text('Gentle exfoliation',style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),),
                      ],
                    ),
                    Column(
                      spacing: 10,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFF5F5F7),
                          foregroundColor: Colors.black,
                          child: Text(
                            '4',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(duration: 1700.ms).moveY(begin: 20, end: 0),
                        Text('Suitable for all skin\n types',style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildImageSection(BuildContext context) {
  // Define a set height for the hero section (e.g., 80% of screen height)
  final double sectionHeight = MediaQuery.of(context).size.height * 0.8;

  return SizedBox(
    height: sectionHeight, // Constraints the Stack height
    width: double.infinity,
    child: Stack(
      children: [
        // 1. Background and Image
        Container(
          width: double.infinity,
          height: sectionHeight,
          color: Colors.black,
          child: Center(
            child: Image.network(
              'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=1000&auto=format&fit=crop',
              height: sectionHeight * 1.0, // Relative height for the bottle
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
          ),
        ),

        // 2. Text Content (Anchored to the bottom)
        Positioned(
          bottom: 60, // Adjusted for a cleaner look
          left: 25,
          right: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SKIN CARE",
                style: GoogleFonts.inter(
                  letterSpacing: 4, // Increased for luxury feel
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
              ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
              const SizedBox(height: 12),
              Text(
                "Radiance\nSerum",
                style: GoogleFonts.tenorSans(
                  fontSize: 42,
                  height: 1.1,
                  color: Colors.amber,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 20),
              Text(
                "\$245.00",
                style: GoogleFonts.tenorSans(
                  fontSize: 22,
                  color: Colors.amber,
                ),
              ).animate().fadeIn(delay: 500.ms).moveY(begin: 10, end: 0),
            ],
          ),
        ),
      ],
    ),
  );
}
// 1. KEY INGREDIENTS SECTION
  Widget _buildKeyIngredients(BuildContext context) {
    final List<String> ingredients = [
      'Vitamin C',
      'Hyaluronic Acid',
      'Niacinamide',
      'Peptide Complex',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY INGREDIENTS',
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 4.0,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 10),
          ...ingredients.map((item) => Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.circle, size: 8, color: Colors.black),
                    title: Text(
                      item,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const Divider(thickness: 0.5, color: Color(0xFFEEEEEE)),
                ],
              )),
        ],
      ),
    );
  }

  // 2. HOW TO USE & VOLUME SECTION
  Widget _buildUsageAndVolume(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO USE',
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 4.0,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Apply 2-3 drops to clean skin morning and evening. Follow with moisturizer.',
            style: TextStyle(fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 40),
          const Divider(thickness: 0.5, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Volume', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const Text(
                '30ml / 1.0 fl oz',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}