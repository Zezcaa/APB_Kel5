import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'createnewpass.dart'; // Import halaman baru

class OtpScreen extends StatefulWidget {
  final String email; // Terima email dari halaman sebelumnya
  const OtpScreen({super.key, required this.email});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.2:8000/api/verify-reset-code'), // Sesuaikan URL
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': widget.email,
          'code': otpController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jika berhasil, pindah ke halaman buat password baru
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateNewPassScreen(
              email: widget.email,
              code: otpController.text.trim(),
            ),
          ),
        );
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal memverifikasi kode.';
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
        title: const Text("Masukkan Kode OTP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Kode OTP telah dikirim ke email:\n${widget.email}", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Kode OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verifikasi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}