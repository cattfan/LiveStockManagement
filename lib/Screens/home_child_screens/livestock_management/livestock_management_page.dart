import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/Screens/home_child_screens/livestock_management/livestock_model.dart';
import 'edit_livestock_page.dart';

class LivestockManagementPage extends StatefulWidget {
  const LivestockManagementPage({super.key});

  @override
  State<LivestockManagementPage> createState() =>
      _LivestockManagementPageState();
}

class _LivestockManagementPageState extends State<LivestockManagementPage> {
  DatabaseReference? _dbRef;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _dbRef = FirebaseDatabase.instance.ref('app_data/$userId/vat_nuoi');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dbRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý vật nuôi')),
        body: const Center(child: Text("Vui lòng đăng nhập để xem dữ liệu.")),
      );
    }
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
        stream: _dbRef!.onValue,
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

          // Using a Map<String, dynamic> is safer
          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          final List<Livestock> livestockList = [];

          data.forEach((key, value) {
            final livestockMap = Map<String, dynamic>.from(value as Map);
            livestockList.add(
              Livestock(
                id: key,
                ten: livestockMap['ten'] ?? '',
                chuong: livestockMap['chuong'] ?? '',
                soLuong: (livestockMap['soLuong'] ?? 0) as int,
                thucAn: livestockMap['thucAn'] ?? '',
              ),
            );
          });

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: livestockList.length,
            itemBuilder: (context, index) {
              final livestock = livestockList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    livestock.ten,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Chuồng: ${livestock.chuong}, Số lượng: ${livestock.soLuong}, Thức ăn: ${livestock.thucAn}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black54),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
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
