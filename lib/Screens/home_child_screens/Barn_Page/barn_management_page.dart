import 'package:flutter/material.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/all_barn_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/edit_barn_page.dart';
import 'add_barn_page.dart';

class BarnManagementPage extends StatefulWidget {
  const BarnManagementPage({super.key});

  @override
  State<BarnManagementPage> createState() => _BarnManagementPageState();
}

class _BarnManagementPageState extends State<BarnManagementPage> {
  List<Map<String, dynamic>> barns = [
    {'name': 'Chuồng A1', 'max': 50, 'used': 30, 'temp': '28°C', 'humidity': '60%'},
    {'name': 'Chuồng B2', 'max': 40, 'used': 25, 'temp': '26°C', 'humidity': '65%'},
    {'name': 'Chuồng C3', 'max': 60, 'used': 45, 'temp': '29°C', 'humidity': '55%'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Chuồng trại',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần tiêu đề và nút xem toàn bộ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng quan chuồng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    final updatedBarns = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllBarnPage(barns: barns),
                      ),
                    );

                    if (updatedBarns != null) {
                      setState(() {
                        barns = List<Map<String, dynamic>>.from(updatedBarns);
                      });
                    }
                  },
                  child: const Text(
                    'Xem toàn bộ',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...barns.take(2).map((barn) => _buildOverviewCard(barn)).toList(), // Chỉ 2 chuồng

            const SizedBox(height: 24),
            const Text(
              'Điều kiện chuồng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...barns.take(2).map((barn) => _buildConditionCard(barn)).toList(), // Chỉ 2 chuồng
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBarnPage()),
          );

          if (result != null) {
            // Thêm result vào danh sách chuồng nuôi
            setState(() {
              barns.add({
                'name': result['name'],
                'max': result['capacity'],
                'used': result['used'],
                'temp': result['temp'],
                'humidity': result['humidity'],
              });
            });
          }

        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> barn) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          barn['name'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Tối đa: ${barn['max']} - Đang sử dụng: ${barn['used']}',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
         onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditBarnPage(barnData: barn),
    ),
  );
  if (result != null) {
    setState(() {
      barn['name'] = result['name'];
      barn['max'] = result['capacity'];
    });
  }
},

        ),
      ),
    );
  }

  Widget _buildConditionCard(Map<String, dynamic> barn) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          barn['name'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Nhiệt độ: ${barn['temp']} - Độ ẩm: ${barn['humidity']}',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ),
    );
  }
}
