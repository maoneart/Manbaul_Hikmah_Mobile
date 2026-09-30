import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/school_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SchoolProvider()),
      ],
      child: const ManbaulHikmahApp(),
    ),
  );
}

class ManbaulHikmahApp extends StatelessWidget {
  const ManbaulHikmahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manbaul Hikmah Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
