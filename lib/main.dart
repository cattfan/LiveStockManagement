import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livestockmanagement/Screens/statistics_page.dart';
import 'package:livestockmanagement/widgets/bottom_nav.dart';
import 'package:livestockmanagement/Screens/home_page.dart';
import 'package:livestockmanagement/Screens/livestock_page.dart';
import 'package:livestockmanagement/Screens/setting_page.dart';
import 'package:livestockmanagement/Screens/login_page.dart';

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
      home:
          const AuthWrapper(), // Sử dụng AuthWrapper để kiểm tra trạng thái đăng nhập
      debugShowCheckedModeBanner: false,
    );
  }
}

// Widget mới để kiểm tra trạng thái đăng nhập
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
          // Nếu người dùng đã đăng nhập, hiển thị HomeScreen
          return const HomeScreen();
        }
        // Nếu chưa, hiển thị trang đăng nhập
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    LivestockGridScreen(),
    const StatisticsPage(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
