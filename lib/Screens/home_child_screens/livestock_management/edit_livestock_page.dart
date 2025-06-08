import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/Screens/home_child_screens/livestock_management/livestock_model.dart';

class AddEditLivestockPage extends StatefulWidget {
  final Livestock? livestock;

  const AddEditLivestockPage({super.key, this.livestock});

  @override
  State<AddEditLivestockPage> createState() => _AddEditLivestockPageState();
}

class _AddEditLivestockPageState extends State<AddEditLivestockPage> {
  final _formKey = GlobalKey<FormState>();
  // KHAI BÁO BIẾN ĐÃ ĐƯỢC CẬP NHẬT (không còn _loaiController)
  late TextEditingController _tenController;
  late TextEditingController _chuongController;
  late TextEditingController _soLuongController;
  late TextEditingController _thucAnController;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('quan_ly_chan_nuoi/vat_nuoi');

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController(text: widget.livestock?.ten ?? '');
    _chuongController = TextEditingController(text: widget.livestock?.chuong ?? '');
    _soLuongController = TextEditingController(text: widget.livestock?.soLuong.toString() ?? '');
    _thucAnController = TextEditingController(text: widget.livestock?.thucAn ?? '');
  }

  @override
  void dispose() {
    _tenController.dispose();
    _chuongController.dispose();
    _soLuongController.dispose();
    _thucAnController.dispose();
    super.dispose();
  }

  Future<void> _saveLivestock() async {
    if (_formKey.currentState!.validate()) {
      final newLivestock = Livestock(
        id: widget.livestock?.id,
        ten: _tenController.text,
        chuong: _chuongController.text,
        soLuong: int.tryParse(_soLuongController.text) ?? 0,
        thucAn: _thucAnController.text,
      );

      try {
        if (widget.livestock == null) {
          await _dbRef.push().set(newLivestock.toJson());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm vật nuôi thành công!')));
        } else {
          await _dbRef.child(newLivestock.id!).update(newLivestock.toJson());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
      }
    }
  }

  Future<void> _deleteLivestock() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );

    if (confirmed == true && widget.livestock != null) {
      try {
        await _dbRef.child(widget.livestock!.id!).remove();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa vật nuôi.')));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
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
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.livestock != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteLivestock,
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
                controller: _tenController,
                decoration: const InputDecoration(labelText: 'Tên/Giống (VD: Bò sữa)'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên/giống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chuongController,
                decoration: const InputDecoration(labelText: 'Chuồng'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập chuồng' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _soLuongController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập số lượng';
                  if (int.tryParse(value) == null) return 'Vui lòng nhập một số hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thucAnController,
                decoration: const InputDecoration(labelText: 'Thức ăn'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập loại thức ăn' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLivestock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lưu', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
