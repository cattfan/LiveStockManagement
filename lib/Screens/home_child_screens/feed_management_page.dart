import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class FeedManagementPage extends StatefulWidget {
  const FeedManagementPage({super.key});

  @override
  State<FeedManagementPage> createState() => _FeedManagementPageState();
}

class _FeedManagementPageState extends State<FeedManagementPage> {
  List<Map<String, dynamic>> _feedItems = [];
  StreamSubscription<DatabaseEvent>? _feedSubscription;
  DatabaseReference? _feedRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _feedRef = FirebaseDatabase.instance.ref('app_data/${user.uid}/thuc_an');
      _fetchFeedItemsFromFirebase();
    }
  }

  void _fetchFeedItemsFromFirebase() {
    if (_feedRef == null) return;
    _feedSubscription = _feedRef!.onValue.listen(
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
                'ngay_sx': value['ngay_sx']?.toString() ?? 'N/A',
                'khoi_luong': value['khoi_luong']?.toString() ?? '0 Kg',
                'phan_loai': value['phan_loai']?.toString() ?? 'Không loại',
              });
            }
          });
        }
        setState(() {
          _feedItems = fetchedItems;
        });
      },
      onError: (Object error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu thức ăn: $error')),
        );
      },
    );
  }

  void _addFeedItem(Map<String, dynamic> newItem) {
    if (_feedRef == null) return;
    _feedRef!
        .push()
        .set({
          'ten': newItem['ten'],
          'ngay_sx': newItem['ngay_sx'],
          'khoi_luong': newItem['khoi_luong'],
          'phan_loai': newItem['phan_loai'],
        })
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm thức ăn thành công!')),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Thêm thất bại: $error')));
        });
  }

  void _updateFeedItem(String itemId, Map<String, dynamic> updatedItem) {
    if (_feedRef == null) return;
    _feedRef!
        .child(itemId)
        .update({
          'ten': updatedItem['ten'],
          'ngay_sx': updatedItem['ngay_sx'],
          'khoi_luong': updatedItem['khoi_luong'],
          'phan_loai': updatedItem['phan_loai'],
        })
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thức ăn thành công!')),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $error')));
        });
  }

  void _deleteFeedItem(String itemId) {
    if (_feedRef == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa mục này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                _feedRef!
                    .child(itemId)
                    .remove()
                    .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Xóa thức ăn thành công!'),
                        ),
                      );
                    })
                    .catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Xóa thất bại: $error')),
                      );
                    });
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _feedSubscription?.cancel();
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
          'Quản lý Thức ăn',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body:
          _feedRef == null
              ? const Center(child: Text("Vui lòng đăng nhập."))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [Expanded(child: _buildFeedItemsList())],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFeedItemPage()),
          );
          if (newItem != null && newItem is Map<String, dynamic>) {
            _addFeedItem(newItem);
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFeedItemsList() {
    if (_feedItems.isEmpty) {
      return const Center(child: Text('Chưa có thức ăn nào.'));
    }
    return ListView.builder(
      itemCount: _feedItems.length,
      itemBuilder: (context, index) {
        final item = _feedItems[index];
        return _buildFeedItemCard(context, item);
      },
    );
  }

  Widget _buildFeedItemCard(BuildContext context, Map<String, dynamic> item) {
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
              'Ngày sản xuất: ${item['ngay_sx']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Khối lượng: ${item['khoi_luong']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Phân loại: ${item['phan_loai']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updatedItemData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditFeedItemPage(
                          id: item['id']!,
                          ten: item['ten']!,
                          ngay_sx: item['ngay_sx']!,
                          khoi_luong: item['khoi_luong']!,
                          phan_loai: item['phan_loai']!,
                        ),
                  ),
                );
                if (updatedItemData != null &&
                    updatedItemData is Map<String, dynamic>) {
                  _updateFeedItem(item['id']!, updatedItemData);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFeedItem(item['id']!),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFeedItemPage extends StatefulWidget {
  const AddFeedItemPage({super.key});

  @override
  State<AddFeedItemPage> createState() => _AddFeedItemPageState();
}

class _AddFeedItemPageState extends State<AddFeedItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedType;

  final List<String> _feedTypes = ['Thức ăn tự nhiên', 'Thức ăn công nghiệp'];

  @override
  void initState() {
    super.initState();
    _weightController.text = '0';
    _selectedType = _feedTypes.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expiryDateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Thêm Thức ăn mới',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thức ăn'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên thức ăn';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Khối lượng (Kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập khối lượng';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Khối lượng không hợp lệ';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Phân loại'),
                items:
                    _feedTypes.map((String type) {
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn phân loại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'ten': _nameController.text,
                      'ngay_sx': _expiryDateController.text,
                      'khoi_luong': '${_weightController.text} Kg',
                      'phan_loai': _selectedType!,
                    });
                  }
                },
                child: const Text('Thêm thức ăn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditFeedItemPage extends StatefulWidget {
  final String id;
  final String ten;
  final String ngay_sx;
  final String khoi_luong;
  final String phan_loai;

  const EditFeedItemPage({
    super.key,
    required this.id,
    required this.ten,
    required this.ngay_sx,
    required this.khoi_luong,
    required this.phan_loai,
  });

  @override
  State<EditFeedItemPage> createState() => _EditFeedItemPageState();
}

class _EditFeedItemPageState extends State<EditFeedItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _expiryDateController;
  late TextEditingController _weightController;
  String? _selectedType;

  final List<String> _feedTypes = ['Thức ăn tự nhiên', 'Thức ăn công nghiệp'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ten);
    _expiryDateController = TextEditingController(text: widget.ngay_sx);
    String initialWeight = widget.khoi_luong.replaceAll(' Kg', '').trim();
    _weightController = TextEditingController(text: initialWeight);
    if (_feedTypes.contains(widget.phan_loai)) {
      _selectedType = widget.phan_loai;
    } else {
      _selectedType = _feedTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expiryDateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Chỉnh sửa Thức ăn',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thức ăn'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên thức ăn';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Khối lượng (Kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập khối lượng';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Khối lượng không hợp lệ';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Phân loại'),
                items:
                    _feedTypes.map((String type) {
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn phân loại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'ten': _nameController.text,
                      'ngay_sx': _expiryDateController.text,
                      'khoi_luong': '${_weightController.text} Kg',
                      'phan_loai': _selectedType!,
                    });
                  }
                },
                child: const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
