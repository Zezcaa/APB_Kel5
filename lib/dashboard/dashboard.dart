import 'package:flutter/material.dart';
import 'package:flutter_tubes/dashboard/homescreen.dart';
import 'package:flutter_tubes/dashboard/reservasi.dart';
import 'package:flutter_tubes/dashboard/caridokter.dart';
import 'package:flutter_tubes/dashboard/rawatinap.dart';
import 'package:flutter_tubes/dashboard/profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        resizeToAvoidBottomInset: false, // <- Ini penting banget!
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Row(
            children: [
              Image.asset('assets/logo.jpeg', height: 35),
              const SizedBox(width: 10),
              const Text('Healthycare', style: TextStyle(color: Colors.black)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0), // Biar TabBar gak ketimpa
              child: TabBarView(
                children: [
                  HomeScreen(),
                  BookingPage(),
                  FindDoctorWithSchedulePage(),
                  InpatientRoomPage(),
                  ProfilePage(),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                elevation: 8,
                child: TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: "Home"),
                    Tab(icon: Icon(Icons.calendar_today), text: "Reservasi"),
                    Tab(icon: Icon(Icons.search), text: "Cari Dokter"),
                    Tab(icon: Icon(Icons.bed), text: "Rawat"),
                    Tab(icon: Icon(Icons.person), text: "Profile"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
