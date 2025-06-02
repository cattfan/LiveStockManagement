import 'package:flutter/material.dart';

class StorageManagementPage extends StatelessWidget {
  const StorageManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),  // Màu mũi tên
        centerTitle: true,
        title: Text(
          'Quan lý Vật tư',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân loại Vật tư',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildStorageItem(
                    context,
                    title: 'Thức ăn',
                    subtitle: 'Số lượng: 200 kg',
                    onEdit: () {
                      // Chuyển sang trang chỉnh sửa hoặc hiển thị dialog
                    },
                  ),
                  _buildStorageItem(
                    context,
                    title: 'Thuốc',
                    subtitle: 'Số lượng: 50 chai',
                    onEdit: () {},
                  ),
                  _buildStorageItem(
                    context,
                    title: 'Dụng cụ',
                    subtitle: 'Số lượng: 100 bộ',
                    onEdit: () {},
                  ),
                  _buildStorageItem(
                    context,
                    title: 'Vật tư khác',
                    subtitle: 'Số lượng: 30 thùng',
                    onEdit: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageItem(BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
