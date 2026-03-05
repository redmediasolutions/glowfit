import 'package:beauty_app/components/galleryimage.dart';
import 'package:beauty_app/models/cartitem.dart';
import 'package:beauty_app/models/product_model.dart';
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

  final List<CartItem> _cartItems = []; 
void _addToCart() {
  setState(() {
    // We search the GLOBAL list now
   int index = globalCart.indexWhere((item) => item.name == widget.product.name);
    
    if (index != -1) {
      globalCart[index].quantity++;
    } else {
      globalCart.add(
        CartItem(
        name: widget.product.name,
            price: "₹ ${widget.product.regularPrice}",
            imageUrl: widget.product.image ?? '', 
            image: '',
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
    final p = widget.product;
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
       
      ),
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, 
floatingActionButton: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20), 
  child: GestureDetector(
    onTap: () {
      _addToCart();
      print("DEBUG: Items in cart now: ${_cartItems.length}");
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
          const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
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
_buildgalleryimage(context, p),
            const SizedBox(height: 10,),
              _productdetails(context, p),
            const SizedBox(height: 50,),

         scrollTriggered(_description(context, p), 'desc'),
            const SizedBox(height: 50,),
           

         scrollTriggered(_image(context,p), 'Image')   ,
               
            const SizedBox(height: 50,),
scrollTriggered(_buildKeyIngredients(context,p), 'KeyIngredients')   ,
          
            const SizedBox(height: 100,),
scrollTriggered(_buildImageSection(context,p), 'Imagesection')   ,
          
      
            const SizedBox(height: 100,),

            _buildUsageAndVolume(context, p),
           
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Productsmodel p) {
  return Stack(
    children: [
      Container(
        height: 600,
        width: double.infinity,
        color: const Color(0xFFF5F5F7),
        child: Image.network(
  selectedImage ?? p.image ?? 'https://via.placeholder.com/380',
  fit: BoxFit.contain,
).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
      ),

      Positioned(
        bottom: 30,   
        left: 25,
        right: 25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.categories,
              style: GoogleFonts.inter(
                letterSpacing: 3,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              p.name,
              style: GoogleFonts.tenorSans(
                fontSize: 25,
                height: 1.0,
                color: Colors.black,
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),

            const SizedBox(height: 25),

            Text(
              "₹ ${p.salePrice}",
              style: GoogleFonts.tenorSans(
                fontSize: 20,
                height: 1.0,
                color: Colors.black,
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
          ],
        ),
      ),
    ],
  );
}

//=============Gallery Image=============================
Widget _buildgalleryimage(BuildContext context, Productsmodel p) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: SizedBox(
      height: 100,
      width: 500,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: p.galleryImages.length,
        itemBuilder: (context, index) {
           final image = p.galleryImages[index]; 
          return Padding(
            padding: const EdgeInsets.only(right: 10), 
            child: GestureDetector(
               onTap: () {
                setState(() {
                  selectedImage = image;
                });
              },
              child: GalleryImage(
                imageUrl: p.galleryImages[index],
              ),
            ),
          );
        },
      ),
    ),
  );
}

 Widget _productdetails(BuildContext context, Productsmodel p) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
       
        Row(
          spacing: 10,
          children: [
              Text(
                   'Composition : -',
              textAlign: TextAlign.left, // Added for better centering
          style: GoogleFonts.tenorSans(
            fontSize: 20,
           
            color: Colors.black,
          )
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
)
           
          ],
        ),
        const SizedBox(height: 25,),
        Row(
          spacing: 10,
          children: [
              Text(
                   'Package : -',
              textAlign: TextAlign.left, 
          style: GoogleFonts.tenorSans(
            fontSize: 20,
           
            color: Colors.black,
          )
        )  ,Text(
      p.packagesize ?? '',
          textAlign: TextAlign.justify, // Ensures the block is centered
          style: GoogleFonts.inter(
            fontSize: 16, 
            height: 1.5, // Improved readability
            color: Colors.black45,
          ),
        ),
           
          ],
        ),
       const SizedBox(height: 25,),
        Row(
          spacing: 10,
          children: [
              Text(
                   'Brand Name : -',
              textAlign: TextAlign.left, 
          style: GoogleFonts.tenorSans(
            fontSize: 20,
           
            color: Colors.black,
          )
        )  , Text(
                   p.manufactured ?? '',
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

 Widget _description(BuildContext context, Productsmodel p) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
     'DESCRIPTION',
          textAlign: TextAlign.left, // Added for better centering
          style: GoogleFonts.tenorSans(
            fontSize: 20,
            height: 1.1,
            color: Colors.black,
          )
        ),
        const SizedBox(height: 20),
        Text(
       p.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
          textAlign: TextAlign.justify, // Ensures the block is centered
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
  Widget _image(BuildContext context, Productsmodel p) {
  return Container(
    // Removed height: double.infinity and margin
    padding: const EdgeInsets.symmetric(vertical: 40), // Controlled spacing
    child: Center(
      child: Image.network(
        p.image ?? 'https://via.placeholder.com/380',
        height: 380,
        fit: BoxFit.contain,
      ).animate().fadeIn(duration: 1200.ms).moveY(begin: 20, end: 0),
    ),
  );
}

  // 1. KEY INGREDIENTS SECTION
  Widget _buildKeyIngredients(BuildContext context, Productsmodel p) {
  // 1. Check if the content is null or just empty whitespace
  final String content = p.sideeeffects?.trim() ?? '';

  // 2. If no content exists, return an empty box (deletes the white space)
  if (content.isEmpty) {
    return const SizedBox.shrink();
  }

  // 3. If you have multiple side effects separated by commas or newlines, 
  // you can split them into a list. Otherwise, keep it as a single-item list.
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
        ...ingredients.map((item) => Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  // Using a smaller, cleaner bullet point
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.circle, size: 6, color: Colors.black),
                  ),
                  title: Text(
                    item,
                    style: GoogleFonts.inter(
                       fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4, // Better line height for readability
                    ),
                  ),
                ),
                const Divider(thickness: 0.5, color: Color(0xFFEEEEEE)),
              ],
            )),
      ],
    ),
  );
}

  Widget _buildImageSection(BuildContext context, Productsmodel p) {
  final double sectionHeight = MediaQuery.of(context).size.height * 0.8;

  return SizedBox(
    height: sectionHeight,
    width: double.infinity,
    child: Stack(
      children: [
      
        Positioned.fill(
          child: Container(
            color: Colors.black, 
            child: Image.network(
              p.image ?? 'https://via.placeholder.com/380',
              fit: BoxFit.cover, 
            ).animate().fadeIn(duration: 1200.ms),
          ),
        ),

     
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.6, 1.0], 
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1), 
                ],
              ),
            ),
          ),
        ),

       
        Positioned(
          bottom: 50, 
          left: 30,
          right: 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), 
             
            ),
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

  // 2. HOW TO USE & VOLUME SECTION
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
              fontSize: 16, // Reduced slightly for better body text feel
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),
        ],

        // 3. Static Volume Section (Always shows unless you make it dynamic)
        const Divider(thickness: 0.5, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 20),
      
      ],
    ),
  );
}
}