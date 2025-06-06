import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livestock Management',
      theme: ThemeData(
        fontFamily: 'Manrope',
      ),
      home: const LivestockLoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LivestockLoginPage extends StatelessWidget {
  const LivestockLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFf8fcf8);
    const Color primaryTextColor = Color(0xFF0e1b0e);
    const Color secondaryTextColor = Color(0xFF4e974e);
    const Color inputBgColor = Color(0xFFe7f3e7);
    const Color buttonBgColor = Color(0xFF14B314);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'QUẢN LÝ CHĂN NUÔI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.015 * 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Container(
                      width: double.infinity,
                      height: 218.0,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12.0),
                        image: const DecorationImage(
                          image: AssetImage('images/Logo.png'),
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 12.0, left: 16.0, right: 16.0),
                    child: Text(
                      'Chào mừng!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tài khoản',
                          hintStyle: const TextStyle(color: secondaryTextColor, fontSize: 16.0),
                          filled: true,
                          fillColor: inputBgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16.0),
                          isDense: true,
                        ),
                        style: const TextStyle(
                          color: primaryTextColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu',
                          hintStyle: const TextStyle(color: secondaryTextColor, fontSize: 16.0),
                          filled: true,
                          fillColor: inputBgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16.0),
                          isDense: true,
                        ),
                        style: const TextStyle(
                          color: primaryTextColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 12.0, left: 16.0, right: 16.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            // Handle forgot password
                          },

                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBgColor,
                          minimumSize: const Size(84, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Handle login
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: Center(
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.015 * 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        // Handle sign up
                      },

                    ),
                  ),
                  Container(
                    height: 20.0,
                    color: bgColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}