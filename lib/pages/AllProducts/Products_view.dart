import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glowfit/Auth/mobilelogin.dart';
import 'package:glowfit/models/product_model.dart';
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
        return visible ? child : Opacity(opacity: 0, child: child);
      },
    ),
  );
}

final CarouselSliderController _carouselController = CarouselSliderController();

class ProductsView extends StatefulWidget {
  final Productsmodel product;
  const ProductsView({super.key, required this.product});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String? selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.product.image;
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.go('/AllProducts');
          },
          icon: Icon(Icons.arrow_back_ios),
        ),

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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        //========================== ADD TO CART BUTTON FUNCTION =========================
        child: GestureDetector(
          onTap: () async {
            try {
              print('➡️ Add to cart clicked');

              if (!p.canAddToCart) {
                print('⛔ Product not allowed in cart');
                return;
              }
              final user = FirebaseAuth.instance.currentUser;

              /// 🔐 Guest → show login
              if (user == null || user.isAnonymous) {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  builder: (context) {
                    return Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: MobileLogin(),
                    );
                  },
                );
                return;
              }

              final String uid = user.uid;
              final String productId = p.id.toString();

              final cartItemRef = FirebaseFirestore.instance
                  .collection('carts')
                  .doc(uid)
                  .collection('items')
                  .doc(productId);

              final cartSnap = await cartItemRef.get();

              final double parsedSalePrice =
                  p.salePrice ?? p.regularPrice ?? 0.0;

              if (cartSnap.exists) {
                /// ➕ Increment
                await cartItemRef.update({
                  'quantity': FieldValue.increment(1),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              } else {
                /// 🆕 Create
                await cartItemRef.set({
                  'productId': p.id,
                  'image': p.image,
                  'name': p.name,
                  'brand': p.brand,
                  // 'packing': p.packing,
                  'mrp': p.regularPrice,
                  'salePrice': parsedSalePrice,
                  'quantity': 1,
                  'addedBy': 'user',
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to cart')));
              }
            } catch (e, stack) {
              print('❌ Add to cart error: $e');
              print(stack);
            }
          },
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  "ADD TO CART",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
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
            _buildHeroSection(context, p),
            const SizedBox(height: 10),
            _productdetails(context, p),
            const SizedBox(height: 50),

            scrollTriggered(_description(context, p), 'desc'),
            const SizedBox(height: 50),

            scrollTriggered(_image(context, p), 'Image'),

            const SizedBox(height: 50),
            scrollTriggered(_buildKeyIngredients(context, p), 'KeyIngredients'),

            const SizedBox(height: 100),
            scrollTriggered(_buildImageSection(context, p), 'Imagesection'),

            const SizedBox(height: 100),

            _buildUsageAndVolume(context, p),

            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Productsmodel p) {
    // Combine main image and gallery images into one list
    final List<String> allImages = [
      p.image ?? '',
      ...p.galleryImages,
    ].where((img) => img.isNotEmpty).toList();

    return Stack(
      children: [
      //=========================== IMAGE CAROUSEL SECTION =========================
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 600,
            viewportFraction: 1.0, 
            enlargeCenterPage: false,
            enableInfiniteScroll: allImages.length > 1,
            autoPlay:
                false, 
            onPageChanged: (index, reason) {
              setState(() {
                selectedImage = allImages[index];
              });
            },
          ),
          items: allImages.map((imageUrl) {
            return Container(
              width: MediaQuery.of(context).size.width,
              color: const Color(
                0xFFF5F5F7,
              ), 
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                height: 100,
                width: 200, 
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
              ).animate().fadeIn(duration: 800.ms),
            );
          }).toList(),
        ),

      
        if (allImages.length > 1)
          Positioned(
            top: 550,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: allImages.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedImage == entry.value
                        ? Colors.black
                        : Colors.black.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),

        // --- Product Info Overlay ---
        Positioned(
          bottom: 30,
          left: 25,
          right: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.categories.toUpperCase(),
                style: GoogleFonts.inter(
                  letterSpacing: 3,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.name,
                style: GoogleFonts.tenorSans(
                  fontSize: 26,
                  height: 1.1,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              Text(
                "₹ ${p.salePrice}",
                style: GoogleFonts.tenorSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //========================== PRODUCT DETAILS SECTION =========================
  Widget _productdetails(BuildContext context, Productsmodel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              Text(
                'Composition : -',
                textAlign: TextAlign.left,
                style: GoogleFonts.tenorSans(fontSize: 20, color: Colors.black),
              ),
              Expanded(
                child: Text(
                  p.composition ?? '',
                  softWrap: true,
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    height: 1.5,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            spacing: 10,
            children: [
              Text(
                'Package : -',
                textAlign: TextAlign.left,
                style: GoogleFonts.tenorSans(fontSize: 20, color: Colors.black),
              ),
              Text(
                p.packagesize ?? '',
                textAlign: TextAlign.justify, 
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            spacing: 10,
            children: [
              Text(
                'Brand Name : -',
                textAlign: TextAlign.left,
                style: GoogleFonts.tenorSans(fontSize: 20, color: Colors.black),
              ),
              Text(
                p.brand ?? '',
                textAlign: TextAlign.justify,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //========================== DESCRIPTION SECTION =========================
  Widget _description(BuildContext context, Productsmodel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPTION',
            textAlign: TextAlign.left, 
            style: GoogleFonts.tenorSans(
              fontSize: 20,
              height: 1.1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            p.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
            textAlign: TextAlign.justify, 
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.5, 
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  //========================== IMAGE SECTION =========================
  Widget _image(BuildContext context, Productsmodel p) {
    return Container(
   
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Image.network(
          p.image ?? 'https://via.placeholder.com/380',
          height: 380,
          fit: BoxFit.contain,
        ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
      ),
    );
  }

  //==========================SIDE EFFECTS SECTION =========================
  Widget _buildKeyIngredients(BuildContext context, Productsmodel p) {
    final String content = p.sideeeffects?.trim() ?? '';
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<String> ingredients = [content];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIDE EFFECTS',
            style: GoogleFonts.inter(
              fontSize: 15,
              letterSpacing: 4.0,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),
          // Map the list to widgets
          ...ingredients.map(
            (item) => Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.circle, size: 6, color: Colors.black),
                  ),
                  title: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4, 
                    ),
                  ),
                ),
                const Divider(thickness: 0.5, color: Color(0xFFEEEEEE)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //========================== IMAGE SECTION =========================
  Widget _buildImageSection(BuildContext context, Productsmodel p) {
    final double sectionHeight = MediaQuery.of(context).size.height * 0.8;
    return SizedBox(
      height: sectionHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
              child: Image.network(
                p.image ?? 'https://via.placeholder.com/380',
                cacheWidth: 400,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ).animate().fadeIn(duration: 1200.ms),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      letterSpacing: 4,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.tealAccent,
                    ),
                  ).animate().fadeIn(duration: 800.ms).moveY(begin: 10, end: 0),

                  const SizedBox(height: 15),
                  Text(
                    "₹ ${p.salePrice}",
                    style: GoogleFonts.tenorSans(
                      fontSize: 24,
                      color: Colors.tealAccent,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //========================== HOW DOES IT WORK & VOLUME SECTION =========================
  Widget _buildUsageAndVolume(BuildContext context, Productsmodel p) {
    // 1. Clean the content and check if it exists
    final String workingContent = p.working?.trim() ?? '';
    final bool hasWorkingContent = workingContent.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Conditional "How It Works" Section
          if (hasWorkingContent) ...[
            Text(
              'HOW DOES IT WORK',
              style: GoogleFonts.inter(
                fontSize: 15,
                letterSpacing: 4.0,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              workingContent,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
          ],
          const Divider(thickness: 0.5, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
