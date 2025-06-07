import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'dart:async'; // Dùng cho StreamSubscription

class StorageManagementPage extends StatefulWidget {
  const StorageManagementPage({super.key});

  @override
  State<StorageManagementPage> createState() => _StorageManagementPageState();
}

class _StorageManagementPageState extends State<StorageManagementPage> {
  List<Map<String, dynamic>> _storageItems = [];
  late StreamSubscription<DatabaseEvent> _storageSubscription;

  // Tham chiếu đến node gốc của vật tư trong Realtime Database
  final DatabaseReference _storageRef = FirebaseDatabase.instance.ref('DungCuChanNuoi');

  // Controllers cho các trường nhập liệu trong dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  // Không cần _unitController nữa vì sẽ dùng _selectedUnit
  String? _selectedUnit; // Để lưu giá trị đơn vị được chọn trong Dropdown
  String? _selectedType; // Để lưu giá trị loại vật tư được chọn trong Dropdown

  final List<String> _storageTypes = [
    'Thức ăn',
    'Thuốc',
    'Dụng cụ',
    'Vật tư khác',
  ];

  // Danh sách các đơn vị tính có sẵn
  final List<String> _units = [
    'Kg',
    'cái',
    'thùng',
    'chai',
    'gói',
    'lit',
    'bao',
    'cuộn',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStorageItemsFromFirebase();
  }

