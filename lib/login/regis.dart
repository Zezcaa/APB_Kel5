import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Controller untuk field tanggal
  final TextEditingController dateController = TextEditingController();

  DateTime? _dateOfBirth;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        // Update teks di controller agar tampil di UI
        dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.2:8000/api/register-patient'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': fullnameController.text.trim(),
          'email': emailController.text.trim(),
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
          'password_confirmation': passwordController.text.trim(),
          'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
        }),
      );

      final data = json.decode(response.body);

      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi berhasil! Silakan login.'), backgroundColor: Colors.green),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Registrasi gagal.';
            if (data['errors'] != null) {
              _errorMessage = (data['errors'] as Map).values.first[0];
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Tidak dapat terhubung ke server. Pastikan server berjalan dan koneksi sudah benar.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Akun Pasien")),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 26),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('assets/logo.jpeg', width: 120, height: 120),
              const SizedBox(height: 20),
              TextFormField(
                controller: fullnameController,
                decoration: InputDecoration(labelText: 'Nama Lengkap', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                validator: (v) => v!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                validator: (v) => (v!.isEmpty || !v.contains('@')) ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                validator: (v) => v!.isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                validator: (v) => (v!.length < 6) ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Buat Akun', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
