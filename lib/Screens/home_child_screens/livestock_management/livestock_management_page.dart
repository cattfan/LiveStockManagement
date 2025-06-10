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
  DatabaseReference? _livestockRef;
  DatabaseReference? _barnRef;
  DatabaseReference? _feedRef;

  Map<String, String> _barnIdToNameMap = {};
  Map<String, String> _feedIdToNameMap = {};
  bool _isLoading = true;

  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color cardBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _livestockRef = FirebaseDatabase.instance.ref(
        'app_data/$userId/vat_nuoi',
      );
      _barnRef = FirebaseDatabase.instance.ref('app_data/$userId/chuong_trai');
      _feedRef = FirebaseDatabase.instance.ref('app_data/$userId/thuc_an');
      _fetchDependencies();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDependencies() async {
    if (_barnRef == null || _feedRef == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    ;

    final results = await Future.wait([_barnRef!.get(), _feedRef!.get()]);

    final barnSnapshot = results[0];
    if (barnSnapshot.exists && barnSnapshot.value is Map) {
      final data = Map<String, dynamic>.from(barnSnapshot.value as Map);
      final Map<String, String> loadedBarns = {};
      data.forEach((key, value) {
        final barnData = Map<String, dynamic>.from(value as Map);
        loadedBarns[key] = barnData['name'] ?? 'Chuồng không tên';
      });
      _barnIdToNameMap = loadedBarns;
    }

    final feedSnapshot = results[1];
    if (feedSnapshot.exists && feedSnapshot.value is Map) {
      final data = Map<String, dynamic>.from(feedSnapshot.value as Map);
      final Map<String, String> loadedFeeds = {};
      data.forEach((key, value) {
        final feedData = Map<String, dynamic>.from(value as Map);
        loadedFeeds[key] = feedData['ten'] ?? 'Thức ăn không tên';
      });
      _feedIdToNameMap = loadedFeeds;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: pageBgColor,
        appBar: AppBar(
          backgroundColor: pageBgColor,
          elevation: 0,
          title: const Text(
            'Quản lý vật nuôi',
            style: TextStyle(color: primaryTextColor),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_livestockRef == null) {
      return Scaffold(
        backgroundColor: pageBgColor,
        appBar: AppBar(
          backgroundColor: pageBgColor,
          elevation: 0,
          title: const Text(
            'Quản lý vật nuôi',
            style: TextStyle(color: primaryTextColor),
          ),
        ),
        body: const Center(child: Text("Vui lòng đăng nhập để xem dữ liệu.")),
      );
    }
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        leading: const BackButton(color: primaryTextColor),
        backgroundColor: pageBgColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Quản lý vật nuôi',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _livestockRef!.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Không thể tìm thấy vật nuôi.'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Chưa có vật nuôi nào.'));
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          final List<Livestock> livestockList = [];

          data.forEach((key, value) {
            livestockList.add(
              Livestock.fromSnapshot(snapshot.data!.snapshot.child(key)),
            );
          });

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: livestockList.length,
            itemBuilder: (context, index) {
              final livestock = livestockList[index];
              final barnName =
                  _barnIdToNameMap[livestock.chuong] ?? 'Không xác định';
              final feedName =
                  _feedIdToNameMap[livestock.thucAn] ?? 'Không xác định';
              return Card(
                color: cardBgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    livestock.ten,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryTextColor,
                    ),
                  ),
                  subtitle: Text(
                    'Loại: ${livestock.loai} | Số lượng: ${livestock.soLuong}\nChuồng: $barnName\nThức ăn: $feedName',
                    style: const TextStyle(color: primaryTextColor),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: secondaryTextColor),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AddEditLivestockPage(livestock: livestock),
                        ),
                      );
                      _fetchDependencies();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditLivestockPage(),
            ),
          );
          _fetchDependencies();
        },
        backgroundColor: secondaryTextColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
