import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

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
        .animate(
          // Pass the controller to fix the '1 positional argument expected' error
          adapter: ScrollAdapter(_scrollController), 
        )
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
                size: 26,
              ),
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

            // Masssive spacing between "pages" to reduce clutter
            const SizedBox(height: 160),

            // --- SECTION 2: COLLECTIONS (Scroll Animated) ---
            _buildAnimatedSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCollectionHeader(),
                  const SizedBox(height: 40),
                  _buildHorizontalCollection(),
                ],
              ),
            ),

            const SizedBox(height: 180),

            // --- SECTION 3: PHILOSOPHY (Scroll Animated) ---
            _buildAnimatedSection(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),
                  _buildPhilosophySection(),
                ],
              ),
            ),

            const SizedBox(height: 120), 
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
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                    const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
            style: GoogleFonts.inter(
              fontSize: 17,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCollection() {
    return SizedBox(
      height: 520,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 25),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 320,
            margin: const EdgeInsets.only(right: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(45),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=1000&auto=format&fit=crop',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "SKINCARE",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Radiance Serum",
                        style: GoogleFonts.tenorSans(
                          fontSize: 26,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "\$245",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
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
                        )
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhilosophySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PHILOSOPHY",
            style: GoogleFonts.inter(
              letterSpacing: 4,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Beauty in\nSimplicity",
            style: GoogleFonts.tenorSans(
              fontSize: 48,
              height: 1.1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Every product is a testament to our commitment to excellence. From formulation to packaging, we believe in the power of minimalism to reveal true luxury.",
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.black54,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}