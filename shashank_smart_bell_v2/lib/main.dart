import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    DevicePreview(
      builder: (context) => const SmartBellApp(),
    ),
  );
}

class SmartBellApp extends StatelessWidget {
  const SmartBellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart School Bell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
