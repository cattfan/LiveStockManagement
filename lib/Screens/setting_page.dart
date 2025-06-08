import 'package:firebase_auth/firebase_auth.dart';
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

  final User? currentUser = FirebaseAuth.instance.currentUser;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: currentUser?.displayName ?? 'Chưa có tên',
    );
    emailController = TextEditingController(
      text: currentUser?.email ?? 'Không có email',
    );
    phoneController = TextEditingController(
      text: currentUser?.phoneNumber ?? 'Chưa có SĐT',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _saveUserInfo() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tên không được để trống')));
      return;
    }
    try {
      await currentUser?.updateDisplayName(nameController.text.trim());
      // Bạn có thể thêm logic cập nhật số điện thoại vào Realtime DB nếu cần
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật thông tin!')));
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
    }
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
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person),
            ),
            enabled: isEditing,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            enabled: false,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
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
                  Navigator.pop(context);
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
