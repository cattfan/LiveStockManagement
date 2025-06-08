import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:livestockmanagement/models/note_model.dart';
import 'package:livestockmanagement/widgets/feature_card.dart';
import 'package:livestockmanagement/Screens/home_child_screens/vaccination_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/storage_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/feed_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/barn_management_page.dart';
import 'home_child_screens/livestock_management/livestock_management_page.dart';
import 'livestock_page.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchTotalLivestock();
    _fetchNoteCount();
    _fetchTodayNotes();
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
                                'Xin chào, An Nguyễn!',
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
                        icon: Icons.inventory_2_outlined,
                        label: 'Quản lý Kho',
                        iconColor: const Color(0xFF34D399),
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const StorageManagementPage(),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        icon: Icons.receipt_long_outlined,
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
                  const SizedBox(height: 24),
                  _buildFarmOverviewCard(),
                  const SizedBox(height: 24),
                  _buildTodayTasksCard(),
                  const SizedBox(height: 80),
                ]),
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
                        'Tổng số ghi chú',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Text(
                        _isLoading ? 'Đang tải...' : _noteCount.toString(),
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Công việc hôm nay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          _todayNotes.isEmpty
              ? Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                child: Center(
                  child: Text(
                    'Không có công việc nào cho hôm nay.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ),
              )
              : ListView.separated(
                itemCount: _todayNotes.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final note = _todayNotes[index];
                  final time =
                      note.reminderDate != null
                          ? DateFormat('HH:mm a').format(note.reminderDate!)
                          : '';
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotesListPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: _buildTaskItem(
                      Icons.receipt_long_outlined,
                      Colors.blue[500]!,
                      note.title,
                      time,
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 4),
              ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    IconData icon,
    Color iconColor,
    String title,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
