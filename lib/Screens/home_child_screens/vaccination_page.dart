import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Vaccination {
  final String id;
  final String tenVaccine;
  final DateTime ngayTiem;
  final String loaiVatNuoi;

  Vaccination({
    required this.id,
    required this.tenVaccine,
    required this.ngayTiem,
    required this.loaiVatNuoi,
  });

  factory Vaccination.fromMap(String key, Map<dynamic, dynamic> value) {
    return Vaccination(
      id: key,
      tenVaccine: value['ten_vaccine'] ?? 'N/A',
      ngayTiem: DateTime.tryParse(value['ngay_tiem'] ?? '') ?? DateTime.now(),
      loaiVatNuoi: value['loai_vat_nuoi'] ?? 'N/A',
    );
  }
}

class VaccinationPage extends StatefulWidget {
  const VaccinationPage({super.key});

  @override
  State<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  DatabaseReference? _dbRef;
  List<Vaccination> _upcomingVaccinations = [];
  List<Vaccination> _pastVaccinations = [];
  bool _isLoading = true;

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
        'app_data/${user.uid}/lich_tiem_chung',
      );
      _listenToVaccinations();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _listenToVaccinations() {
    _dbRef?.onValue.listen((event) {
      if (!mounted) return;
      final now = DateTime.now();
      final List<Vaccination> upcoming = [];
      final List<Vaccination> past = [];
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final vaccination = Vaccination.fromMap(key, value);
          if (vaccination.ngayTiem.isAfter(now) ||
              vaccination.ngayTiem.isAtSameMomentAs(now)) {
            upcoming.add(vaccination);
          } else {
            past.add(vaccination);
          }
        });
      }
      upcoming.sort((a, b) => a.ngayTiem.compareTo(b.ngayTiem));
      past.sort((a, b) => b.ngayTiem.compareTo(a.ngayTiem));

      setState(() {
        _upcomingVaccinations = upcoming;
        _pastVaccinations = past;
        _isLoading = false;
      });
    });
  }

  void _showAddEditDialog({Vaccination? vaccination}) {
    final isEditing = vaccination != null;
    final nameController = TextEditingController(
      text: isEditing ? vaccination.tenVaccine : '',
    );
    final typeController = TextEditingController(
      text: isEditing ? vaccination.loaiVatNuoi : '',
    );
    DateTime selectedDate = isEditing ? vaccination.ngayTiem : DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: pageBgColor,
              title: Text(
                isEditing ? 'Sửa Lịch Tiêm' : 'Thêm Lịch Tiêm Mới',
                style: const TextStyle(color: primaryTextColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: primaryTextColor),
                      decoration: const InputDecoration(
                        labelText: 'Tên Vắc-xin',
                        labelStyle: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                    TextField(
                      controller: typeController,
                      style: const TextStyle(color: primaryTextColor),
                      decoration: const InputDecoration(
                        labelText: 'Loại Vật Nuôi',
                        labelStyle: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ngày tiêm: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                            style: const TextStyle(color: primaryTextColor),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: secondaryTextColor,
                          ),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null && picked != selectedDate) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newVaccinationData = {
                      'ten_vaccine': nameController.text,
                      'loai_vat_nuoi': typeController.text,
                      'ngay_tiem': selectedDate.toIso8601String(),
                    };

                    if (isEditing) {
                      _dbRef?.child(vaccination.id).update(newVaccinationData);
                    } else {
                      _dbRef?.push().set(newVaccinationData);
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryTextColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteVaccination(String id) {
    _dbRef?.child(id).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryTextColor),
        title: const Text(
          'Lịch Tiêm Chủng',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _dbRef == null
              ? const Center(child: Text("Vui lòng đăng nhập."))
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Lịch Sắp Tới',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _upcomingVaccinations.isEmpty
                      ? const Text(
                        'Không có lịch tiêm chủng nào sắp tới.',
                        style: TextStyle(color: primaryTextColor),
                      )
                      : Column(
                        children:
                            _upcomingVaccinations
                                .map((v) => _buildVaccinationCard(v, true))
                                .toList(),
                      ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lịch Đã Qua',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _pastVaccinations.isEmpty
                      ? const Text(
                        'Không có lịch tiêm chủng nào đã qua.',
                        style: TextStyle(color: primaryTextColor),
                      )
                      : Column(
                        children:
                            _pastVaccinations
                                .map((v) => _buildVaccinationCard(v, false))
                                .toList(),
                      ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: secondaryTextColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccination, bool isUpcoming) {
    return Card(
      color: cardBgColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          vaccination.tenVaccine,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        subtitle: Text(
          'Cho: ${vaccination.loaiVatNuoi}\nNgày: ${DateFormat('dd/MM/yyyy').format(vaccination.ngayTiem)}',
          style: const TextStyle(color: primaryTextColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUpcoming)
              IconButton(
                icon: const Icon(Icons.edit, color: secondaryTextColor),
                onPressed: () => _showAddEditDialog(vaccination: vaccination),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteVaccination(vaccination.id),
            ),
          ],
        ),
      ),
    );
  }
}
