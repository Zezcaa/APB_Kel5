import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Model untuk menampung data riwayat dari API
class RiwayatKunjungan {
  final String tanggal;
  final String diagnosa;
  final String jenisRawat;
  final String namaDokter;
  final String resep;
  final String sumber;
  final String? metodePembayaran;
  final String? namaKamar;

  RiwayatKunjungan({
    required this.tanggal,
    required this.diagnosa,
    required this.jenisRawat,
    required this.namaDokter,
    required this.resep,
    required this.sumber,
    this.metodePembayaran,
    this.namaKamar,
  });

  factory RiwayatKunjungan.fromJson(Map<String, dynamic> json) {
    return RiwayatKunjungan(
      tanggal: json['tanggal'] ?? 'Tanggal tidak diketahui',
      diagnosa: json['diagnosa'] ?? '-',
      jenisRawat: json['jenis_rawat'] ?? '-',
      namaDokter: json['nama_dokter'] ?? '-',
      resep: json['resep'] ?? '-',
      sumber: json['sumber'] ?? '-',
      metodePembayaran: json['metode_pembayaran'],
      namaKamar: json['kamar'],
    );
  }
}

class RiwayatKunjunganPage extends StatefulWidget {
  const RiwayatKunjunganPage({super.key});

  @override
  State<RiwayatKunjunganPage> createState() => _RiwayatKunjunganPageState();
}

class _RiwayatKunjunganPageState extends State<RiwayatKunjunganPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<RiwayatKunjungan> _riwayatList = [];

  @override
  void initState() {
    super.initState();
    _fetchRiwayatKunjungan();
  }

  Future<void> _fetchRiwayatKunjungan() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final response = await http.get(
        Uri.parse('http://172.20.10.2:8000/api/riwayat-kunjungan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _riwayatList = data.map((json) => RiwayatKunjungan.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat riwayat. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Riwayat Kunjungan"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Rawat Jalan'),
              Tab(text: 'Rawat Inap'),
            ],
          ),
        ),
        body: _buildTabContent(),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchRiwayatKunjungan,
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    final hasilPeriksaList = _riwayatList.where((e) => e.sumber == 'Poliklinik').toList();
    final reservasiKamarList = _riwayatList.where((e) => e.sumber == 'Reservasi Kamar').toList();

    return TabBarView(
      children: [
        // Tab 1: Rawat Jalan
        RefreshIndicator(
          onRefresh: _fetchRiwayatKunjungan,
          child: hasilPeriksaList.isEmpty
              ? const Center(child: Text("Belum ada hasil periksa."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hasilPeriksaList.length,
                  itemBuilder: (context, index) => buildCard(hasilPeriksaList[index]),
                ),
        ),

        // Tab 2: Rawat Inap
        RefreshIndicator(
          onRefresh: _fetchRiwayatKunjungan,
          child: reservasiKamarList.isEmpty
              ? const Center(child: Text("Belum ada reservasi kamar."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reservasiKamarList.length,
                  itemBuilder: (context, index) => buildCard(reservasiKamarList[index]),
                ),
        ),
      ],
    );
  }

  Widget buildCard(RiwayatKunjungan kunjungan) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Text(kunjungan.tanggal, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          // Text("Jenis Rawat: ${kunjungan.jenisRawat}"),
          if (kunjungan.sumber == "Poliklinik") ...[
            Text("Dokter: ${kunjungan.namaDokter}"),
            Text("Diagnosa: ${kunjungan.diagnosa}"),
            Text("Resep: ${kunjungan.resep}"),
          ],
          if (kunjungan.sumber == "Reservasi Kamar") ...[
            Text("Kamar: ${kunjungan.namaKamar ?? '-'}"),
            Text("Metode Pembayaran: ${kunjungan.metodePembayaran ?? '-'}"),
          ],
          // Text("Sumber: ${kunjungan.sumber}"),
        ],
      ),
    ),
  );
}
}
