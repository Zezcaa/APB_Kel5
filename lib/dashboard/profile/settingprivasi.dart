import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _dataVisibility = true;
  bool _shareDataWithThirdParty = false;
  bool _locationAccess = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan Privasi"),
        backgroundColor: Colors.white, // Set AppBar background color to white
        elevation: 0, // Remove AppBar shadow
      ),
      backgroundColor: Colors.white, // Set the background color to white
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Visibilitas Data"),
              subtitle: const Text("Menampilkan data pribadi Anda di aplikasi."),
              value: _dataVisibility,
              onChanged: (bool value) {
                setState(() {
                  _dataVisibility = value;
                });
              },
              activeColor: Colors.green, // Set active switch color to green
              inactiveThumbColor: Colors.grey[400], // Light grey color for off state
              inactiveTrackColor: Colors.grey[300], // Light grey color for the track in off state
            ),
            SwitchListTile(
              title: const Text("Berbagi Data dengan Pihak Ketiga"),
              subtitle: const Text("Izinkan aplikasi berbagi data Anda dengan pihak ketiga."),
              value: _shareDataWithThirdParty,
              onChanged: (bool value) {
                setState(() {
                  _shareDataWithThirdParty = value;
                });
              },
              activeColor: Colors.green, // Set active switch color to green
              inactiveThumbColor: Colors.grey[400], // Light grey color for off state
              inactiveTrackColor: Colors.grey[300], // Light grey color for the track in off state
            ),
            SwitchListTile(
              title: const Text("Akses Lokasi"),
              subtitle: const Text("Izinkan aplikasi mengakses lokasi perangkat Anda."),
              value: _locationAccess,
              onChanged: (bool value) {
                setState(() {
                  _locationAccess = value;
                });
              },
              activeColor: Colors.green, // Set active switch color to green
              inactiveThumbColor: Colors.grey[400], // Light grey color for off state
              inactiveTrackColor: Colors.grey[300], // Light grey color for the track in off state
            ),
            const SizedBox(height: 24),
            // Save Button with new style
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                minimumSize: const Size(double.infinity, 40), // Full width and 40 height
              ),
              onPressed: () {
                // Simulasi menyimpan pengaturan privasi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pengaturan Privasi Berhasil Disimpan"),
                  ),
                );
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              child: const Text(
                "Simpan Pengaturan Privasi",
                style: TextStyle(color: Colors.white), // White text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
