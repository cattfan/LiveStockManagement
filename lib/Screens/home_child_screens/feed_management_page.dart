// File: lib/Screens/home_child_screens/feed_management_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async'; // Dùng cho StreamSubscription

class FeedManagementPage extends StatefulWidget {
  const FeedManagementPage({super.key});

  @override
  State<FeedManagementPage> createState() => _FeedManagementPageState();
}

class _FeedManagementPageState extends State<FeedManagementPage> {
  List<Map<String, dynamic>> _feedItems = []; // Thay đổi kiểu dữ liệu thành dynamic để linh hoạt hơn
  late StreamSubscription<DatabaseEvent> _feedSubscription; // Thêm StreamSubscription
  final DatabaseReference _feedRef = FirebaseDatabase.instance.ref('Thucan');
  // ^ Đảm bảo rằng 'Thucan' là node gốc chứa danh sách các mục thức ăn của bạn trong Firebase

  @override
  void initState() {
    super.initState();
    _fetchFeedItemsFromFirebase(); // Fetch data from Firebase on init
  }

  // Function to fetch data from Firebase
  void _fetchFeedItemsFromFirebase() {
    print('--- Đang lắng nghe dữ liệu từ Firebase tại ${_feedRef.path} ---');
    _feedSubscription = _feedRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print('--- Dữ liệu thô từ Firebase: $data ---'); // IN RA DỮ LIỆU THÔ ĐỂ KIỂM TRA

      final List<Map<String, dynamic>> fetchedItems = []; // Sử dụng dynamic
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            // SỬA TÊN TRƯỜNG ĐỂ KHỚP VỚI FIREBASE CỦA BẠN: HanDuoung, khoiluong, Phanloai, ngaysx
            fetchedItems.add({
              'id': key, // Store the Firebase key for updates/deletes
              'name': value['HanDuoung']?.toString() ?? 'Không tên', // Dùng HanDuoung làm tên hiển thị
              'expiryDate': value['ngaysx']?.toString() ?? 'N/A', // ngaysx là ngày sản xuất/hạn dùng
              'weight': value['khoiluong']?.toString() ?? '0 Kg', // khoiluong
              'type': value['Phanloai']?.toString() ?? 'Không loại', // Phanloai
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
        SnackBar(content: Text('Lỗi khi tải dữ liệu thức ăn: $error')),
      );
    });
  }

  // Hàm để thêm mục mới vào Firebase
  void _addFeedItem(Map<String, dynamic> newItem) { // Thay đổi kiểu dữ liệu thành dynamic
    // SỬA TÊN TRƯỜNG ĐỂ KHỚP VỚI FIREBASE KHI THÊM MỚI
    _feedRef.push().set({
      'HanDuoung': newItem['name'], // name trong form -> HanDuoung trong Firebase
      'ngaysx': newItem['expiryDate'], // expiryDate trong form -> ngaysx trong Firebase
      'khoiluong': newItem['weight'], // weight trong form -> khoiluong trong Firebase (đã xử lý " Kg" trong AddForm)
      'Phanloai': newItem['type'], // type trong form -> Phanloai trong Firebase
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

  // Hàm để cập nhật mục trong Firebase
  void _updateFeedItem(String itemId, Map<String, dynamic> updatedItem) { // Thay đổi kiểu dữ liệu thành dynamic
    if (itemId != null) {
      // SỬA TÊN TRƯỜNG ĐỂ KHỚP VỚI FIREBASE KHI GHI
      _feedRef.child(itemId).update({
        'HanDuoung': updatedItem['name'], // name trong form -> HanDuoung trong Firebase
        'ngaysx': updatedItem['expiryDate'], // expiryDate trong form -> ngaysx trong Firebase
        'khoiluong': updatedItem['weight'], // weight trong form -> khoiluong trong Firebase (đã xử lý " Kg" trong EditForm)
        'Phanloai': updatedItem['type'], // type trong form -> Phanloai trong Firebase
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

  // Hàm để xóa mục khỏi Firebase
  void _deleteFeedItem(String itemId) {
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
                if (itemId != null) {
                  _feedRef.child(itemId).remove().then((_) {
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
  void dispose() {
    _feedSubscription.cancel(); // Hủy lắng nghe khi widget bị hủy
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
          if (newItem != null && newItem is Map<String, String>) { // Kiểm tra kiểu dữ liệu
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
        return _buildFeedItemCard(context, item); // Chỉ truyền item, không cần index nữa
      },
    );
  }

  Widget _buildFeedItemCard(
      BuildContext context, Map<String, dynamic> item) { // Thay đổi kiểu dữ liệu
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          item['name']!, // 'name' ở đây là 'HanDuoung' từ Firebase
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Ngày sản xuất: ${item['expiryDate']}', // Sử dụng 'ngaysx'
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
                final updatedItemData = await Navigator.push(
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
                if (updatedItemData != null && updatedItemData is Map<String, String>) {
                  _updateFeedItem(item['id']!, updatedItemData); // Truyền ID và dữ liệu đã cập nhật
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFeedItem(item['id']!), // Xóa theo ID
            ),
          ],
        ),
      ),
    );
  }
}

// AddFeedItemPage
class AddFeedItemPage extends StatefulWidget {
  const AddFeedItemPage({super.key});

  @override
  State<AddFeedItemPage> createState() => _AddFeedItemPageState();
}

class _AddFeedItemPageState extends State<AddFeedItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(); // Không đặt giá trị mặc định '0'
  String? _selectedType;

  final List<String> _feedTypes = [
    'Thức ăn tự nhiên',
    'Thức ăn công nghiệp'
  ];

  @override
  void initState() {
    super.initState();
    // Đặt giá trị mặc định cho weight nếu muốn
    _weightController.text = '0'; // Hoặc bỏ qua để người dùng nhập
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
          child: ListView( // Thay Column bằng ListView để tránh overflow
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thức ăn (Hạn Dùng/Tình trạng)'),
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
                  labelText: 'Ngày sản xuất (DD/MM/YYYY)', // Đổi label cho khớp với Firebase
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn ngày sản xuất';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Khối lượng (Kg)'),
                keyboardType: TextInputType.number, // Chỉ cho phép nhập số
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
                        'weight': '${_weightController.text} Kg', // Thêm ' Kg' khi trả về
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

// EditFeedItemPage
class EditFeedItemPage extends StatefulWidget {
  final String id;
  final String name; // (HanDuoung)
  final String expiryDate; // (ngaysx)
  final String weight; // (khoiluong)
  final String type; // (Phanloai)

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

    // Loại bỏ " Kg" khi hiển thị để người dùng dễ chỉnh sửa số
    String initialWeight = widget.weight.replaceAll(' Kg', '').trim();
    _weightController = TextEditingController(text: initialWeight);

    if (_feedTypes.contains(widget.type)) {
      _selectedType = widget.type;
    } else {
      _selectedType = _feedTypes.first; // Đặt giá trị mặc định nếu không khớp
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
      initialDate: DateTime.now(), // Có thể đặt initialDate dựa trên widget.expiryDate nếu muốn
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
          child: ListView( // Thay Column bằng ListView để tránh overflow
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thức ăn (Hạn Dùng/Tình trạng)'),
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
                  labelText: 'Ngày sản xuất (DD/MM/YYYY)', // Đổi label cho khớp
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn ngày sản xuất';
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
                        'weight': '${_weightController.text} Kg', // Thêm ' Kg' khi trả về
                        'type': _selectedType!,
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