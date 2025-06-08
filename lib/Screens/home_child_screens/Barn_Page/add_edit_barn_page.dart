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
  late TextEditingController _usedController;
  late TextEditingController _tempController;
  late TextEditingController _humidityController;

  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref('quan_ly_chan_nuoi/chuong_trai');

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với giá trị số (loại bỏ ký tự đơn vị)
    _nameController = TextEditingController(text: widget.barn?.name ?? '');
    _capacityController =
        TextEditingController(text: widget.barn?.capacity.toString() ?? '');
    _usedController =
        TextEditingController(text: widget.barn?.used.toString() ?? '');
    _tempController = TextEditingController(text: widget.barn?.temp.replaceAll('°C', '').trim() ?? '');
    _humidityController = TextEditingController(text: widget.barn?.humidity.replaceAll('%', '').trim() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _usedController.dispose();
    _tempController.dispose();
    _humidityController.dispose();
    super.dispose();
  }

  Future<void> _saveBarn() async {
    if (_formKey.currentState!.validate()) {
      // Tự động thêm đơn vị vào sau giá trị người dùng nhập
      final String tempValue = _tempController.text.isNotEmpty ? '${_tempController.text}°C' : '';
      final String humidityValue = _humidityController.text.isNotEmpty ? '${_humidityController.text}%' : '';

      final newBarn = Barn(
        id: widget.barn?.id,
        name: _nameController.text,
        capacity: int.tryParse(_capacityController.text) ?? 0,
        used: int.tryParse(_usedController.text) ?? 0,
        temp: tempValue,
        humidity: humidityValue,
      );

      try {
        if (widget.barn == null) {
          await _dbRef.push().set(newBarn.toJson());
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm chuồng trại thành công!')));
        } else {
          await _dbRef.child(newBarn.id!).update(newBarn.toJson());
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thành công!')));
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
      }
    }
  }

  Future<void> _deleteBarn() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận Xóa'),
          content:
          const Text('Bạn có chắc chắn muốn xóa chuồng trại này không?'),
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
        await _dbRef.child(widget.barn!.id!).remove();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã xóa chuồng trại.')));
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
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
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.barn != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteBarn,
            )
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
                validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tên chuồng' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Sức chứa tối đa'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập sức chứa' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usedController,
                decoration:
                const InputDecoration(labelText: 'Số lượng đang sử dụng'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập số lượng';
                  final intValue = int.tryParse(value);
                  final int capacity =
                      int.tryParse(_capacityController.text) ?? 0;
                  if (intValue == null) return 'Không hợp lệ';
                  if (intValue > capacity) return 'Không được vượt quá sức chứa';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Nhiệt độ',
                    suffixText: '°C'
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _humidityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Độ ẩm',
                    suffixText: '%'
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBarn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lưu',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
