import 'package:flutter/material.dart';

class EditBarnPage extends StatefulWidget {
  final Map<String, dynamic> barnData;

  const EditBarnPage({super.key, required this.barnData});

  @override
  State<EditBarnPage> createState() => _EditBarnPageState();
}

class _EditBarnPageState extends State<EditBarnPage> {
  final _formKey = GlobalKey<FormState>();
  late String barnName;
  late int capacity;
  late int used;
  late String temp;
  late String humidity;

  @override
  void initState() {
    super.initState();
    barnName = widget.barnData['name'];
    capacity = widget.barnData['max'];
    used = widget.barnData['used'];
    temp = widget.barnData['temp'];
    humidity = widget.barnData['humidity'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: const Text(
          'Sửa chuồng nuôi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: barnName,
                decoration: const InputDecoration(labelText: 'Tên chuồng'),
                onSaved: (value) => barnName = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: capacity.toString(),
                decoration: const InputDecoration(labelText: 'Số lượng tối đa'),
                keyboardType: TextInputType.number,
                onSaved: (value) => capacity = int.tryParse(value ?? '0') ?? 0,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập số lượng' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: used.toString(),
                decoration: const InputDecoration(labelText: 'Số lượng đang sử dụng'),
                keyboardType: TextInputType.number,
                onSaved: (value) => used = int.tryParse(value ?? '0') ?? 0,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập số lượng';
                  final intValue = int.tryParse(value);
                  if (intValue == null) return 'Không hợp lệ';
                  if (intValue > capacity) return 'Không được vượt quá số lượng tối đa';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: temp,
                decoration: const InputDecoration(labelText: 'Nhiệt độ'),
                onSaved: (value) => temp = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: humidity,
                decoration: const InputDecoration(labelText: 'Độ ẩm'),
                onSaved: (value) => humidity = value ?? '',
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.pop(context, {
                            'name': barnName,
                            'capacity': capacity,
                            'used': used,
                            'temp': temp,
                            'humidity': humidity,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Thoát', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
