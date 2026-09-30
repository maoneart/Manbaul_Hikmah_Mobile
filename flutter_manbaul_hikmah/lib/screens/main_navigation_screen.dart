import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'attendance/attendance_screen.dart';
import 'savings/savings_screen.dart';
import 'announcements/announcements_screen.dart';
import 'students/student_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const AttendanceScreen(),
      const SavingsScreen(),
      const AnnouncementsScreen(),
      const StudentListScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.gojekGreen,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Presensi'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Tabungan'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Warta'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Siswa'),
        ],
      ),
    );
  }
}
