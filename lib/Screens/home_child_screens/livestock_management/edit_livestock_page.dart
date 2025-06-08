import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/Screens/home_child_screens/livestock_management/livestock_model.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/barn_model.dart';

class Feed {
  final String id;
  final String ten;
  Feed({required this.id, required this.ten});
}

class AddEditLivestockPage extends StatefulWidget {
  final Livestock? livestock;
  const AddEditLivestockPage({super.key, this.livestock});

  @override
  State<AddEditLivestockPage> createState() => _AddEditLivestockPageState();
}

class _AddEditLivestockPageState extends State<AddEditLivestockPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenController;
  late TextEditingController _soLuongController;

  String? _selectedType; // State cho loại vật nuôi
  String? _selectedBarnId;
  String? _selectedFeedId;
  String? _oldBarnId;
  int _oldSoLuong = 0;

  final List<String> _livestockTypes = ['Gia súc', 'Gia cầm'];

  DatabaseReference? _livestockRef;
  DatabaseReference? _barnRef;
  DatabaseReference? _feedRef;

  StreamSubscription? _barnSubscription;
  StreamSubscription? _feedSubscription;

  List<Barn> _barnList = [];
  List<Feed> _feedList = [];
  bool _isLoading = true;

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
      _setupListeners();
    } else {
      setState(() => _isLoading = false);
    }

    _tenController = TextEditingController(text: widget.livestock?.ten ?? '');
    _soLuongController = TextEditingController(
      text: widget.livestock?.soLuong.toString() ?? '',
    );

    if (widget.livestock != null) {
      _selectedType = widget.livestock!.loai;
      _selectedBarnId = widget.livestock!.chuong;
      _selectedFeedId = widget.livestock!.thucAn;
      _oldBarnId = widget.livestock!.chuong;
      _oldSoLuong = widget.livestock!.soLuong;
    } else {
      _selectedType = _livestockTypes[0];
    }
  }

  void _setupListeners() {
    if (_barnRef == null || _feedRef == null) {
      setState(() => _isLoading = false);
      return;
    }
    ;

    _barnSubscription = _barnRef!.onValue.listen((event) {
      if (!mounted) return;
      final List<Barn> loadedBarns = [];
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final barnData = Map<String, dynamic>.from(event.snapshot.value as Map);
        barnData.forEach((key, value) {
          loadedBarns.add(Barn.fromSnapshot(event.snapshot.child(key)));
        });
      }
      setState(() {
        _barnList = loadedBarns;
      });
      _checkLoading();
    });

    _feedSubscription = _feedRef!.onValue.listen((event) {
      if (!mounted) return;
      final List<Feed> loadedFeeds = [];
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final feedData = Map<String, dynamic>.from(event.snapshot.value as Map);
        feedData.forEach((key, value) {
          final feedMap = value as Map;
          loadedFeeds.add(
            Feed(id: key, ten: feedMap['ten'] ?? 'Thức ăn không tên'),
          );
        });
      }
      setState(() {
        _feedList = loadedFeeds;
      });
      _checkLoading();
    });
  }

  void _checkLoading() {
    if (mounted && _barnSubscription != null && _feedSubscription != null) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _soLuongController.dispose();
    _barnSubscription?.cancel();
    _feedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateBarnUsage(String barnId, int change) async {
    if (_barnRef == null) return;
    final barnToUpdateRef = _barnRef!.child(barnId);
    await barnToUpdateRef.runTransaction((Object? barnData) {
      if (barnData == null) return Transaction.abort();
      final Map<String, dynamic> barnMap = Map<String, dynamic>.from(
        barnData as Map,
      );
      int currentUsage = barnMap['used'] ?? 0;
      barnMap['used'] = currentUsage + change;
      return Transaction.success(barnMap);
    });
  }

  Future<void> _saveLivestock() async {
    if (_formKey.currentState!.validate()) {
      if (_livestockRef == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Người dùng chưa đăng nhập.')),
        );
        return;
      }
      final int newSoLuong = int.tryParse(_soLuongController.text) ?? 0;

      final newLivestockData = {
        'ten': _tenController.text,
        'loai': _selectedType, // Lưu loại
        'chuong': _selectedBarnId,
        'soLuong': newSoLuong,
        'thucAn': _selectedFeedId,
      };

      try {
        if (widget.livestock == null) {
          await _livestockRef!.push().set(newLivestockData);
          await _updateBarnUsage(_selectedBarnId!, newSoLuong);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm vật nuôi thành công!')),
          );
        } else {
          await _livestockRef!
              .child(widget.livestock!.id!)
              .update(newLivestockData);
          if (_oldBarnId == _selectedBarnId) {
            int change = newSoLuong - _oldSoLuong;
            if (change != 0) await _updateBarnUsage(_selectedBarnId!, change);
          } else {
            if (_oldBarnId != null)
              await _updateBarnUsage(_oldBarnId!, -_oldSoLuong);
            await _updateBarnUsage(_selectedBarnId!, newSoLuong);
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
      }
    }
  }

  Future<void> _deleteLivestock() async {
    if (_livestockRef == null || widget.livestock == null) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Xác nhận Xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa vật nuôi này?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _livestockRef!.child(widget.livestock!.id!).remove();
        await _updateBarnUsage(
          widget.livestock!.chuong,
          -widget.livestock!.soLuong,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa vật nuôi.')));
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
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
        elevation: 1,
        title: Text(
          widget.livestock == null ? 'Thêm Vật Nuôi' : 'Sửa Vật Nuôi',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.livestock != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteLivestock,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _tenController,
                        decoration: const InputDecoration(
                          labelText: 'Tên/Giống (VD: Bò sữa)',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Vui lòng nhập tên/giống'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      // --- THÊM MỚI: Dropdown cho Loại ---
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'Loại'),
                        items:
                            _livestockTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Vui lòng chọn loại' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedBarnId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Chuồng'),
                        items:
                            _barnList.map((Barn barn) {
                              return DropdownMenuItem<String>(
                                value: barn.id,
                                child: Text(
                                  '${barn.name} (còn trống: ${barn.capacity - barn.used})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBarnId = newValue;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Vui lòng chọn chuồng' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _soLuongController,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập số lượng';
                          final newQuantity = int.tryParse(value);
                          if (newQuantity == null || newQuantity <= 0)
                            return 'Vui lòng nhập số dương';

                          if (_selectedBarnId != null) {
                            Barn? selectedBarn;
                            try {
                              selectedBarn = _barnList.firstWhere(
                                (b) => b.id == _selectedBarnId,
                              );
                            } catch (e) {
                              selectedBarn = null;
                            }

                            if (selectedBarn != null) {
                              int availableSpace =
                                  selectedBarn.capacity - selectedBarn.used;
                              if (widget.livestock != null &&
                                  widget.livestock!.chuong == _selectedBarnId) {
                                availableSpace += _oldSoLuong;
                              }

                              if (newQuantity > availableSpace) {
                                return 'Vượt sức chứa! (còn trống: $availableSpace)';
                              }
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedFeedId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Thức ăn'),
                        items:
                            _feedList.map((Feed feed) {
                              return DropdownMenuItem<String>(
                                value: feed.id,
                                child: Text(
                                  feed.ten,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFeedId = newValue;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Vui lòng chọn thức ăn' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveLivestock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
