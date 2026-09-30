import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/school_provider.dart';
import 'dashboard_screen.dart';
import 'attendance/attendance_screen.dart';
import 'savings/savings_screen.dart';
import 'announcements/announcements_screen.dart';
import 'settings/settings_screen.dart';
import 'auth/login_screen.dart';

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
    final provider = Provider.of<SchoolProvider>(context);

    // If user is logged out, show LoginScreen
    if (!provider.isLoggedIn) {
      return const LoginScreen();
    }

    final screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const AttendanceScreen(),
      const SavingsScreen(),
      const AnnouncementsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00B14F),
          unselectedItemColor: const Color(0xFF8E8E93),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Presensi'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Tabungan'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Warta'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Pengaturan'),
          ],
        ),
      ),
    );
  }
}
