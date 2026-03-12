import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glowfit/components/products_List.dart';
import 'package:glowfit/models/cartitem.dart';
import 'package:glowfit/models/product_model.dart';
import 'package:glowfit/pages/cart/cart_Page.dart';
import 'package:glowfit/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Homepage extends StatefulWidget {
  final String categoryId;
  const Homepage({super.key, required this.categoryId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Define the ScrollController to link animations with scroll position
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Wrapper for Scroll-Triggered Animation
  Widget _buildAnimatedSection({required Widget child}) {
    return child
        .animate(adapter: ScrollAdapter(_scrollController))
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  //==================== SCROLL TRIGGER HELPER (For more complex staggered animations) ==================
  Widget scrollTriggered(Widget Function(bool) builder, String key) {
    ValueNotifier<bool> isVisible = ValueNotifier(false);

    return VisibilityDetector(
      key: Key(key),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15 && !isVisible.value) {
          isVisible.value = true;
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isVisible,
        builder: (context, visible, _) {
          return builder(visible);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = kToolbarHeight + 20;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'GladSkin',
          style: GoogleFonts.tenorSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              letterSpacing: 6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        //===================== CART ICON WITH REAL-TIME BADGE UPDATES =====================
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: StreamBuilder<QuerySnapshot>(
              // 1. Listen to the current user's cart items
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                // 2. Calculate the total quantity from the snapshot
                int totalItems = 0;
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    totalItems += (data['quantity'] ?? 0) as int;
                  }
                }

                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                  icon: Badge(
                    label: Text(
                      '$totalItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    isLabelVisible: totalItems > 0,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: HERO (Large spacing, occupies most of screen) ---
            SizedBox(
              height: screenHeight - appBarHeight - 60,
              child: _buildHeroSection(context),
            ),
            const SizedBox(height: 50),

            // --- SECTION 2: COLLECTIONS (Scroll Animated) ---
            _buildCollectionHeader(),

            _buildHorizontalCollection(categoryId: "19"),

            const SizedBox(height: 160),
            // --- SECTION 3: PHILOSOPHY (Scroll Animated) ---
            _buildAnimatedSection(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),
                  scrollTriggered(
                    (visible) => _buildPhilosophySection(context, visible),
                    'Philosophy',
                  ),
                ],
              ),
            ),

            _buildAnimatedSection(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),
                  // In your Column children:
                  scrollTriggered(
                    (visible) => _buildOurIngredients(context, visible),
                    'desc-section',
                  ),
                ],
              ),
            ),
            _buildAnimatedSection(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),
                  // In your Column children:
                  scrollTriggered(
                    (visible) => _buildShopByCategory(context, visible),
                    'desc-section',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
//===================== IMAGE + TEXT HERO SECTION WITH OVERLAY CONTENT =====================
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
          bottom: 20,
          left: 25,
          right: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NEW ARRIVAL",
                style: GoogleFonts.inter(
                  letterSpacing: 3,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Radiance\nRedefined",
                style: GoogleFonts.tenorSans(
                  fontSize: 58,
                  height: 1.0,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 25),
              Text(
                "Experience transformative luxury with our\nsignature serum, crafted for luminous skin.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  context.go('/AllProducts');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45,
                    vertical: 25,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "DISCOVER",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
//===================== COLLECTIONS SECTION WITH HORIZONTAL SCROLL AND ASYNC DATA FETCHING =====================
  Widget _buildCollectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our\nCollections",
            style: GoogleFonts.tenorSans(
              fontSize: 48,
              height: 1.1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Curated essentials for your daily ritual",
            style: GoogleFonts.inter(fontSize: 17, color: Colors.black45),
          ),
        ],
      ),
    );
  }

