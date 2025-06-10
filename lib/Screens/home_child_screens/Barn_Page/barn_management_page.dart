import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/barn_model.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/add_edit_barn_page.dart';

class BarnManagementPage extends StatefulWidget {
  const BarnManagementPage({super.key});

  @override
  State<BarnManagementPage> createState() => _BarnManagementPageState();
}

class _BarnManagementPageState extends State<BarnManagementPage> {
  DatabaseReference? _dbRef;
  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color cardBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbRef = FirebaseDatabase.instance.ref(
        'app_data/${user.uid}/chuong_trai',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        leading: const BackButton(color: primaryTextColor),
        backgroundColor: pageBgColor,
        centerTitle: true,
        title: const Text(
          'Quản lý chuồng trại',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body:
          _dbRef == null
              ? const Center(child: Text('Vui lòng đăng nhập để xem dữ liệu.'))
              : StreamBuilder(
                stream: _dbRef!.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Text('Chưa có chuồng trại nào.'),
                    );
                  }

                  final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );
                  final List<Barn> barnList = [];

                  data.forEach((key, value) {
                    barnList.add(
                      Barn.fromSnapshot(snapshot.data!.snapshot.child(key)),
                    );
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: barnList.length,
                    itemBuilder: (context, index) {
                      final barn = barnList[index];
                      return Card(
                        color: cardBgColor,
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(
                            barn.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Sức chứa: ${barn.used}/${barn.capacity}',
                                style: const TextStyle(color: primaryTextColor),
                              ),
                              if (barn.temp.isNotEmpty)
                                Text(
                                  'Nhiệt độ: ${barn.temp}',
                                  style: const TextStyle(
                                    color: primaryTextColor,
                                  ),
                                ),
                              if (barn.humidity.isNotEmpty)
                                Text(
                                  'Độ ẩm: ${barn.humidity}',
                                  style: const TextStyle(
                                    color: primaryTextColor,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: secondaryTextColor,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddEditBarnPage(barn: barn),
                                ),
                              );
                            },
                          ),
                          isThreeLine: true,
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
            MaterialPageRoute(builder: (context) => const AddEditBarnPage()),
          );
        },
        backgroundColor: secondaryTextColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
