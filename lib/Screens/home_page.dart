import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:livestockmanagement/Screens/home_child_screens/note_page/note_model.dart';
import 'package:livestockmanagement/Screens/home_child_screens/note_page/note_page.dart';
import 'package:livestockmanagement/widgets/feature_card.dart';
import 'package:livestockmanagement/Screens/home_child_screens/vaccination_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/storage_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/feed_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/barn_management_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/livestock_management/livestock_management_page.dart';

class _TodayTask {
  final String title;
  final DateTime time;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  _TodayTask({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalLivestock = 0;
  int _noteCount = 0;
  int _upcomingVaccinationCount = 0;
  List<Note> _allNotes = [];
  List<_TodayTask> _todayTasks = [];

  bool _isLoading = true;

  DatabaseReference? _userRef;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userRef = FirebaseDatabase.instance.ref('app_data/${user.uid}');
      _fetchTotalLivestock();
      _listenToNotes();
      _listenToVaccinations();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _listenToNotes() {
    _userRef?.child('ghi_chu').onValue.listen((event) {
      if (!mounted) return;
      final List<Note> loadedNotes = [];
      int count = 0;
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final notesMap = Map<String, dynamic>.from(event.snapshot.value as Map);
        count = notesMap.length;
        notesMap.forEach((key, value) {
          final noteData = Map<String, dynamic>.from(value);
          loadedNotes.add(
            Note(
              key: key,
              title: noteData['title'] ?? 'Không có tiêu đề',
              content: noteData['content'] ?? '',
              reminderDate:
                  noteData['reminderDate'] != null
                      ? DateTime.tryParse(noteData['reminderDate'])
                      : null,
            ),
          );
        });
      }
      _allNotes = loadedNotes;
      if (mounted) {
        setState(() {
          _noteCount = count;
        });
        _combineAndSortTodayTasks();
      }
    });
  }

  void _listenToVaccinations() {
    _userRef?.child('lich_tiem_chung').onValue.listen((event) {
      if (!mounted) return;
      int upcomingCount = 0;
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = event.snapshot.value as Map;
        data.forEach((key, value) {
          final vaccinationData = value as Map;
          final vaccinationDateStr = vaccinationData['ngay_tiem'];
          if (vaccinationDateStr != null) {
            final vaccinationDate = DateTime.tryParse(vaccinationDateStr);
            if (vaccinationDate != null &&
                !vaccinationDate.isBefore(startOfToday)) {
              upcomingCount++;
            }
          }
        });
      }

      if (mounted) {
        setState(() {
          _upcomingVaccinationCount = upcomingCount;
        });
        _combineAndSortTodayTasks();
      }
    });
  }

  void _combineAndSortTodayTasks() {
    final List<_TodayTask> combinedTasks = [];
    final today = DateTime.now();

    final todayNotes =
        _allNotes.where((note) {
          if (note.reminderDate == null) return false;
          return note.reminderDate!.year == today.year &&
              note.reminderDate!.month == today.month &&
              note.reminderDate!.day == today.day;
        }).toList();

    _userRef?.child('lich_tiem_chung').get().then((snapshot) {
      if (snapshot.exists && snapshot.value is Map) {
        final data = snapshot.value as Map;
        data.forEach((key, value) {
          final vaccinationData = value as Map;
          final vaccinationDate = DateTime.tryParse(
            vaccinationData['ngay_tiem'] ?? '',
          );
          if (vaccinationDate != null &&
              vaccinationDate.year == today.year &&
              vaccinationDate.month == today.month &&
              vaccinationDate.day == today.day) {
            combinedTasks.add(
              _TodayTask(
                title: vaccinationData['ten_vaccine'] ?? 'Lịch tiêm',
                time: vaccinationDate,
                icon: Icons.vaccines_outlined,
                iconColor: Colors.red[400]!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VaccinationPage(),
                      ),
                    ),
              ),
            );
          }
        });
      }

      for (var note in todayNotes) {
        combinedTasks.add(
          _TodayTask(
            title: note.title,
            time: note.reminderDate!,
            icon: Icons.receipt_long_outlined,
            iconColor: Colors.blue[500]!,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotesListPage(),
                  ),
                ),
          ),
        );
      }

      combinedTasks.sort((a, b) => a.time.compareTo(b.time));

      if (mounted) {
        setState(() {
          _todayTasks = combinedTasks;
        });
      }
    });
  }

  void _fetchTotalLivestock() {
    _userRef
        ?.child('vat_nuoi')
        .onValue
        .listen(
          (DatabaseEvent event) {
            if (!mounted) return;
            int sum = 0;
            if (event.snapshot.exists && event.snapshot.value is Map) {
              final data = event.snapshot.value as Map;
              data.forEach((key, value) {
                final animalData = value as Map;
                final quantity =
                    int.tryParse(animalData['soLuong']?.toString() ?? '0') ?? 0;
                sum += quantity;
              });
            }
            if (mounted) {
              setState(() {
                _totalLivestock = sum;
                _isLoading = false;
              });
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final constrainedWidth = screenWidth > 500 ? 500.0 : screenWidth;

    if (_userRef == null) {
      return const Center(child: Text("Không có người dùng đăng nhập."));
    }

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
                              StreamBuilder<User?>(
                                stream: FirebaseAuth.instance.userChanges(),
                                builder: (context, snapshot) {
                                  final userName =
                                      snapshot.data?.displayName ??
                                      snapshot.data?.email ??
                                      'User';
                                  return Text(
                                    'Xin chào, $userName!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  );
                                },
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
                  // ******** ĐÃ XÓA DÒNG CHỮ "CHỨC NĂNG CHÍNH" TẠI ĐÂY ********
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
                        label: 'Quản lý Vật tư',
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

  Widget _buildOverviewItem(
    String title,
    String value,
    Color valueColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              _isLoading ? '...' : value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmOverviewCard() {
    final int notableCount = _upcomingVaccinationCount + _noteCount;

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
          Text(
            'Tổng quan trang trại',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOverviewItem(
                'Tổng vật nuôi',
                _totalLivestock.toString(),
                Colors.green[700]!,
                Colors.green[50]!,
              ),
              const SizedBox(width: 12),
              _buildOverviewItem(
                'Đáng chú ý',
                notableCount.toString(),
                Colors.orange[700]!,
                Colors.orange[50]!,
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
          _todayTasks.isEmpty
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
                itemCount: _todayTasks.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final task = _todayTasks[index];
                  final time = DateFormat('HH:mm a').format(task.time);
                  return InkWell(
                    onTap: task.onTap,
                    borderRadius: BorderRadius.circular(8.0),
                    child: _buildTaskItem(
                      task.icon,
                      task.iconColor,
                      task.title,
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
