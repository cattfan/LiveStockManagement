import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;

  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color inputBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Người dùng chưa đăng nhập.");
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      // Xác thực lại người dùng trước khi đổi mật khẩu
      await user.reauthenticateWithCredential(cred);

      // Nếu xác thực thành công, cập nhật mật khẩu mới
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        Navigator.of(context).pop();
        // DÒNG THÔNG BÁO THÀNH CÔNG ĐÃ BỊ XÓA
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'wrong-password'
                  ? 'Mật khẩu hiện tại không đúng.'
                  : 'Đã xảy ra lỗi: ${e.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xảy ra lỗi không mong muốn.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: secondaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          filled: true,
          fillColor: inputBgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16.0),
          isDense: true,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: secondaryTextColor,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Custom AppBar ---
                    Container(
                      color: pageBgColor,
                      padding: const EdgeInsets.only(
                        top: 4.0,
                        right: 16.0,
                        left: 4.0,
                        bottom: 2.0,
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: primaryTextColor,
                                size: 24,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Expanded(
                              child: Text(
                                'Đổi mật khẩu',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 48,
                            ), // Placeholder for alignment
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      hintText: 'Mật khẩu hiện tại',
                      obscureText: _obscureCurrentPassword,
                      onToggleVisibility:
                          () => setState(
                            () =>
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword,
                          ),
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Vui lòng nhập mật khẩu hiện tại'
                                  : null,
                    ),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hintText: 'Mật khẩu mới',
                      obscureText: _obscureNewPassword,
                      onToggleVisibility:
                          () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword,
                          ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Xác nhận mật khẩu mới',
                      obscureText: _obscureNewPassword,
                      onToggleVisibility:
                          () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword,
                          ),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- Nút Lưu ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryTextColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _changePassword,
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          SafeArea(top: false, child: const SizedBox(height: 8)),
        ],
      ),
    );
  }
}
