import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
   
    final String location = GoRouterState.of(context).uri.path;
    
    int getSelectedIndex() {
      if (location == '/home') return 0;
      if (location == '/AllProducts') return 1;
      if (location == '/search') return 2;
      if (location == '/profile') return 3;
      return 0;
    }

    int selectedIndex = getSelectedIndex();

    return Padding(
      
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), 
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.home_outlined, 0, '/home', selectedIndex),
            _buildNavItem(context, Icons.shopping_bag_outlined, 1, '/AllProducts', selectedIndex),
            _buildNavItem(context, Icons.search, 2, '/search', selectedIndex),
            _buildNavItem(context, Icons.person_outline, 3, '/profile', selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    int index,
    String route,
    int selectedIndex,
  ) {
    bool isSelected = selectedIndex == index;
    Color activeColor = Colors.black; 
    Color inactiveColor = Colors.blueGrey.withOpacity(0.3);

    return GestureDetector(
      onTap: () {
        if (route == '/profile') {
          final user = FirebaseAuth.instance.currentUser;
          final bool isGuest = user == null || user.isAnonymous;
          if (isGuest) {
            context.go('/login?source=profile');
            return;
          }
        }
        context.go(route);
      }, // Navigation happens here
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 28,
          ),
          // Dot indicator
          Opacity(
            opacity: isSelected ? 1 : 0,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
