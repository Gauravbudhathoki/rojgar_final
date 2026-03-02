import 'package:flutter/material.dart';
import 'package:rojgar/feature/splash/presentation/pages/buttom_screens/post_job_screen.dart';
import '../../../splash/presentation/pages/buttom_screens/browse_screen.dart';
import '../../../splash/presentation/pages/buttom_screens/companies_screen.dart';
import '../../../splash/presentation/pages/buttom_screens/home_screen.dart';
import '../../../splash/presentation/pages/buttom_screens/profile_screen.dart';

class ButtomNavigationScreen extends StatefulWidget {
  const ButtomNavigationScreen({super.key});

  @override
  State<ButtomNavigationScreen> createState() => _ButtomNavigationScreenState();
}

class _ButtomNavigationScreenState extends State<ButtomNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CompaniesScreen(),
    const BrowseScreen(),
    const ProfileScreen(),
  ];

  void _openPostJob() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PostJobScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostJob,
        backgroundColor: const Color(0xFF43B925),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
            _buildNavItem(icon: Icons.business, label: 'Companies', index: 1),
            const SizedBox(width: 48),
            _buildNavItem(icon: Icons.search, label: 'Browse', index: 2),
            _buildNavItem(icon: Icons.person, label: 'Profile', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF43B925) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? const Color(0xFF43B925) : Colors.grey,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}