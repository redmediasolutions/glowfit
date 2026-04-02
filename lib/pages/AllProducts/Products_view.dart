import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glowfit/Auth/mobilelogin.dart';
import 'package:glowfit/models/product_model.dart';
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
late final VoidCallback onIncrement;
late final VoidCallback onDecrement;

// required VoidCallback onRemove,
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

  bool _isGuest() {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous;
  }

  void _showLoginSnackBar() {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: const Color(0xFF1D212C),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please login to add to cart',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _updateQty(Productsmodel p, int change) async {
    final user = FirebaseAuth.instance.currentUser;

    // If user is not logged in, you should show your login sheet here
    if (user == null || user.isAnonymous) {
      return false;
    }

    final String productId = p.id.toString();
    final docRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .doc(productId);

    try {
      // We use .set with merge: true so that if the item doesn't exist, it is created.
      // If it DOES exist, only the quantity and updatedAt change.
      await docRef.set({
        'productId': p.id,
        'name': p.name,
        'image': p.image,
        'salePrice': p.salePrice ?? p.regularPrice,
        'quantity': FieldValue.increment(change),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Cart Updated: $productId");
      return true;
    } catch (e) {
      print("❌ Firestore Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null || user.isAnonymous;

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
          p.name,
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
        child: Row(
          children: [
            if (isGuest)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.remove,
                      size: 18,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "0",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              )
            else
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('carts')
                    .doc(user.uid)
                    .collection('items')
                    .doc(p.id.toString()) // Use p.id.toString() here
                    .snapshots(),
                builder: (context, snapshot) {
                  int currentQty = 0;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    currentQty = data['quantity'] ?? 0;
                  }

                  return Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                        onPressed: currentQty > 0
                            ? () async {
                                if (_isGuest()) {
                                  context.go('/login');
                                  return;
                                }
                                await _updateQty(
                                  p,
                                  -1,
                                ); // Pass the whole object 'p'
                              }
                            : null,
                          icon: Icon(
                            Icons.remove,
                            size: 18,
                            color: currentQty > 0
                                ? Colors.grey
                                : Colors.grey.shade300,
                          ),
                        ),
                        Text(
                          "$currentQty",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        IconButton(
                        onPressed: () async {
                          if (_isGuest()) {
                            context.go('/login');
                            return;
                          }
                          await _updateQty(p, 1); // Pass the whole object 'p'
                        },
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(width: 12),

            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (_isGuest()) {
                    _showLoginSnackBar();
                    context.go('/login');
                    return;
                  }
                  final bool added = await _updateQty(
                    p,
                    1,
                  ); // Pass the whole object 'p'
                  if (!added) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A206E),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A206E).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "ADD TO CART",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
            _buildHeroSection(context, p),
            const SizedBox(height: 10),
            _productdetails(context, p),
            const SizedBox(height: 10),
            scrollTriggered(_description(context, p), 'desc'),
            const SizedBox(height: 15),
         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  child: Row(
    children: [
      Expanded(child: _keywords(context, Icons.science_outlined, "Composition")),
      const SizedBox(width: 10), // Gap between frames
      Expanded(child: _keywords(context, Icons.opacity, "Hydrating")),
      const SizedBox(width: 10),
      Expanded(child: _keywords(context, Icons.verified_outlined, "Certified")),
    ],
  ),
),
            
          

  const SizedBox(height: 15),
            _buildProductDetails(p),
            const SizedBox(height: 40),
        
            scrollTriggered(_buildImageSection(context, p), 'Imagesection'),

            const SizedBox(height: 100),

      

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
            height: 700,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: allImages.length > 1,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() {
                selectedImage = allImages[index];
              });
            },
          ),
          items: allImages.map((imageUrl) {
            return Container(
              width: MediaQuery.of(context).size.width,
              color: const Color(0xFFF5F5F7),
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
            ],
          ),
        ),
      ],
    );
  }

  
