// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/widgets/feature_card.dart';
import 'package:livestockmanagement/Screens/home_child_screens/vaccination_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/storage_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/feed_management_page.dart';
import 'home_child_screens/Barn_Page/barn_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/barn_management_page.dart';
import 'livestock_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalLivestock = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTotalLivestock();
  }

  void _fetchTotalLivestock() {
    DatabaseReference vatnuoiRef = FirebaseDatabase.instance.ref('Vatnuoi');
    vatnuoiRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        int sum = 0;
        data.forEach((key, value) {
          final animalData = value as Map<dynamic, dynamic>;
          // Chuyển đổi Soluong sang int, nếu không phải số thì coi như là 0
          final quantity = int.tryParse(animalData['Soluong'].toString()) ?? 0;
          sum += quantity;
        });

        if (mounted) {
          setState(() {
            _totalLivestock = sum;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final constrainedWidth = screenWidth > 500 ? 500.0 : screenWidth;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constrainedWidth),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    color: Colors.green[600],
                    padding: const EdgeInsets.only(top: 16.0, bottom: 80.0, left: 16.0, right: 16.0),
                    child: Column(
                      children: [
                        SafeArea(
                          bottom: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pets, color: Colors.yellow[400], size: 30),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Quản lý chăn nuôi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red[500],
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: const Text(
                                          '3',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.menu, color: Colors.white, size: 28),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.green[500],
                              child: const Icon(Icons.person, size: 32, color: Colors.white70)
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào, An Nguyễn!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                'Trang trại ABC',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 22.0, left: 16.0, right: 16.0, bottom: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Text(
                      'Chức năng chính',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        FeatureCard(icon: Icons.savings_outlined,
                            label: 'Quản lý Vật nuôi',
                            iconColor: const Color(0xFF34D399),
                            bgColor: const Color(0xFFD1FAE5),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  LivestockGridScreen())
                              );
                            }
                        ),

                        FeatureCard(icon: Icons.home_work_outlined,
                          label: 'Quản lý Chuồng trại',
                          iconColor: const Color(0xFF34D399),
                          bgColor: const Color(0xFFD1FAE5),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            const BarnManagementPage())
                            );
                          },
                        ),
                        FeatureCard(icon: Icons.grass_outlined,
                          label: 'Quản lý Thức ăn',
                          iconColor: const Color(0xFF34D399),
                          bgColor: const Color(0xFFD1FAE5),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            const FeedManagementPage())
                            );
                          },
                        ),
                        FeatureCard(icon: Icons.vaccines_outlined,
                          label: 'Lịch tiêm chủng',
                          iconColor: const Color(0xFF34D399),
                          bgColor: const Color(0xFFD1FAE5),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            const VaccinationPage())
                            );
                          },
                        ),
                        FeatureCard(icon: Icons.inventory_2_outlined,
                          label: 'Quản lý Kho',
                          iconColor: const Color(0xFF34D399),
                          bgColor: const Color(0xFFD1FAE5),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            const StorageManagementPage())
                            );
                          },
                        ),
                        const FeatureCard(icon: Icons.receipt_long_outlined,
                            label: 'Ghi chép',
                            iconColor: Color(0xFF34D399),
                            bgColor: Color(0xFFD1FAE5)
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFarmOverviewCard(),
                    const SizedBox(height: 24),
                    _buildTodayTasksCard(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng quan trang trại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem chi tiết',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng số vật nuôi',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Text(
                        _isLoading ? 'Đang tải...' : _totalLivestock.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cần chú ý',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Text(
                        '15',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasksCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Công việc hôm nay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          _buildTaskItem(Icons.local_drink, Colors.orange[500]!, 'Cho heo ăn (Lô A1)', '07:00 AM'),
          const SizedBox(height: 8),
          _buildTaskItem(Icons.cleaning_services, Colors.blue[500]!, 'Dọn dẹp chuồng gà', '09:00 AM'),
          const SizedBox(height: 8),
          _buildTaskItem(Icons.vaccines, Colors.purple[500]!, 'Tiêm phòng bò (Lô B2)', '02:00 PM'),
        ],
      ),
    );
  }

  Widget _buildTaskItem(IconData icon, Color iconColor, String title, String time) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}