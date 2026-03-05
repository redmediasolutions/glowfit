import 'dart:async'; // Required for Timer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchField extends StatefulWidget {
  // We add this callback so the SearchPage can "listen" to the typing
  final Function(String query) onSearchChanged;

  const SearchField({super.key, required this.onSearchChanged});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel(); // Important: Stop the timer if the user leaves the page
    super.dispose();
  }

  void _onInternalChanged(String query) {
    // If the user types a new letter, cancel the previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new 500ms timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(2), 
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: TextField(
          onChanged: _onInternalChanged, // Use our debounced function
          cursorColor: Colors.black,
          style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.grey[500], size: 24),
            hintText: "Find your essentials",
            hintStyle: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 15,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}