//====================== HORIZONTAL PRODUCT LIST WITH ASYNC FETCHING AND ERROR HANDLING ======================
  Widget _buildHorizontalCollection({required String categoryId}) {
    return SizedBox(
      height: 520,
      child: FutureBuilder<List<Productsmodel>>(
        future: APIService.fetchProductsByCategory(categoryId: categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingList();
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load products',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () => context.push('/productview', extra: product),
                child: Container(
                  width: 320,

                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ProductsList(
                          product: product,
                          id: product.id.toString(),
                          name: product.name,
                          imageUrl: product.image,
                          regularPrice: product.regularPrice,
                          onAddToCart: () => print("Added ${product.name}"),
                        ),
                      ),
                      Positioned(
                        top: 25,
                        right: 25,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              context.push('/productview', extra: product);
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  //====================== PHILOSOPHY SECTION WITH STAGGERED ANIMATIONS ======================
  Widget _buildPhilosophySection(BuildContext context, bool visible) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label: Fades in first
          Text(
                "PHILOSOPHY",
                style: GoogleFonts.inter(
                  letterSpacing: 4,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(duration: 600.ms)
              .moveY(begin: 10, end: 0),

          const SizedBox(height: 25),

          // Title: Fades and slides up with a short delay
          Text(
                "Beauty in\nSimplicity",
                style: GoogleFonts.tenorSans(
                  fontSize: 48,
                  height: 1.1,
                  color: Colors.black,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(delay: 200.ms, duration: 800.ms)
              .moveX(begin: -20, end: 0),

          const SizedBox(height: 30),

          // Body Text: Slowest fade for a smooth finish
          Text(
                "Every product is a testament to our commitment to excellence. From formulation to packaging, we believe in the power of minimalism to reveal true luxury.",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.8,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(delay: 400.ms, duration: 1000.ms)
              .moveX(begin: -20, end: 0),
        ],
      ),
    );
  }
//===================== OUR INGREDIENTS SECTION WITH IMAGE AND BULLET POINTS =====================
  Widget _buildOurIngredients(BuildContext context, bool visible) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&q=80',
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
              .animate(target: visible ? 0 : 1)
              .fadeIn()
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 30),

          Text(
            'OUR INGREDIENTS',
            style: GoogleFonts.inter(
              fontSize: 12,
              letterSpacing: 2.0,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 15),

          Text(
                "Nature's Finest,\nScientifically Refined",
                style: GoogleFonts.tenorSans(
                  fontSize: 34,
                  height: 1.2,
                  color: Colors.black,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(delay: 200.ms)
              .moveY(begin: 20),

          const SizedBox(height: 20),

          Text(
            "We source rare botanicals from around the world and pair them with cutting-edge science to create formulations that deliver visible results.",
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF6B7280), // Neutral grey
            ),
          ),

          const SizedBox(height: 30),

          // Bullet points with clean circles
          _ingredientPoint("100% Natural Extracts"),
          _ingredientPoint("Clinically Tested"),
          _ingredientPoint("Cruelty-Free"),
        ],
      ),
    );
  }
//===================== OUR INGREDIENTS SECTION WITH IMAGE AND BULLET POINTS =====================
  Widget _ingredientPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.black),
          const SizedBox(width: 15),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

//========================= SHOP BY CATEGORY SECTION WITH HORIZONTAL SCROLL AND ANIMATIONS =========================
  Widget _buildShopByCategory(BuildContext context, bool visible) {
    final categories = [
      {
        'name': 'Serums',
        'count': '12 Products',
        'image':
            'https://www.drsheths.com/cdn/shop/files/1_Website.jpg?v=1746015642',
      },
      {
        'name': 'Moisturizers',
        'count': '8 Products',
        'image':
            'https://vibrantskinbar.com/wp-content/uploads/what-is-moisturizer.jpg',
      },
      {
        'name': 'Cleansers',
        'count': '6 Products',
        'image':
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=400',
      },
      {
        'name': 'Masks',
        'count': '5 Products',
        'image':
            'https://wowbeauty.co/wp-content/uploads/2023/10/face-mask-web.webp',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Shop by Category",
              style: GoogleFonts.tenorSans(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ).animate(target: visible ? 1 : 0).fadeIn().slideX(begin: -0.1),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(categories[index]['image']!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.35),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categories[index]['name']!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            categories[index]['count']!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(target: visible ? 1 : 0)
                    .fadeIn(delay: (100 * index).ms)
                    .moveX(begin: 20, end: 0); // Subtle staggered slide-in
              },
            ),
          ),
        ],
      ),
    );
  }
}
//========================= TOP VERTICAL DRAWER WITH CUSTOM ANIMATIONS AND REAL-TIME CART BADGE =========================
class TopVerticalDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;

  const TopVerticalDrawer({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // 1. MAIN CONTENT
        Positioned.fill(
          child: SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(context),
                Expanded(child: child),
              ],
            ),
          ),
        ),

        // 2. DIM OVERLAY
        if (isOpen)
          GestureDetector(
            onTap: onToggle,
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ).animate().fadeIn(duration: 300.ms),
          ),

        // 3. THE TOP DRAWER
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
          top: isOpen ? 0 : -(screenHeight * 0.5),
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight * 0.5,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 130),
                _drawerLink("HOME"),
                _drawerLink("PRODUCTS"),
                _drawerLink("SEARCH"),
                _drawerLink("PROFILE"),
                const Spacer(),
                IconButton(
                  onPressed: onToggle,
                  icon: const Icon(Icons.keyboard_arrow_up, size: 30),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(isOpen ? Icons.close : Icons.menu_open),
            onPressed: onToggle,
          ),
          Text(
            'GLOW & FIT',
            style: GoogleFonts.tenorSans(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                letterSpacing: 6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              icon: Badge(
                label: Text(
                  // Calculates total quantity of all items in the cart
                  globalCart
                      .fold(0, (sum, item) => sum + item.quantity)
                      .toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                // Only show the badge if the cart is not empty
                isLabelVisible: globalCart.isNotEmpty,
                backgroundColor: Colors.redAccent, // Luxury black badge
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.black,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child:
          Text(
                title,
                style: GoogleFonts.archivo(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  height: 1.5,
                ),
              )
              .animate(target: isOpen ? 1 : 0)
              .fadeIn(delay: 200.ms)
              .slideX(begin: 0.2),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, _) {
        return Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }
}
