import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindDoctorWithSchedulePage extends StatefulWidget {
  const FindDoctorWithSchedulePage({super.key});

  @override
  State<FindDoctorWithSchedulePage> createState() => _FindDoctorWithSchedulePageState();
}

class _FindDoctorWithSchedulePageState extends State<FindDoctorWithSchedulePage> {
  String searchQuery = '';
  List<dynamic> doctors = [];
  bool isLoadingDoctors = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    final response = await http.get(Uri.parse('http://172.20.10.2:8000/api/doctors'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        doctors = data['doctors'];
        isLoadingDoctors = false;
      });
    } else {
      print('Failed to load doctors');
    }
  }

  List<dynamic> get filteredDoctors {
    if (searchQuery.isEmpty) return doctors;
    return doctors.where((doctor) {
      final name = doctor['name'].toString().toLowerCase();
      final specialty = doctor['specialty'].toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase()) || specialty.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoadingDoctors
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Cari dokter',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorSchedulePage(
                                doctorId: doctor['id'].toString(),
                                doctorName: doctor['name'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      color: Colors.grey[100],
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
  backgroundImage: doctor['photo_path'] != null
      ? AssetImage('assets/${doctor['photo_path'].trim()}')
      : null,
  child: doctor['photo_path'] == null
      ? const Icon(Icons.person, color: Colors.white)
      : null,
  backgroundColor: Colors.grey[400],
),



        title: Text(doctor['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(doctor['specialty']),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}


class DoctorSchedulePage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const DoctorSchedulePage({super.key, required this.doctorId, required this.doctorName});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  List<dynamic> schedule = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    final response = await http.get(
      Uri.parse('http://172.20.10.2:8000/api/jadwal/${widget.doctorId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        schedule = data['schedule'];
        isLoading = false;
      });
    } else {
      print("Failed to load schedule");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Jadwal: ${widget.doctorName}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jadwal Praktik",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (schedule.isEmpty)
                    const Text("Tidak ada jadwal tersedia.")
                  else
                    ...schedule.map((item) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  item["day"],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                item["time"],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
