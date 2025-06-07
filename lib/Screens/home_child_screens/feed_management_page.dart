import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database

class FeedManagementPage extends StatefulWidget {
  const FeedManagementPage({super.key});

  @override
  State<FeedManagementPage> createState() => _FeedManagementPageState();
}

class _FeedManagementPageState extends State<FeedManagementPage> {
  List<Map<String, String>> _feedItems = [];

  // Define the Firebase database reference for 'Thucan'
  // Đã đổi tên biến theo chuẩn lowerCamelCase
  final DatabaseReference _ThucanRef = FirebaseDatabase.instance.ref('Thucan');
  // ^ Đảm bảo rằng 'Thuocan' là node gốc chứa danh sách các mục thức ăn của bạn trong Firebase

  @override
  void initState() {
    super.initState();
    _fetchFeedItemsFromFirebase(); // Fetch data from Firebase on init
  }

  // Function to fetch data from Firebase
  void _fetchFeedItemsFromFirebase() {
    print('--- Đang lắng nghe dữ liệu từ Firebase tại ${_ThucanRef.path} ---');
    _ThucanRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print('--- Dữ liệu thô từ Firebase: $data ---'); // IN RA DỮ LIỆU THÔ ĐỂ KIỂM TRA

      final List<Map<String, String>> fetchedItems = [];
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            // SỬA TÊN TRƯỜNG ĐỂ KHỚP VỚI FIREBASE
            // Dựa trên ảnh: HanDuoung, khoiluong, Phanloai, ngaysx
            fetchedItems.add({
              'id': key, // Store the Firebase key for updates/deletes
              'name': value['HanDuoung']?.toString() ?? '', // Giả định 'HanDuoung' dùng làm tên
              'expiryDate': value['ngaysx']?.toString() ?? '', // 'ngaysx' cho hạn sử dụng
              'weight': value['khoiluong']?.toString() ?? '', // 'khoiluong' cho khối lượng
              'type': value['Phanloai']?.toString() ?? '', // 'Phanloai' cho loại
            });
          }
        });
        print('--- Đã đọc ${fetchedItems.length} mục từ Firebase ---');
      } else {
        print('--- Không có dữ liệu hoặc dữ liệu không đúng định dạng Map ---');
      }
      setState(() {
        _feedItems = fetchedItems;
        print('--- UI đã được cập nhật với ${_feedItems.length} mục ---');
      });
    }, onError: (Object error) {
      print('--- LỖI khi tải dữ liệu từ Firebase: $error ---');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $error')),
      );
    });
  }

  // Hàm này không được gọi trong code hiện tại, cân nhắc xóa hoặc sử dụng
  // if (updatedItem != null) { _updateFeedItem(index, updatedItem); }
  // sau khi Navigator.pop từ EditFeedItemPage
  void _updateFeedItem(int index, Map<String, String> updatedItem) {
    String? itemId = _feedItems[index]['id'];
    if (itemId != null) {
      // SỬA TÊN TRƯỜNG ĐỂ KHỚP VỚI FIREBASE KHI GHI
      _ThucanRef.child(itemId).update({
        'HanDuoung': updatedItem['name'], // name trong code -> HanDuoung trong Firebase
        'ngaysx': updatedItem['expiryDate'], // expiryDate trong code -> ngaysx trong Firebase
        'khoiluong': updatedItem['weight'], // weight trong code -> khoiluong trong Firebase
        'Phanloai': updatedItem['type'], // type trong code -> Phanloai trong Firebase
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thức ăn thành công!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: $error')),
        );
      });
    }
  }

  void _addFeedItem(Map<String, String> newItem) {
    // SỬA TÊN TRƯỜNG ĐỂ KHỚP VỚI FIREBASE KHI THÊM MỚI
    _ThucanRef.push().set({
      'HanDuoung': newItem['name'],
      'ngaysx': newItem['expiryDate'],
      'khoiluong': newItem['weight'],
      'Phanloai': newItem['type'],
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm thức ăn thành công!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm thất bại: $error')),
      );
    });
  }

  void _deleteFeedItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa mục này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                String? itemId = _feedItems[index]['id'];
                if (itemId != null) {
                  _ThucanRef.child(itemId).remove().then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xóa thức ăn thành công!')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xóa thất bại: $error')),
                    );
                  });
                }
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionTitle('Danh sách thức ăn'),
            Expanded(
              child: _buildFeedItemsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFeedItemPage(),
            ),
          );
          if (newItem != null) {
            _addFeedItem(newItem);
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }

  Widget _buildFeedItemsList() {
    if (_feedItems.isEmpty) {
      return const Center(child: Text('Không có thức ăn nào. Nhấn nút + để thêm mới!'));
    }
    return ListView.builder(
      itemCount: _feedItems.length,
      itemBuilder: (context, index) {
        final item = _feedItems[index];
        return _buildFeedItemCard(context, index, item);
      },
    );
  }

  Widget _buildFeedItemCard(
      BuildContext context, int index, Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          item['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Hạn sử dụng: ${item['expiryDate']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Khối lượng: ${item['weight']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Phân loại: ${item['type']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updatedItemData = await Navigator.push( // Đổi tên biến để rõ ràng hơn
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFeedItemPage(
                      id: item['id']!,
                      name: item['name']!,
                      expiryDate: item['expiryDate']!,
                      weight: item['weight']!,
                      type: item['type']!,
                    ),
                  ),
                );
                // Bạn có thể gọi _updateFeedItem ở đây nếu muốn update ngay lập tức
                // thay vì chờ onValue listener tự động cập nhật
                if (updatedItemData != null && updatedItemData is Map<String, String>) {
                  _updateFeedItem(index, updatedItemData);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFeedItem(index),
            ),
          ],
        ),
      ),
    );
  }
}

