import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
   final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 250 : 500,
    
      child: TextFormField(
    controller: _searchController,
    style: const TextStyle(color: Colors.white), // Ensure text is visible
    onChanged: (value) {
      // This is the critical part: it tells the table to rebuild as you type
      setState(() {}); 
    },
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search, color: Colors.grey),
      hintText: 'Search',
      hintStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor:Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    ),
      ),
    );
  }
}