import 'package:flutter/material.dart';
import 'package:livestockmanagement/Screens/home_child_screens/livestock_management/livestock_management_page.dart';
import 'package:livestockmanagement/Screens/statistics_page.dart';
import 'package:livestockmanagement/Screens/setting_page.dart';

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
            _buildBottomNavItem(context, 0, Icons.home_outlined, 'Trang chủ'),
            _buildBottomNavItem(context, 1, Icons.pets_outlined, 'Vật nuôi'),
            _buildBottomNavItem(
              context,
              2,
              Icons.bar_chart_outlined,
              'Thống kê',
            ),
            _buildBottomNavItem(context, 3, Icons.settings_outlined, 'Cài đặt'),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Không làm gì nếu đang ở trang chủ (index = 0)
    if (index == 0) return;

    Widget page;
    switch (index) {
      case 1:
        page = const LivestockManagementPage();
        break;
      case 2:
        page = const StatisticsPage();
        break;
      case 3:
        page = const SettingsScreen();
        break;
      default:
        return;
    }

    // Sử dụng Navigator.push để mở trang mới, tạo ra nút quay lại
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    // Trang chủ luôn được active vì chúng ta đang ở HomeScreen
    final bool isActive = (currentIndex == 0 && index == 0);
    final color = isActive ? Colors.green[600] : Colors.grey[600];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleNavigation(context, index),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
