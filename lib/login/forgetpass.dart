import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp.dart'; // Import halaman OTP

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  _ForgetPassState createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendResetCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.2:8000/api/forgot-password'), // Sesuaikan URL
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': emailController.text.trim()}),
      );

      // =================================================================
      // PERUBAHAN DI SINI: Cetak respons dari server ke console
      debugPrint('Respons dari Server: ${response.body}');
      // =================================================================

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jika berhasil, pindah ke halaman OTP sambil mengirim email
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(email: emailController.text.trim()),
          ),
        );
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal mengirim kode.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lupa Password"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/logo.jpeg', width: 120, height: 120),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Terdaftar',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Kirim Kode Reset', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}