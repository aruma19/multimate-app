// File: lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../pages/main_menu.dart';
import '../pages/team_members_page.dart';
import '../pages/help_page.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key, 
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Beranda'),
              _buildNavItem(1, Icons.group, 'Anggota'),
              _buildNavItem(2, Icons.help, 'Bantuan'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = widget.currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        _animationController.reset();
        _animationController.forward();
        widget.onTap(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(isSelected ? 12 : 8),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF6A11CB) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Color(0xFF6A11CB).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ] : [],
            ),
            child: Icon(
              icon,
              size: isSelected ? 26 : 22,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            style: TextStyle(
              color: isSelected ? Color(0xFF6A11CB) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: isSelected ? 12 : 11,
            ),
            child: Text(label),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 4,
            width: isSelected ? 20 : 0,
            margin: EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF6A11CB) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}