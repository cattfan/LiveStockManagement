// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:livestockmanagement/models/note_model.dart';
import 'package:livestockmanagement/widgets/feature_card.dart';
import 'package:livestockmanagement/Screens/home_child_screens/vaccination_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/storage_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/feed_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/barn_management_page.dart';
import 'home_child_screens/livestock_management/livestock_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/note_page/note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalLivestock = 0;
  bool _isLoading = true;
  int _noteCount = 0;
  List<Note> _todayNotes = [];
  String _userName = ''; // Biến lưu tên người dùng

  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchTotalLivestock();
    _fetchNoteCount();
    _fetchTodayNotes();
  }

  // Hàm lấy tên người dùng từ Firebase Realtime Database
  Future<void> _fetchUserName() async {
    if (_user == null) return;

    final userRef = FirebaseDatabase.instance.ref('users/${_user.uid}');
    try {
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _userName = data['name'] ?? '';
        });
      }
    } catch (e) {
      // Có thể thêm xử lý lỗi tại đây nếu cần
      debugPrint('Lỗi khi lấy tên người dùng: $e');
    }
  }

  void _fetchTodayNotes() {
    DatabaseReference notesRef = FirebaseDatabase.instance.ref('notes');
    notesRef.onValue.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && mounted) {
        final notesMap = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Note> loadedNotes = [];
        final today = DateTime.now();

        notesMap.forEach((key, value) {
          final noteData = Map<String, dynamic>.from(value);
          final reminderDateStr = noteData['reminderDate'];
          if (reminderDateStr != null) {
            final reminderDate = DateTime.tryParse(reminderDateStr);
            if (reminderDate != null &&
                reminderDate.year == today.year &&
                reminderDate.month == today.month &&
                reminderDate.day == today.day) {
              loadedNotes.add(
                Note(
                  key: key,
                  title: noteData['title'] ?? 'Không có tiêu đề',
                  content: noteData['content'] ?? '',
                  reminderDate: reminderDate,
                ),
              );
            }
          }
        });

        loadedNotes.sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

        setState(() {
          _todayNotes = loadedNotes;
        });
      }
    }, onError: (error) {});
  }

  void _fetchTotalLivestock() {
    DatabaseReference vatnuoiRef = FirebaseDatabase.instance.ref('Vatnuoi');
    vatnuoiRef.onValue.listen(
      (DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          int sum = 0;
          data.forEach((key, value) {
            final animalData = value as Map<dynamic, dynamic>;
            final quantity =
                int.tryParse(animalData['Soluong'].toString()) ?? 0;
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
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  void _fetchNoteCount() {
    DatabaseReference notesRef = FirebaseDatabase.instance.ref('notes');
    notesRef.onValue.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final value = snapshot.value;

        int count = 0;

        if (value is Map) {
          count = value.length;
        }

        if (mounted) {
          setState(() {
            _noteCount = count;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _noteCount = 0;
          });
        }
      }
    }, onError: (error) {});
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
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      bottom: 80.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Column(
                      children: [
                        SafeArea(
                          bottom: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
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
                            child: const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName.isNotEmpty
                                    ? 'Xin chào, $_userName!'
                                    : 'Xin chào!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
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
              padding: const EdgeInsets.only(
                top: 22.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Chức năng chính',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      FeatureCard(
                        icon: Icons.savings_outlined,
                        label: 'Quản lý Vật nuôi',
                        iconColor: const Color(0xFF34D399),
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const LivestockManagementPage(),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        icon: Icons.home_work_outlined,
                        label: 'Quản lý Chuồng trại',
                        iconColor: const Color(0xFF34D399),
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BarnManagementPage(),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        icon: Icons.grass_outlined,
                        label: 'Quản lý Thức ăn',
                        iconColor: const Color(0xFF34D399),
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedManagementPage(),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        icon: Icons.vaccines_outlined,
                        label: 'Lịch tiêm chủng',
                        iconColor: const Color(0xFF34D399),
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VaccinationPage(),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        icon: Icons.storage_outlined,
                        label: 'Quản lý kho',
                        iconColor: const Color(0xFF34D399),
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StorageManagementPage(),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        icon: Icons.note_alt_outlined,
                        label: 'Ghi chú',
                        iconColor: const Color(0xFF34D399),
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotesListPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticsSection(),
                  const SizedBox(height: 24),
                  _buildNoteRemindersSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              _buildStatisticItem(
                icon: Icons.pets_outlined,
                label: 'Tổng số vật nuôi',
                value: _isLoading ? '...' : '$_totalLivestock',
                iconColor: Colors.green[600],
              ),
              const SizedBox(width: 24),
              _buildStatisticItem(
                icon: Icons.note_alt_outlined,
                label: 'Số ghi chú',
                value: '$_noteCount',
                iconColor: Colors.green[600],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticItem({
    required IconData icon,
    required String label,
    required String value,
    required Color? iconColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800])),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lời nhắc hôm nay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: BoxConstraints(maxHeight: 320),
          child: _todayNotes.isEmpty
              ? const Center(
                  child: Text('Không có lời nhắc nào hôm nay.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _todayNotes.length,
                  itemBuilder: (context, index) {
                    final note = _todayNotes[index];
                    final formattedDate = DateFormat('HH:mm').format(note.reminderDate!);
                    return ListTile(
                      leading: const Icon(Icons.notification_add_outlined),
                      title: Text(note.title),
                      subtitle: Text(formattedDate),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
