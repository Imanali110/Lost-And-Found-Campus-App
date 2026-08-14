// lib/screens/splash_screen.dart
// Shows briefly while checking if user is already logged in

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/items_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Check if user is already signed in
    await context.read<AuthProvider>().init();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final loggedIn = context.read<AuthProvider>().isLoggedIn;
    if (loggedIn) context.read<ItemsProvider>().startListening();

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => loggedIn ? const HomeScreen() : const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 85, height: 85,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.search, color: Colors.white, size: 48)),
          const SizedBox(height: 18),
          const Text('Campus Lost & Found',
            style: TextStyle(color: Colors.white, fontSize: 22,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Find what matters',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 50),
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ],
      )),
    );
  }
}
