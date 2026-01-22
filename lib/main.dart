import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Minimal main for debugging iPad crash
void main() {
  // Catch any errors during startup
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MinimalApp());
  }, (error, stack) {
    debugPrint('CRASH ERROR: $error');
    debugPrint('STACK: $stack');
  });
}

class MinimalApp extends StatelessWidget {
  const MinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MinimalSplash(),
    );
  }
}

class MinimalSplash extends StatefulWidget {
  const MinimalSplash({super.key});

  @override
  State<MinimalSplash> createState() => _MinimalSplashState();
}

class _MinimalSplashState extends State<MinimalSplash> {
  String _status = 'Starting...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _status = 'App started successfully!');

      // Wait 3 seconds then show success
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        setState(() => _status = 'Ready! iPad test passed.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0E2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              size: 80,
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: 30),
            const Text(
              'VitaFit',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.pinkAccent,
            ),
          ],
        ),
      ),
    );
  }
}
