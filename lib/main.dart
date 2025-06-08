import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livestockmanagement/Screens/home_child_screens/livestock_management/livestock_management_page.dart';
import 'package:livestockmanagement/Screens/statistics_page.dart';
import 'package:livestockmanagement/widgets/bottom_nav.dart';
import 'package:livestockmanagement/Screens/home_page.dart';
import 'package:livestockmanagement/Screens/setting_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/auth_page/login_page.dart';
import 'package:livestockmanagement/Screens/home_child_screens/auth_page/getusername.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FarmApp());
}

class FarmApp extends StatelessWidget {
  const FarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng quản lý chăn nuôi',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user != null &&
              (user.displayName == null || user.displayName!.isEmpty)) {
            return const GetUsernamePage();
          }
          return const HomeScreen();
        }
        return const LivestockLoginPage();
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body chỉ là HomePage
      body: const HomePage(),
      // BottomNav sẽ xử lý việc điều hướng
      bottomNavigationBar: BottomNav(
        currentIndex: 0, // Luôn ở tab Trang chủ
        onTap: (index) {
          // Logic điều hướng sẽ được xử lý trong BottomNav
        },
      ),
    );
  }
}
