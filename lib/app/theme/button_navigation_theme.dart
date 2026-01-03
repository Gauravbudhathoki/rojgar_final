
import 'package:flutter/material.dart';

BottomNavigationBarThemeData getBottomNavigationTheme() {
  return const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,

    selectedItemColor: Color(0xFF43B925),
    unselectedItemColor: Colors.grey,

    selectedIconTheme: IconThemeData(
      size: 22,
      color: Color(0xFF43B925),
    ),
    unselectedIconTheme: IconThemeData(
      size: 20,
      color: Colors.grey,
    ),

    selectedLabelStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Color(0xFF43B925),
    ),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      color: Colors.grey,
    ),

    elevation: 12,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  );
}
