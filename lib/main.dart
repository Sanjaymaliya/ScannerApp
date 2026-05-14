
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scannerapp/theme/app_theme.dart';
import 'features/home/home_screen.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CardScannerApp());
}

class CardScannerApp extends StatelessWidget {
  const CardScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card & Passbook Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}