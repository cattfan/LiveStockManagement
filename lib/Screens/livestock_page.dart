import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Livestock {
  final String id;
  final String ten;
  final String chuong;
  final int soLuong;
  final String thucAn;
  final String imageUrl;

  Livestock({
    required this.id,
    required this.ten,
    required this.chuong,
    required this.soLuong,
    required this.thucAn,
    required this.imageUrl,
  });

  factory Livestock.fromMap(
    String id,
    Map<dynamic, dynamic> map,
    String imageUrl,
  ) {
    return Livestock(
      id: id,
      ten: map['ten']?.toString() ?? 'Không có tên',
      chuong: map['chuong']?.toString() ?? 'Không xác định',
      soLuong: int.tryParse(map['soLuong']?.toString() ?? '0') ?? 0,
      thucAn: map['thucAn']?.toString() ?? 'Không xác định',
      imageUrl: imageUrl,
    );
  }
}

class LivestockGridScreen extends StatefulWidget {
  const LivestockGridScreen({super.key});
  @override
  _LivestockGridScreenState createState() => _LivestockGridScreenState();
}

class _LivestockGridScreenState extends State<LivestockGridScreen> {
  DatabaseReference? _ref;
  List<Livestock> _livestockList = [];
  bool _loading = true;

  final Map<String, String> imageMap = {
    'BÒ':
        'https://plus.unsplash.com/premium_photo-1661962510497-9505129083fa?q=80',
    'Heo trắng':
        'https://images.unsplash.com/photo-1567201080580-bfcc97dae346?q=80',
    'Gà ta':
        'https://images.unsplash.com/photo-1644217147354-17d6e38108c6?w=600',
    'Dê':
        'https://plus.unsplash.com/premium_photo-1681882343875-0c709293d624?q=80',
    'Vịt siêm':
        'https://images.unsplash.com/photo-1465153690352-10c1b29577f8?q=80',
  };

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _ref = FirebaseDatabase.instance.ref(
        "app_data/${user.uid}/quan_ly_chan_nuoi/vat_nuoi",
      );
      fetchLivestock();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> fetchLivestock() async {
    if (_ref == null) return;
    try {
      final snapshot = await _ref!.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final tempList = <Livestock>[];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final name = value['ten']?.toString() ?? '';
            final imageUrl =
                imageMap[name] ?? 'https://via.placeholder.com/150';

            tempList.add(Livestock.fromMap(key.toString(), value, imageUrl));
          }
        });

        if (mounted) {
          setState(() {
            _livestockList = tempList;
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Quản lý vật nuôi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _ref == null
              ? const Center(child: Text("Vui lòng đăng nhập."))
              : _livestockList.isEmpty
              ? const Center(child: Text('Không có vật nuôi nào'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _livestockList.length,
                  itemBuilder: (context, index) {
                    final animal = _livestockList[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => LivestockDetailScreen(
                                    livestock: animal,
                                    key: ValueKey(animal.id),
                                  ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  animal.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.error, size: 50),
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    animal.ten,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Số lượng: ${animal.soLuong}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class LivestockDetailScreen extends StatelessWidget {
  final Livestock livestock;

  const LivestockDetailScreen({super.key, required this.livestock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          livestock.ten,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  livestock.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Tên: ${livestock.ten}", style: const TextStyle(fontSize: 18)),
            Text(
              "Số lượng: ${livestock.soLuong}",
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "Thức ăn: ${livestock.thucAn}",
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "Chuồng: ${livestock.chuong}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
