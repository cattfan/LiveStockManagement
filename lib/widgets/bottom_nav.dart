// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8.0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(0, Icons.home_outlined, 'Trang chủ', currentIndex == 0, context),
            _buildBottomNavItem(1, Icons.pets_outlined, 'Vật nuôi', currentIndex == 1, context),
            _buildBottomNavItem(2, Icons.bar_chart_outlined, 'Thống kê', currentIndex == 2, context),
            _buildBottomNavItem(3, Icons.settings_outlined, 'Cài đặt', currentIndex == 3, context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label, bool isActive, BuildContext context) {
    final color = isActive ? Colors.green[600] : Colors.grey[600];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}