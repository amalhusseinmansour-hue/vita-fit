import 'package:flutter/material.dart';

// MINIMAL VERSION FOR DEBUGGING iOS CRASH
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MinimalApp());
}

class MinimalApp extends StatelessWidget {
  const MinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaFit',
      debugShowCheckedModeBanner: false,
      home: const MinimalScreen(),
    );
  }
}

class MinimalScreen extends StatelessWidget {
  const MinimalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A24),
      body: Center(
        child: Text(
          'VitaFit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
