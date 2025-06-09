import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/Screens/home_child_screens/Barn_Page/barn_model.dart';

class AddEditBarnPage extends StatefulWidget {
  final Barn? barn;

  const AddEditBarnPage({super.key, this.barn});

  @override
  State<AddEditBarnPage> createState() => _AddEditBarnPageState();
}

class _AddEditBarnPageState extends State<AddEditBarnPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _tempController;
  late TextEditingController _humidityController;

  DatabaseReference? _dbRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbRef = FirebaseDatabase.instance.ref(
        'app_data/${user.uid}/chuong_trai',
      );
    }

    _nameController = TextEditingController(text: widget.barn?.name ?? '');
    _capacityController = TextEditingController(
      text: widget.barn?.capacity.toString() ?? '',
    );
    _tempController = TextEditingController(
      text: widget.barn?.temp.replaceAll('°C', '').trim() ?? '',
    );
    _humidityController = TextEditingController(
      text: widget.barn?.humidity.replaceAll('%', '').trim() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _tempController.dispose();
    _humidityController.dispose();
    super.dispose();
  }

  Future<void> _saveBarn() async {
    if (_formKey.currentState!.validate()) {
      if (_dbRef == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Người dùng chưa đăng nhập.')),
        );
        return;
      }
      final String tempValue =
          _tempController.text.isNotEmpty ? '${_tempController.text}°C' : '';
      final String humidityValue =
          _humidityController.text.isNotEmpty
              ? '${_humidityController.text}%'
              : '';

      final Map<String, dynamic> barnData = {
        'name': _nameController.text,
        'capacity': int.tryParse(_capacityController.text) ?? 0,
        'temp': tempValue,
        'humidity': humidityValue,
      };

      try {
        if (widget.barn == null) {
          barnData['used'] = 0;
          await _dbRef!.push().set(barnData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm chuồng trại thành công!')),
          );
        } else {
          await _dbRef!.child(widget.barn!.id!).update(barnData);
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

  // --- CHỨC NĂNG XÓA CHUỒNG TRẠI ---
  Future<void> _deleteBarn() async {
    // *** RÀNG BUỘC ĐIỀU KIỆN: Kiểm tra xem chuồng có đang chứa vật nuôi không ***
    // Nếu trường 'used' (số lượng đã dùng) lớn hơn 0, hiển thị cảnh báo và không cho xóa.
    if (widget.barn != null && widget.barn!.used > 0) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Không thể xóa'),
              content: const Text(
                'Vui lòng di chuyển hoặc xóa hết vật nuôi khỏi chuồng này trước khi xóa chuồng.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return; // Dừng hàm tại đây
    }

    if (_dbRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Người dùng chưa đăng nhập.')),
      );
      return;
    }

    // Hiển thị hộp thoại xác nhận trước khi xóa
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận Xóa'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa chuồng trại này không?',
          ),
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
        );
      },
    );

    // Nếu người dùng xác nhận, tiến hành xóa
    if (confirmed == true && widget.barn != null) {
      try {
        await _dbRef!.child(widget.barn!.id!).remove();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa chuồng trại.')));
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
          widget.barn == null ? 'Thêm Chuồng Trại' : 'Sửa Chuồng Trại',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Hiển thị nút xóa trên AppBar nếu đang ở chế độ sửa
        actions: [
          if (widget.barn != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteBarn,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên chuồng'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Vui lòng nhập tên chuồng' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Sức chứa tối đa'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Vui lòng nhập sức chứa';
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0)
                    return 'Sức chứa phải là số dương';
                  // Ràng buộc: Sức chứa mới không được nhỏ hơn số lượng vật nuôi đang có
                  if (widget.barn != null && capacity < widget.barn!.used) {
                    return 'Sức chứa không được nhỏ hơn số lượng hiện có (${widget.barn!.used})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Nhiệt độ',
                  suffixText: '°C',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _humidityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Độ ẩm',
                  suffixText: '%',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBarn,
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
