import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrimaryHeader extends StatelessWidget {
  final Widget body;
  final Color background;

  const PrimaryHeader({
    super.key,
    required this.body,
    this.background = const Color.fromARGB(255, 170, 112, 112),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/images/app-header.svg',
          height: 24,
        ),
      ),
      body: body, // ✅ THIS WAS MISSING
    );
  }
}