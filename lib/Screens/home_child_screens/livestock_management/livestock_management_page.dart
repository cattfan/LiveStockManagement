import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/Screens/home_child_screens/livestock_management/livestock_model.dart';
import 'edit_livestock_page.dart';

class LivestockManagementPage extends StatefulWidget {
  const LivestockManagementPage({super.key});

  @override
  State<LivestockManagementPage> createState() => _LivestockManagementPageState();
}
class _LivestockManagementPageState extends State<LivestockManagementPage> {
  // Tham chiếu đến node 'vat_nuoi' trong Realtime Database
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
      'quan_ly_chan_nuoi/vat_nuoi');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: const Text(
          'Quản lý vật nuôi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: _dbRef.onValue, // Lắng nghe sự thay đổi dữ liệu tại node này
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Chưa có vật nuôi nào.'));
          }

          final Map<dynamic, dynamic> data = snapshot.data!.snapshot
              .value as Map<dynamic, dynamic>;
          final List<Livestock> livestockList = [];

          data.forEach((key, value) {
            // SỬA LỖI: Tạo đối tượng Livestock trực tiếp từ Map
            final livestockMap = value as Map<dynamic, dynamic>;
            livestockList.add(Livestock(
              id: key,
              ten: livestockMap['ten'] ?? '',
              chuong: livestockMap['chuong'] ?? '',
              soLuong: (livestockMap['soLuong'] ?? 0) as int,
              thucAn: livestockMap['thucAn'] ?? '',
            ));
          });

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: livestockList.length,
            itemBuilder: (context, index) {
              final livestock = livestockList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(livestock.ten, style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                      'Chuồng: ${livestock.chuong}, Số lượng: ${livestock
                          .soLuong}, Thức ăn: ${livestock.thucAn}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black54),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditLivestockPage(livestock: livestock),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng đến trang thêm mới (không truyền livestock)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditLivestockPage(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