//=======================KeyWords==========================
 Widget _keywords(BuildContext context, IconData symbol, String label) {
  return Container(
    height: 90,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: const Color(0xFFF8E9F0), 
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(symbol, size: 24, color: const Color(0xFF8A206E)),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1, // Prevents text from pushing the frame height
          overflow: TextOverflow.ellipsis, // Adds '...' if the word is too long
          style: GoogleFonts.inter(
            fontSize: 11, // Slightly smaller to ensure fit on small screens
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8A206E),
          ),
        ),
      ],
    ),
  );
}
  //======================= content=============================

  Widget _buildProductDetails(Productsmodel p) {
  return Column(
    children: [
      _customExpansionTile("SideEffects", p.sideeeffects?? 'No Information'),
      const Divider(height: 1),
      _customExpansionTile("How Does it Work", p.working??'No Information'),
      
    ],
  );
}

Widget _customExpansionTile(String title, String content) {
  return Theme(
    // This removes the default border/lines that ExpansionTile adds when opened
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1D212C), // Dark slate/black
        ),
      ),
      trailing: const Icon(
        Icons.add,
        color: Color(0xFF802060), // The purple/pink color from your image
        size: 26,
      ),
      // This icon appears when the tile is open
      expandedAlignment: Alignment.topLeft,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.5,
            color: Colors.black54,
          ),
        ),
      ],
    ),
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
            spacing: 20,
            children: [
              Text(
                "₹ ${p.salePrice}",
                style: GoogleFonts.tenorSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "₹ ${p.regularPrice}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: 15,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.grey,
                ),
              ),
            ],
          ),
const SizedBox(height: 20,),
          Row(
            spacing: 10,
            children: [
              Text(
                'Composition : -',
                textAlign: TextAlign.left,
                style:Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18
                )
              ),
              Expanded(
                child: Text(
                  p.composition ?? '',
                  softWrap: true,
                  textAlign: TextAlign.justify,
                style:Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: 15
                )
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
                style:Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18
                )
              ),
              Text(
                p.packagesize ?? '',
                textAlign: TextAlign.justify,
               style:Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: 15
                )
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
               style:Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18
                )
              ),
              Text(
                p.brand ?? '',
                textAlign: TextAlign.justify,
                style:Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: 15
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  //========================== DESCRIPTION SECTION =========================
  Widget _description(BuildContext context, Productsmodel p) {
    // 1. Create a Notifier to track if text is expanded
    final ValueNotifier<bool> isExpanded = ValueNotifier(false);

    final String cleanDescription = p.description.replaceAll(
      RegExp(r'<[^>]*>|&[^;]+;'),
      '',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: isExpanded,
            builder: (context, expanded, child) {
              return GestureDetector(
                onTap: () => isExpanded.value = !isExpanded.value,
                child: AnimatedSize(
                  // 2. Adds a smooth transition when expanding
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        cleanDescription,
                        textAlign: TextAlign.justify,
                        // 3. Toggle between 3 lines and "null" (which means infinite lines)
                        maxLines: expanded ? null : 5,
                        overflow: expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              );
            },
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

  // //==========================SIDE EFFECTS SECTION =========================
  // Widget _buildKeyIngredients(BuildContext context, Productsmodel p) {
  //   final String content = p.sideeeffects?.trim() ?? '';
  //   if (content.isEmpty) {
  //     return const SizedBox.shrink();
  //   }
  //   final List<String> ingredients = [content];

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'SIDE EFFECTS',
  //           style: GoogleFonts.inter(
  //             fontSize: 15,
  //             letterSpacing: 4.0,
  //             color: Colors.blueGrey,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         // Map the list to widgets
  //         ...ingredients.map(
  //           (item) => Column(
  //             children: [
  //               ListTile(
  //                 contentPadding: EdgeInsets.zero,

  //                 leading: const Padding(
  //                   padding: EdgeInsets.only(top: 8.0),
  //                   child: Icon(Icons.circle, size: 6, color: Colors.black),
  //                 ),
  //                 title: Text(
  //                   item,
  //                   style: GoogleFonts.inter(
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.w400,
  //                     height: 1.4,
  //                   ),
  //                 ),
  //               ),
  //               const Divider(thickness: 0.5, color: Color(0xFFEEEEEE)),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

//   
}
