import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Philosophysection extends StatelessWidget {

  final bool visible;

  const Philosophysection(BuildContext context, {super.key, required this.visible});

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label: Fades in first
          Text(
                "PHILOSOPHY",
                style: GoogleFonts.inter(
                  letterSpacing: 4,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(duration: 600.ms)
              .moveY(begin: 10, end: 0),

          const SizedBox(height: 25),

          // Title: Fades and slides up with a short delay
          Text(
                "Beauty in\nSimplicity",
                style: GoogleFonts.tenorSans(
                  fontSize: 48,
                  height: 1.1,
                  color: Colors.black,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(delay: 200.ms, duration: 800.ms)
              .moveX(begin: -20, end: 0),

          const SizedBox(height: 30),

          // Body Text: Slowest fade for a smooth finish
          Text(
                "Every product is a testament to our commitment to excellence. From formulation to packaging, we believe in the power of minimalism to reveal true luxury.",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.8,
                ),
              )
              .animate(target: visible ? 1 : 0)
              .fadeIn(delay: 400.ms, duration: 1000.ms)
              .moveX(begin: -20, end: 0),
        ],
      ),
    );
  }
}
