import 'package:glowfit/pages/Home/HeroSection.dart';
import 'package:glowfit/pages/Home/collectionheader.dart';
import 'package:glowfit/pages/Home/horizontalheader.dart';
import 'package:glowfit/pages/Home/ouringredient.dart';
import 'package:glowfit/pages/Home/philosophysection.dart';
import 'package:glowfit/pages/Home/shopcategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:glowfit/components/primarheader.dart';

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
        .animate(
       
          adapter: ScrollAdapter(_scrollController),
        )
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

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

    return PrimaryHeader(
     
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: HERO (Large spacing, occupies most of screen) ---
            SizedBox(
              height: screenHeight - appBarHeight - 60,
              child: HeroSection(),
            ),
            const SizedBox(height: 50),
            // --- SECTION 2: COLLECTIONS (Scroll Animated) ---
            Collectionheader(),
            HorizontalCollection(categoryId: "19"),
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
                    (visible) => Philosophysection(context, visible: visible),
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
                    (visible) => Ouringredient(visible: visible),
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
                    (visible) => Shopcategory(visible),
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

  

  

  

  

  

 


}


