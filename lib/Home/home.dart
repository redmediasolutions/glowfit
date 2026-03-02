import 'package:beauty_app/components/products_List.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final ScrollController _scrollController = ScrollController();
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    // Listen to scroll to adjust opacity (Fade out as you scroll up)
    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      setState(() {
        // As user scrolls down, opacity of the top hero decreases
        _opacity = (1 - (offset / 400)).clamp(0.0, 1.0);
      });
    });
  }
  @override
  void dispose() {
    _scrollController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        backgroundColor: Colors.white,
        title: Text(
          'BEAUTY APP',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Opacity(
                opacity: _opacity,
                child: Stack(
                  children: [
                     Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                      color: const Color(0xFFF5F5F7),
                      child: Image.network(
                        'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTVrKMVhejKmRt88UaHOv_mpTmfDBKlOZUW_xoQl09QZ9_4tPdj',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Positioned(
                      top: 300,
                      left: 30,
                      right: 30,
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("NEW ARRIVAL", style: Theme.of(context).textTheme.labelLarge),
                          Text("Radiance\nRedefined", style: Theme.of(context).textTheme.displayLarge),
                         Text(
                        "Experience transformative luxury with our signature serum.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ).animate().fadeIn(delay: 400.ms),
                      
                      const SizedBox(height: 10),
          
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("DISCOVER"),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward_ios, size: 12),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 50),
              //======================Second Section===========================//
              Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our ",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                    Text(
                    "Collections",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    "Curated essentials for your daily ritual",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 50),
            Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            child:   Row(
            children: [
              // Product 1 - Starts immediately
              const ProductsList()
          .animate()
          .fadeIn(duration: 800.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack),
              
              const SizedBox(width: 15),
          
              // Product 2 - Starts after 150ms
              const ProductsList()
          .animate()
          .fadeIn(duration: 800.ms, delay: 150.ms)
          .scale(
            begin: const Offset(0.8, 0.8), 
            end: const Offset(1, 1), 
            delay: 150.ms, 
            curve: Curves.easeOutBack
          ),
          
              const SizedBox(width: 15),
          
              // Product 3 - Starts after 300ms
              const ProductsList()
          .animate()
          .fadeIn(duration: 800.ms, delay: 300.ms)
          .scale(
            begin: const Offset(0.8, 0.8), 
            end: const Offset(1, 1), 
            delay: 300.ms, 
            curve: Curves.easeOutBack
          ),
            ],
          )
            ),
          ),
          
              const SizedBox(height: 50),
          
              //===================PHILOSOPHY==========================//
              Divider(color: Colors.blueGrey, endIndent: 5, indent: 5),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Text(
                      'PHILOSOPHY',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      'Beauty in Simplicity',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      'Every product is a testament to our commitment to excellence. From formulation to packaging, we believe in the power of minimalism to reveal true luxury.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