  // Hàm để tải dữ liệu vật tư từ Firebase Realtime Database
  void _fetchStorageItemsFromFirebase() {
    print('--- Đang lắng nghe dữ liệu từ Firebase Realtime Database tại ${_storageRef.path} ---');
    _storageSubscription = _storageRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print('--- Dữ liệu thô từ Firebase Realtime Database: $data ---');

      final List<Map<String, dynamic>> fetchedItems = [];
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            fetchedItems.add({
              'id': key,
              'name': value['TenVatTu']?.toString() ?? 'Không tên',
              'quantity': value['SoLuong']?.toString() ?? '0',
              'unit': value['DonVi']?.toString() ?? 'Đơn vị', // Lấy đơn vị từ Firebase
              'type': value['Loai']?.toString() ?? 'Không loại',
            });
          }
        });
        print('--- Đã đọc ${fetchedItems.length} mục vật tư từ Firebase ---');
      } else {
        print('--- Không có dữ liệu hoặc dữ liệu không đúng định dạng Map từ Firebase ---');
      }
      setState(() {
        _storageItems = fetchedItems;
        print('--- UI đã được cập nhật với ${_storageItems.length} mục vật tư ---');
      });
    }, onError: (Object error) {
      print('--- LỖI khi tải dữ liệu từ Firebase Realtime Database: $error ---');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu vật tư: $error')),
      );
    });
  }

  // Hàm để thêm vật tư mới vào Firebase Realtime Database
  void _addStorageItem(Map<String, dynamic> newItem) {
    _storageRef.push().set({
      'TenVatTu': newItem['name'],
      'SoLuong': int.tryParse(newItem['quantity'].toString()) ?? 0,
      'DonVi': newItem['unit'], // Lưu đơn vị
      'Loai': newItem['type'],
      'timestamp': ServerValue.timestamp,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm vật tư thành công!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm thất bại: $error')),
      );
    });
  }

  // Hàm để cập nhật vật tư trong Firebase Realtime Database
  void _updateStorageItem(String itemId, Map<String, dynamic> updatedItem) {
    if (itemId.isNotEmpty) {
      _storageRef.child(itemId).update({
        'TenVatTu': updatedItem['name'],
        'SoLuong': int.tryParse(updatedItem['quantity'].toString()) ?? 0,
        'DonVi': updatedItem['unit'], // Cập nhật đơn vị
        'Loai': updatedItem['type'],
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật vật tư thành công!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: $error')),
        );
      });
    }
  }

  // Hàm để xóa vật tư khỏi Firebase Realtime Database
  void _deleteStorageItem(String itemId, String itemName) {
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
                  _storageRef.child(itemId).remove().then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xóa vật tư thành công!')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xóa thất bại: $error')),
                    );
                  });
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  // DIALOG ĐỂ THÊM HOẶC CHỈNH SỬA VẬT TƯ (ĐÃ CẬP NHẬT ĐƠN VỊ TÍNH)
  void _showAddEditItemDialog({
    String? itemId, // Null nếu là thêm mới, có giá trị nếu là chỉnh sửa
    String? currentName,
    String? currentQuantity,
    String? currentUnit, // Đơn vị hiện tại
    String? currentType,
  }) {
    // Khởi tạo controllers và selectedType/selectedUnit với giá trị hiện tại (nếu có)
    _nameController.text = currentName ?? '';
    _quantityController.text = currentQuantity ?? '0';

    // Đặt giá trị cho Dropdown "Đơn vị tính"
    if (_units.contains(currentUnit)) {
      _selectedUnit = currentUnit;
    } else {
      _selectedUnit = _units.first; // Mặc định là đơn vị đầu tiên nếu không khớp
    }

    // Đặt giá trị cho Dropdown "Phân loại"
    if (_storageTypes.contains(currentType)) {
      _selectedType = currentType;
    } else {
      _selectedType = _storageTypes.first; // Mặc định là loại đầu tiên nếu không khớp
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(itemId == null ? 'Thêm Vật tư mới' : 'Chỉnh sửa Vật tư'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Tên vật tư'),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                      keyboardType: TextInputType.number,
                    ),
                    // Dropdown cho Đơn vị tính
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Đơn vị tính'),
                      items: _units.map((String unit) {
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn đơn vị tính';
                        }
                        return null;
                      },
                    ),
                    // Dropdown cho Phân loại
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Phân loại'),
                      items: _storageTypes.map((String type) {
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn phân loại';
                        }
                        return null;
                      },
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
                        _selectedUnit == null || // Kiểm tra _selectedUnit
                        _selectedType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng điền đủ thông tin.')),
                      );
                      return;
                    }

                    final Map<String, dynamic> itemData = {
                      'name': _nameController.text,
                      'quantity': _quantityController.text,
                      'unit': _selectedUnit!, // Lấy giá trị từ _selectedUnit
                      'type': _selectedType!,
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
                      backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: Text(itemId == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Hàm để xóa nội dung của các TextEditingController và reset Dropdown
  void _clearControllers() {
    _nameController.clear();
    _quantityController.clear();
    // Không cần clear _unitController nữa
    // Cần reset giá trị _selectedUnit và _selectedType về mặc định hoặc null
    _selectedUnit = _units.first; // Reset về đơn vị đầu tiên
    _selectedType = _storageTypes.first; // Reset về loại đầu tiên
  }

  @override
  void dispose() {
    _storageSubscription.cancel();
    _nameController.dispose();
    _quantityController.dispose();
    // Không cần dispose _unitController
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân loại Vật tư',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _storageItems.isEmpty
                  ? const Center(child: Text('Không có vật tư nào. Nhấn nút + để thêm mới!'))
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
          _showAddEditItemDialog(); // Gọi dialog để thêm mới
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStorageItem(
      BuildContext context, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          item['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Số lượng: ${item['quantity']} ${item['unit']}', // Hiển thị đơn vị
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Loại: ${item['type']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Gọi dialog để chỉnh sửa, truyền cả đơn vị hiện tại
                _showAddEditItemDialog(
                  itemId: item['id']!,
                  currentName: item['name'],
                  currentQuantity: item['quantity'],
                  currentUnit: item['unit'], // Truyền đơn vị hiện tại
                  currentType: item['type'],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteStorageItem(item['id']!, item['name']!),
            ),
          ],
        ),
      ),
    );
  }
}