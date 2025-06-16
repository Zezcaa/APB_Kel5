import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan Notifikasi"),
        backgroundColor: Colors.white, // White background for AppBar
        elevation: 0, // No shadow for AppBar
      ),
      backgroundColor: Colors.white, // White background for the body
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Notifikasi Email"),
              subtitle: const Text("Terima pemberitahuan melalui email."),
              value: _emailNotifications,
              onChanged: (bool value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
              activeColor: Colors.green, // Set active switch color to green
              inactiveThumbColor: Colors.grey[400], // Light grey color for off state
              inactiveTrackColor: Colors.grey[300], // Light grey color for the track in off state
            ),
            SwitchListTile(
              title: const Text("Notifikasi SMS"),
              subtitle: const Text("Terima pemberitahuan melalui SMS."),
              value: _smsNotifications,
              onChanged: (bool value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
              activeColor: Colors.green, // Set active switch color to green
              inactiveThumbColor: Colors.grey[400], // Light grey color for off state
              inactiveTrackColor: Colors.grey[300], // Light grey color for the track in off state
            ),
            SwitchListTile(
              title: const Text("Notifikasi Push"),
              subtitle: const Text("Terima pemberitahuan melalui aplikasi."),
              value: _pushNotifications,
              onChanged: (bool value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
              activeColor: Colors.green, // Set active switch color to green
              inactiveThumbColor: Colors.grey[400], // Light grey color for off state
              inactiveTrackColor: Colors.grey[300], // Light grey color for the track in off state
            ),
            const SizedBox(height: 24),
            // Save Button without icon, styled like previous button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                minimumSize: const Size(double.infinity, 40), // Full width and 40 height
              ),
              onPressed: () {
                // Simulate saving settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pengaturan Notifikasi Berhasil Disimpan"),
                  ),
                );
                Navigator.pop(context); // Go back to the previous page
              },
              child: const Text(
                "Simpan Pengaturan",
                style: TextStyle(color: Colors.white), // White text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
