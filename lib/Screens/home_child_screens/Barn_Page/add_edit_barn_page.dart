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
  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color inputBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

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
        } else {
          await _dbRef!.child(widget.barn!.id!).update(barnData);
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        // Lỗi đã được xử lý nhưng không hiển thị thông báo
      }
    }
  }

  Future<void> _deleteBarn() async {
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
      return;
    }

    if (_dbRef == null) {
      return;
    }

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

    if (confirmed == true && widget.barn != null) {
      try {
        await _dbRef!.child(widget.barn!.id!).remove();
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        // Lỗi đã được xử lý nhưng không hiển thị thông báo
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        leading: const BackButton(color: primaryTextColor),
        backgroundColor: pageBgColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.barn == null ? 'Thêm Chuồng Trại' : 'Sửa Chuồng Trại',
          style: const TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                style: const TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Tên chuồng',
                  labelStyle: const TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Vui lòng nhập tên chuồng' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                style: const TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Sức chứa tối đa',
                  labelStyle: const TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập sức chứa';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'Sức chứa phải là số dương';
                  }
                  if (widget.barn != null && capacity < widget.barn!.used) {
                    return 'Sức chứa không được nhỏ hơn số lượng hiện có (${widget.barn!.used})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempController,
                style: const TextStyle(color: primaryTextColor),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Nhiệt độ',
                  suffixText: '°C',
                  labelStyle: const TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _humidityController,
                style: const TextStyle(color: primaryTextColor),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Độ ẩm',
                  suffixText: '%',
                  labelStyle: const TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBarn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryTextColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Lưu', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