// AddFeedItemPage (Không có thay đổi về cú pháp)
class AddFeedItemPage extends StatefulWidget {
  const AddFeedItemPage({super.key});

  @override
  State<AddFeedItemPage> createState() => _AddFeedItemPageState();
}

class _AddFeedItemPageState extends State<AddFeedItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(text: '0');
  String? _selectedType;

  final List<String> _feedTypes = [
    'Thức ăn tự nhiên',
    'Thức ăn công nghiệp'
  ];

  @override
  void initState() {
    super.initState();
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
        _expiryDateController.text = "${picked.day}/${picked.month}/${picked.year}";
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
          child: Column(
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
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Hạn sử dụng (DD/MM/YYYY)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn hạn sử dụng';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Khối lượng'),
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
                items: _feedTypes.map((String type) {
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
                    Navigator.pop(
                      context,
                      {
                        'name': _nameController.text,
                        'expiryDate': _expiryDateController.text,
                        'weight': '${_weightController.text} Kg',
                        'type': _selectedType!,
                      },
                    );
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

// EditFeedItemPage (Đã sửa lỗi cú pháp)
class EditFeedItemPage extends StatefulWidget {
  final String id;
  final String name;
  final String expiryDate;
  final String weight;
  final String type;

  const EditFeedItemPage({
    super.key,
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.weight,
    required this.type,
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

  final List<String> _feedTypes = [
    'Thức ăn tự nhiên',
    'Thức ăn công nghiệp'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _expiryDateController = TextEditingController(text: widget.expiryDate);

    String initialWeight = widget.weight.replaceAll(' Kg', '').trim();
    _weightController = TextEditingController(text: initialWeight);

    if (_feedTypes.contains(widget.type)) {
      _selectedType = widget.type;
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
        _expiryDateController.text = "${picked.day}/${picked.month}/${picked.year}";
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
          child: Column(
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
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Hạn sử dụng (DD/MM/YYYY)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn hạn sử dụng';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Khối lượng'),
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
                items: _feedTypes.map((String type) {
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
                    Navigator.pop(
                      context,
                      {
                        'name': _nameController.text,
                        'expiryDate': _expiryDateController.text,
                        'weight': '${_weightController.text} Kg',
                        'type': _selectedType ?? '',
                      },
                    );
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