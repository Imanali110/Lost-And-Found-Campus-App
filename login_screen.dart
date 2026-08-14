// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/items_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form     = GlobalKey<FormState>();
  final _emailC   = TextEditingController();
  final _passC    = TextEditingController();
  bool _showPass  = false;

  @override
  void dispose() {
    _emailC.dispose(); _passC.dispose(); super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    try {
      await context.read<AuthProvider>().login(
        email: _emailC.text, password: _passC.text,
      );
      if (!mounted) return;
      context.read<ItemsProvider>().startListening();
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(children: [
              // Logo
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: kPrimary, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.search, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 16),
              const Text('Campus Lost & Found',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimary)),
              const SizedBox(height: 4),
              const Text('Sign in to continue',
                style: TextStyle(color: Colors.black45)),
              const SizedBox(height: 36),

              // Form
              Form(key: _form, child: Column(children: [
                TextFormField(
                  controller: _emailC,
                  validator: V.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dec('Email', Icons.email_outlined)),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passC,
                  validator: V.password,
                  obscureText: !_showPass,
                  decoration: _dec('Password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text("Don't have an account? Register",
                    style: TextStyle(color: kAccent)),
                ),
              ])),
            ]),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kAccent, width: 2)),
  );
}
