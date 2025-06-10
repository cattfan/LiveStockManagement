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

  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color cardBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

  // --- DỮ LIỆU MỚI CHO DROPDOWN PHỤ THUỘC ---
  final List<String> _animalTypes = ['Gia súc', 'Gia cầm'];

  final Map<String, List<String>> _vaccineData = {
    'Gia súc': [
      'Vắc xin Dịch tả lợn',
      'Vắc xin Tụ huyết trùng',
      'Vắc xin Phó thương hàn',
      'Vắc xin Lở mồm long móng',
      'Vắc xin Tai xanh (PRRS)',
      'Vắc xin Viêm da nổi cục',
      'Khác',
    ],
    'Gia cầm': [
      'Vắc xin Cúm gia cầm (H5N1)',
      'Vắc xin Gumboro',
      'Vắc xin Newcastle',
      'Vắc xin Dịch tả vịt',
      'Vắc xin Đậu gà',
      'Vắc xin Viêm phế quản truyền nhiễm',
      'Vắc xin Tụ huyết trùng gia cầm',
      'Khác',
    ],
  };

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbRef = FirebaseDatabase.instance.ref(
        'app_data/${user.uid}/lich_tiem_chung',
      );
    }
  }

  void _showAddEditDialog({Vaccination? vaccination}) {
    final isEditing = vaccination != null;
    String? selectedAnimalType = isEditing ? vaccination.loaiVatNuoi : null;
    String? selectedVaccine = isEditing ? vaccination.tenVaccine : null;
    DateTime selectedDate = isEditing ? vaccination.ngayTiem : DateTime.now();
    final otherVaccineController = TextEditingController();
    bool isOtherSelected = false;

    // Xác định logic cho trường hợp chỉnh sửa
    if (isEditing) {
      // Kiểm tra xem vắc-xin có trong danh sách định sẵn của loại vật nuôi không
      if (_vaccineData[vaccination.loaiVatNuoi]?.contains(
            vaccination.tenVaccine,
          ) ??
          false) {
        selectedVaccine = vaccination.tenVaccine;
      } else {
        // Nếu không, đó là loại 'Khác'
        selectedVaccine = 'Khác';
        isOtherSelected = true;
        otherVaccineController.text = vaccination.tenVaccine;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Lấy danh sách vắc-xin dựa trên loại vật nuôi đã chọn
            final List<String> availableVaccines =
                _vaccineData[selectedAnimalType] ?? [];

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
                    // --- DROPDOWN LOẠI VẬT NUÔI ---
                    DropdownButtonFormField<String>(
                      value: selectedAnimalType,
                      decoration: const InputDecoration(
                        labelText: 'Loại Vật Nuôi',
                        labelStyle: TextStyle(color: secondaryTextColor),
                      ),
                      items:
                          _animalTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: primaryTextColor),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedAnimalType = newValue;
                          // Reset lựa chọn vắc-xin khi đổi loại vật nuôi
                          selectedVaccine = null;
                          isOtherSelected = false;
                        });
                      },
                      validator:
                          (value) =>
                              value == null
                                  ? 'Vui lòng chọn loại vật nuôi'
                                  : null,
                    ),

                    // --- DROPDOWN TÊN VẮC-XIN (PHỤ THUỘC) ---
                    if (selectedAnimalType != null)
                      DropdownButtonFormField<String>(
                        value: selectedVaccine,
                        decoration: const InputDecoration(
                          labelText: 'Tên Vắc-xin',
                          labelStyle: TextStyle(color: secondaryTextColor),
                        ),
                        items:
                            availableVaccines.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: primaryTextColor,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedVaccine = newValue;
                            isOtherSelected = newValue == 'Khác';
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Vui lòng chọn vắc-xin' : null,
                      ),

                    // --- Ô NHẬP LIỆU KHI CHỌN "KHÁC" ---
                    if (isOtherSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextField(
                          controller: otherVaccineController,
                          style: const TextStyle(color: primaryTextColor),
                          decoration: const InputDecoration(
                            labelText: 'Nhập tên vắc-xin khác',
                            labelStyle: TextStyle(color: secondaryTextColor),
                          ),
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
                    final finalVaccineName =
                        isOtherSelected
                            ? otherVaccineController.text
                            : selectedVaccine;

                    if (finalVaccineName == null ||
                        finalVaccineName.isEmpty ||
                        selectedAnimalType == null) {
                      return;
                    }

                    final newVaccinationData = {
                      'ten_vaccine': finalVaccineName,
                      'loai_vat_nuoi': selectedAnimalType,
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

  Future<void> _showDeleteConfirmationDialog(String vaccinationId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa lịch tiêm này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Có'),
              onPressed: () {
                _dbRef?.child(vaccinationId).remove();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 8.0,
        left: 4.0,
        right: 4.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVaccinationItem(Vaccination vaccination) {
    return Card(
      color: cardBgColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        title: Text(
          vaccination.tenVaccine,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: primaryTextColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dành cho: ${vaccination.loaiVatNuoi}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: primaryTextColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: secondaryTextColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(vaccination.ngayTiem),
                      style: const TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () => _showAddEditDialog(vaccination: vaccination),
        onLongPress: () => _showDeleteConfirmationDialog(vaccination.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: primaryTextColor),
        backgroundColor: pageBgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Lịch Tiêm Chủng',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body:
          _dbRef == null
              ? const Center(
                child: Text("Vui lòng đăng nhập để xem lịch tiêm."),
              )
              : StreamBuilder(
                stream: _dbRef!.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return const Center(
                      child: Text(
                        'Chưa có lịch tiêm nào.',
                        style: TextStyle(color: primaryTextColor),
                      ),
                    );
                  }

                  final List<Vaccination> todayVaccinations = [];
                  final List<Vaccination> upcomingVaccinations = [];
                  final List<Vaccination> pastVaccinations = [];
                  final now = DateTime.now();
                  final startOfToday = DateTime(now.year, now.month, now.day);

                  final dataMap = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );

                  dataMap.forEach((key, value) {
                    final vaccination = Vaccination.fromMap(key, value);
                    final vaccinationDay = DateTime(
                      vaccination.ngayTiem.year,
                      vaccination.ngayTiem.month,
                      vaccination.ngayTiem.day,
                    );

                    if (vaccinationDay.isAtSameMomentAs(startOfToday)) {
                      todayVaccinations.add(vaccination);
                    } else if (vaccination.ngayTiem.isAfter(now)) {
                      upcomingVaccinations.add(vaccination);
                    } else {
                      pastVaccinations.add(vaccination);
                    }
                  });

                  todayVaccinations.sort(
                    (a, b) => a.ngayTiem.compareTo(b.ngayTiem),
                  );
                  upcomingVaccinations.sort(
                    (a, b) => a.ngayTiem.compareTo(b.ngayTiem),
                  );
                  pastVaccinations.sort(
                    (a, b) => b.ngayTiem.compareTo(a.ngayTiem),
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todayVaccinations.isNotEmpty)
                          _buildSectionTitle('Lịch tiêm trong ngày'),
                        ...todayVaccinations.map(
                          (v) => _buildVaccinationItem(v),
                        ),
                        if (upcomingVaccinations.isNotEmpty)
                          _buildSectionTitle('Lịch tiêm sắp tới'),
                        ...upcomingVaccinations.map(
                          (v) => _buildVaccinationItem(v),
                        ),
                        if (pastVaccinations.isNotEmpty)
                          _buildSectionTitle('Lịch tiêm đã qua'),
                        ...pastVaccinations.map(
                          (v) => _buildVaccinationItem(v),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: secondaryTextColor,
        elevation: 1,
        child: const Icon(Icons.add, color: pageBgColor),
      ),
    );
  }
}
