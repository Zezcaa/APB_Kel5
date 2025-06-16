import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tubes/dashboard/profile/notif.dart';
import 'package:flutter_tubes/dashboard/profile/riwayatkunjungan.dart';
import 'package:flutter_tubes/dashboard/profile/settingprivasi.dart';
import 'package:flutter_tubes/dashboard/profile/ubahpass.dart';
import 'package:flutter_tubes/dashboard/profile/kritiksaran.dart';
import 'package:flutter_tubes/login/loginscreen.dart';

class UserProfile {
  final String fullName;
  final String userId;
  final String birthdate;

  UserProfile({
    required this.fullName,
    required this.userId,
    required this.birthdate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? 'Nama tidak ditemukan',
      userId: json['user_id'].toString(),
      birthdate: json['birthdate'] != null
          ? DateFormat('dd MMMM yyyy').format(DateTime.parse(json['birthdate']))
          : 'Tanggal tidak diatur',
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan, silakan login ulang.');
      }

      final response = await http.get(
        Uri.parse('http://172.20.10.2:8000/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            _profile = UserProfile.fromJson(data['data']);
            _isLoading = false;
          });
        } else {
          throw Exception('Format data profil dari API tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat profil. Status: ${response.statusCode}');
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
    // Karena ini adalah bagian dari tab, ia tidak memerlukan Scaffold sendiri
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
                'Gagal Memuat Profil\n$_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: fetchProfile, child: const Text('Coba Lagi'))
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchProfile,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile?.fullName ?? 'Nama Pengguna',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // PERBAIKAN: Interpolasi string yang benar
                      Text('ID Pasien: ${_profile?.userId ?? '...'}',
                          style: const TextStyle(color: Colors.grey)),
                      Text('Tanggal Lahir: ${_profile?.birthdate ?? '...'}',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(thickness: 1, height: 1),
          _buildMenuItem(context, icon: Icons.history, text: 'Riwayat Kunjungan', page: const RiwayatKunjunganPage()),
          _buildMenuItem(context, icon: Icons.lock, text: 'Ganti Password', page: const UbahPassPage()),
          _buildMenuItem(context, icon: Icons.notifications, text: 'Pengaturan Notifikasi', page: const NotificationSettingsPage()),
          _buildMenuItem(context, icon: Icons.shield, text: 'Pengaturan Privasi', page: const PrivacySettingsPage()),
          _buildMenuItem(context, icon: Icons.feedback, text: 'Kritik dan Saran', page: const KritikSaranPage()),
          _buildMenuItem(context, icon: Icons.exit_to_app, text: 'Logout', page: const LoginScreen()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String text, required Widget page}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (text == 'Logout') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Konfirmasi Logout'),
              content: const Text('Apakah Anda yakin ingin keluar?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                TextButton(
                  child: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }
}