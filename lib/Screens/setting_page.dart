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

  final TextEditingController nameController = TextEditingController(text: 'Nguyễn Văn A');
  final TextEditingController emailController = TextEditingController(text: 'email@example.com');
  final TextEditingController phoneController = TextEditingController(text: '0123 456 789');

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
                    // Lưu thông tin thay đổi nếu cần thiết
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu thông tin người dùng')),
                    );
                  }
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
              )
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
            enabled: isEditing,
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
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              _showLoginDialog(context);
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final TextEditingController loginUserController = TextEditingController();
    final TextEditingController loginPassController = TextEditingController();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Đăng nhập lại')),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: loginUserController,
                  decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                ),
                TextField(
                  controller: loginPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Quay lại trang cài đặt
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đăng nhập thành công')),
                    );
                  },
                  child: const Text('Đăng nhập'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
