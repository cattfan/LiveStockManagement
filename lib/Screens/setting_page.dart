// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isNotificationEnabled = true;
  bool isEditing = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('users/${user!.uid}');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? user!.email ?? '';
      phoneController.text = data['phone'] ?? '';
    } else {
      nameController.text = '';
      emailController.text = user?.email ?? '';
      phoneController.text = '';
    }
  }

  Future<void> _saveUserInfo() async {
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('users/${user!.uid}');
    await ref.update({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thông tin người dùng')),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // AuthWrapper sẽ tự động điều hướng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin người dùng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (isEditing) {
                    _saveUserInfo();
                  }
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              hintText: 'Vui lòng nhập họ và tên',
              prefixIcon: Icon(Icons.person),
            ),
            enabled: isEditing,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Vui lòng nhập email',
              prefixIcon: Icon(Icons.email),
            ),
            enabled: isEditing,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              hintText: 'Vui lòng nhập số điện thoại',
              prefixIcon: Icon(Icons.phone),
            ),
            enabled: isEditing,
          ),

          const SizedBox(height: 20),
          const Divider(),
          const Text(
            'Hệ thống',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Thông báo'),
            value: isNotificationEnabled,
            onChanged: (val) {
              setState(() {
                isNotificationEnabled = val;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Đổi mật khẩu'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            subtitle: const Text('Tiếng Việt'),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text('Chế độ tối'),
            value: isDarkMode,
            onChanged: (val) {
              setState(() {
                isDarkMode = val;
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có muốn đăng xuất hay không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Không'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  _signOut();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Có', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
