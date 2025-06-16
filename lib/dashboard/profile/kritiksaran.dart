import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KritikSaranPage extends StatefulWidget {
  const KritikSaranPage({super.key});

  @override
  State<KritikSaranPage> createState() => _KritikSaranPageState();
}

class _KritikSaranPageState extends State<KritikSaranPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitKritikSaran() async {
    final pesan = _controller.text.trim();

    if (pesan.isEmpty) {
      _showDialog("Gagal", "Pesan tidak boleh kosong.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.2:8000/api/kritik-saran'), // ganti IP sesuai backend
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'pesan': pesan}),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        _showDialog("Terkirim", "Terima kasih atas kritik dan saran Anda.");
        _controller.clear();
      } else {
        _showDialog("Gagal", body['message'] ?? 'Terjadi kesalahan.');
      }
    } catch (e) {
      _showDialog("Error", "Tidak dapat menghubungi server.");
    }

    setState(() => _isLoading = false);
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kritik dan Saran"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Silakan tulis kritik dan saran Anda",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Tulis di sini...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              onPressed: _isLoading ? null : _submitKritikSaran,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text("Kirim", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
