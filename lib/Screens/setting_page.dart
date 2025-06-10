import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livestockmanagement/Screens/home_child_screens/auth_page/login_page.dart';

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

  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color inputBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

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
      return;
    }
    try {
      await currentUser?.updateDisplayName(nameController.text.trim());
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      // Lỗi đã được xử lý nhưng không hiển thị thông báo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin người dùng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              IconButton(
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  color: secondaryTextColor,
                ),
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
            style: const TextStyle(color: primaryTextColor),
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              labelStyle: const TextStyle(color: secondaryTextColor),
              prefixIcon: const Icon(Icons.person, color: secondaryTextColor),
              filled: true,
              fillColor: inputBgColor,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            enabled: isEditing,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            style: const TextStyle(color: primaryTextColor),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: secondaryTextColor),
              prefixIcon: const Icon(Icons.email, color: secondaryTextColor),
              filled: true,
              fillColor: inputBgColor,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            enabled: false,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            style: const TextStyle(color: primaryTextColor),
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              labelStyle: const TextStyle(color: secondaryTextColor),
              prefixIcon: const Icon(Icons.phone, color: secondaryTextColor),
              filled: true,
              fillColor: inputBgColor,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            enabled: isEditing,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Text(
            'Hệ thống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Thông báo',
              style: TextStyle(color: primaryTextColor),
            ),
            value: isNotificationEnabled,
            activeColor: secondaryTextColor,
            onChanged: (val) {
              setState(() {
                isNotificationEnabled = val;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: primaryTextColor),
            title: const Text(
              'Đổi mật khẩu',
              style: TextStyle(color: primaryTextColor),
            ),
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
          (dialogContext) => AlertDialog(
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có muốn đăng xuất hay không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Không'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pageContext = context;
                  Navigator.pop(dialogContext);
                  await _signOut();

                  if (mounted) {
                    Navigator.of(pageContext).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LivestockLoginPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Có', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
