import 'package:flutter/material.dart';

class BarnManagementPage extends StatelessWidget {
  const BarnManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Chuồng trại',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần Tổng quan chuồng
            const Text(
              'Tổng quan chuồng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildOverviewCard('Chuồng A1', '50 con', '30 con'),
            _buildOverviewCard('Chuồng B2', '40 con', '25 con'),
            _buildOverviewCard('Chuồng C3', '60 con', '45 con'),
            const SizedBox(height: 24),
            // Phần Điều kiện chuồng
            const Text(
              'Điều kiện chuồng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildConditionCard('Chuồng A1', '28°C', '60%'),
            _buildConditionCard('Chuồng B2', '26°C', '65%'),
            _buildConditionCard('Chuồng C3', '29°C', '55%'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Tổng quan: Tên chuồng + Số lượng
  Widget _buildOverviewCard(String name, String max, String used) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity, // Kéo dài chiều ngang
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tối đa: $max - Đang sử dụng: $used',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Điều kiện: Tên chuồng + Nhiệt độ + Độ ẩm
  Widget _buildConditionCard(String name, String temperature, String humidity) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity, // Kéo dài chiều ngang
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhiệt độ: $temperature - Độ ẩm: $humidity',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
