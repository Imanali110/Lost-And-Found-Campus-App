// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/items_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form   = GlobalKey<FormState>();
  final _nameC  = TextEditingController();
  final _rollC  = TextEditingController();
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();
  final _pass2C = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _nameC.dispose(); _rollC.dispose(); _emailC.dispose();
    _passC.dispose(); _pass2C.dispose(); super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    if (_passC.text != _pass2C.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'),
          backgroundColor: Colors.red));
      return;
    }
    try {
      await context.read<AuthProvider>().register(
        name: _nameC.text, rollNumber: _rollC.text,
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
      appBar: AppBar(title: const Text('Create Account'),
        backgroundColor: kPrimary, foregroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(key: _form, child: Column(children: [
            const SizedBox(height: 8),
            _field(_nameC,  'Full Name',    Icons.person_outline,   V.name),
            const SizedBox(height: 14),
            _field(_rollC,  'Roll Number',  Icons.badge_outlined,   V.roll),
            const SizedBox(height: 14),
            _field(_emailC, 'Email',        Icons.email_outlined,   V.email,
              type: TextInputType.emailAddress),
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
            const SizedBox(height: 14),
            TextFormField(
              controller: _pass2C,
              obscureText: true,
              decoration: _dec('Confirm Password', Icons.lock_outline),
              validator: (v) => v == null || v.isEmpty ? 'Confirm your password' : null,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login',
                style: TextStyle(color: kAccent)),
            ),
          ])),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      String? Function(String?) validator, {TextInputType? type}) {
    return TextFormField(
      controller: c, validator: validator, keyboardType: type,
      textCapitalization: TextCapitalization.words,
      decoration: _dec(label, icon),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon),
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kAccent, width: 2)),
  );
}
