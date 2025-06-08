import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class StorageManagementPage extends StatefulWidget {
  const StorageManagementPage({super.key});

  @override
  State<StorageManagementPage> createState() => _StorageManagementPageState();
}

class _StorageManagementPageState extends State<StorageManagementPage> {
  List<Map<String, dynamic>> _storageItems = [];
  StreamSubscription<DatabaseEvent>? _storageSubscription;
  DatabaseReference? _storageRef;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedUnit;
  String? _selectedType;

  final List<String> _storageTypes = ['Thuốc', 'Dụng cụ', 'Vật tư khác'];

  final List<String> _units = [
    'Kg',
    'cái',
    'thùng',
    'chai',
    'gói',
    'lít',
    'bao',
    'cuộn',
    'viên',
    'liều',
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _storageRef = FirebaseDatabase.instance.ref(
        'app_data/${user.uid}/dung_cu',
      );
      _fetchStorageItemsFromFirebase();
    }
  }

  void _fetchStorageItemsFromFirebase() {
    if (_storageRef == null) return;
    _storageSubscription = _storageRef!.onValue.listen(
      (event) {
        if (!mounted) return;
        final data = event.snapshot.value;
        final List<Map<String, dynamic>> fetchedItems = [];
        if (data != null && data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              fetchedItems.add({
                'id': key,
                'ten': value['ten']?.toString() ?? 'Không tên',
                'so_luong': value['so_luong']?.toString() ?? '0',
                'don_vi': value['don_vi']?.toString() ?? 'Đơn vị',
                'loai': value['loai']?.toString() ?? 'Không loại',
              });
            }
          });
        }
        setState(() {
          _storageItems = fetchedItems;
        });
      },
      onError: (Object error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu vật tư: $error')),
        );
      },
    );
  }

  void _addStorageItem(Map<String, dynamic> newItem) {
    if (_storageRef == null) return;
    _storageRef!
        .push()
        .set({
          'ten': newItem['ten'],
          'so_luong': int.tryParse(newItem['so_luong'].toString()) ?? 0,
          'don_vi': newItem['don_vi'],
          'loai': newItem['loai'],
          'timestamp': ServerValue.timestamp,
        })
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm vật tư thành công!')),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Thêm thất bại: $error')));
        });
  }

  void _updateStorageItem(String itemId, Map<String, dynamic> updatedItem) {
    if (_storageRef == null) return;
    if (itemId.isNotEmpty) {
      _storageRef!
          .child(itemId)
          .update({
            'ten': updatedItem['ten'],
            'so_luong': int.tryParse(updatedItem['so_luong'].toString()) ?? 0,
            'don_vi': updatedItem['don_vi'],
            'loai': updatedItem['loai'],
          })
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật vật tư thành công!')),
            );
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật thất bại: $error')),
            );
          });
    }
  }

  void _deleteStorageItem(String itemId, String itemName) {
    if (_storageRef == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa "$itemName" không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemId.isNotEmpty) {
                  _storageRef!
                      .child(itemId)
                      .remove()
                      .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xóa vật tư thành công!'),
                          ),
                        );
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Xóa thất bại: $error')),
                        );
                      });
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditItemDialog({
    String? itemId,
    String? currentName,
    String? currentQuantity,
    String? currentUnit,
    String? currentType,
  }) {
    _nameController.text = currentName ?? '';
    _quantityController.text = currentQuantity ?? '';
    _selectedUnit = _units.contains(currentUnit) ? currentUnit : _units.first;
    _selectedType =
        _storageTypes.contains(currentType) ? currentType : _storageTypes.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(
                itemId == null ? 'Thêm Vật tư mới' : 'Chỉnh sửa Vật tư',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên vật tư',
                      ),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Đơn vị tính',
                      ),
                      items:
                          _units.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() {
                          _selectedUnit = newValue;
                        });
                      },
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Chọn đơn vị'
                                  : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Phân loại'),
                      items:
                          _storageTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() {
                          _selectedType = newValue;
                        });
                      },
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Chọn phân loại'
                                  : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearControllers();
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _quantityController.text.isEmpty ||
                        _selectedUnit == null ||
                        _selectedType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng điền đủ thông tin.'),
                        ),
                      );
                      return;
                    }

                    final Map<String, dynamic> itemData = {
                      'ten': _nameController.text,
                      'so_luong': _quantityController.text,
                      'don_vi': _selectedUnit!,
                      'loai': _selectedType!,
                    };

                    if (itemId == null) {
                      _addStorageItem(itemData);
                    } else {
                      _updateStorageItem(itemId, itemData);
                    }
                    Navigator.pop(context);
                    _clearControllers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(itemId == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _quantityController.clear();
    _selectedUnit = _units.first;
    _selectedType = _storageTypes.first;
  }

  @override
  void dispose() {
    _storageSubscription?.cancel();
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Quản lý Vật tư',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body:
          _storageRef == null
              ? const Center(child: Text("Vui lòng đăng nhập."))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh sách Vật tư',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          _storageItems.isEmpty
                              ? const Center(
                                child: Text(
                                  'Không có vật tư nào. Nhấn nút + để thêm mới!',
                                ),
                              )
                              : ListView.builder(
                                itemCount: _storageItems.length,
                                itemBuilder: (context, index) {
                                  final item = _storageItems[index];
                                  return _buildStorageItem(context, item);
                                },
                              ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditItemDialog();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStorageItem(BuildContext context, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(
          item['ten']!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Số lượng: ${item['so_luong']} ${item['don_vi']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Loại: ${item['loai']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _showAddEditItemDialog(
                  itemId: item['id']!,
                  currentName: item['ten'],
                  currentQuantity: item['so_luong'],
                  currentUnit: item['don_vi'],
                  currentType: item['loai'],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteStorageItem(item['id']!, item['ten']!),
            ),
          ],
        ),
      ),
    );
  }
}
