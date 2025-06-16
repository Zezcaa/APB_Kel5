import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          const Text(
            "Tentang Kami",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "HealthyCare adalah fasilitas kesehatan yang menyediakan layanan medis berkualitas dengan tenaga medis profesional dan peralatan modern untuk memenuhi kebutuhan kesehatan Anda dan keluarga.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          const Text(
            "Fasilitas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              children: [
                _facilityCard("assets/layanan1.jpg", "Ekokardiograf"),
                _facilityCard("assets/layanan2.jpeg", "Elektromiografi"),
                _facilityCard("assets/layanan3.jpeg", "Electroencephalography"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _contactButton(context),
          const SizedBox(height: 20),

          const Text(
            "Lokasi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(-6.9731687, 107.6311621),
                  zoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.healthycare',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: LatLng(-6.9731687, 107.6311621),
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Jl. Telekomunikasi No.1, Terusan Buah Batu, Bandung - Telkom University",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static Widget _facilityCard(String imagePath, String title) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _contactButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey[100],
              title: const Column(
                children: [
                  Icon(Icons.info_outline, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text("Kontak Kami", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text("Silahkan Pilih Kontak"),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    const phone = 'tel:082118379004';
                    if (await canLaunchUrl(Uri.parse(phone))) {
                      await launchUrl(Uri.parse(phone));
                    }
                  },
                  child: const Text("Darurat"),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    const whatsapp = 'https://wa.me/6287738970912';
                    if (await canLaunchUrl(Uri.parse(whatsapp))) {
                      await launchUrl(Uri.parse(whatsapp));
                    }
                  },
                  child: const Text("WhatsApp"),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final email = Uri.encodeFull('mailto:info@healthycareclinic.com');
                    if (await canLaunchUrl(Uri.parse(email))) {
                      await launchUrl(Uri.parse(email));
                    }
                  },
                  child: const Text("Email"),
                ),
              ],
            );
          },
        );
      },
      child: const Text("Kontak Kami"),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
