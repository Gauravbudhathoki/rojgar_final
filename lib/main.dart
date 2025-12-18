import 'package:flutter/material.dart';
import 'package:rojgar/screens/buttom_navigation_screen.dart';
// import 'package:rojgar/screens/splash_screen.dart';
// import 'package:rojgar_1/screens/onboarding_screen.dart';
// import 'screens/login_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rojgar',
      home: const ButtomNavigationScreen(),


    );
  }
}




