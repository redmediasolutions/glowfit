import 'package:beauty_app/components/products_List.dart';
import 'package:beauty_app/components/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matching the warm cream background from your design
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsGeometry.fromLTRB(15, 50, 10, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 30,),
              const Search(),

              const SizedBox(height: 30),
              ActionChoiceExample(),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return const ProductsList()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: (index * 100).ms)
                      .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.easeOutBack,
                        delay: (index * 100).ms,
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





class ActionChoiceExample extends StatefulWidget {
  const ActionChoiceExample({super.key});

  @override
  State<ActionChoiceExample> createState() => _ActionChoiceExampleState();
}

class _ActionChoiceExampleState extends State<ActionChoiceExample> {
  int? _value = 0;

  final List<String> categories = [
    'All',
    'Skincare',
    'Makeup',
    'Serums',
    'Haircare',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      // Add padding to the start so the first item isn't touching the screen edge
      padding: const EdgeInsets.symmetric(horizontal: 20), 
      child: Row(
        children: categories.asMap().entries.map((entry) {
          int index = entry.key;
          String name = entry.value;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              // 1. Convert to Uppercase to match the screenshot
              label: Text(name.toUpperCase()), 
              selected: _value == index,
              showCheckmark: false,

              // 2. Exact Typography Match
              labelStyle: GoogleFonts.montserrat(
                fontSize: 12,
                letterSpacing: 1.5, // Essential for that luxury look
                fontWeight: FontWeight.w600,
                color: _value == index ? Colors.white : Colors.black,
              ),

              // 3. Match Screenshot Colors
              selectedColor: Colors.black,
              // This is the neutral grey seen in your image
              backgroundColor: const Color(0xFFEBEBEB), 

              // 4. Sharp Corners (Zero Radius)
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide.none,
              ),

              // 5. Box Proportions
              // Increased horizontal padding makes the boxes wider
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              
              // Remove default Material behavior that adds extra padding
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,

              onSelected: (bool selected) {
                setState(() {
                  _value = selected ? index : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}