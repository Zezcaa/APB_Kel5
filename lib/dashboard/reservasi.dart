// booking_page.dart — UI disederhanakan, input garis bawah, heading diperbaiki

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _keluhanController = TextEditingController();
  final TextEditingController _rmController = TextEditingController();

  String? _selectedGender;
  DateTime? _birthDate;
  bool? isNewPatient;
  int? patientId;
  String? _error;
  bool _isLoading = false;
  bool _submitDisabled = false;
  String? queueNumber;
  Timer? _debounce;

  List<dynamic> patientsFound = [];
  List<dynamic> clinics = [];
  List<dynamic> doctors = [];
  int? selectedClinicId;
  int? selectedDoctorId;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> checkPatientStatus() async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://172.20.10.2:8000/api/patient/status'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        isNewPatient = data['is_new'];
        patientId = data['patient_id'];
      });
      fetchClinicsAndDoctors();
    } else {
      setState(() => _error = 'Gagal cek status pasien');
    }
  }

  Future<void> fetchClinicsAndDoctors() async {
    final token = await _getToken();
    if (token == null) return;

    final clinicRes = await http.get(
      Uri.parse('http://172.20.10.2:8000/api/clinics'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final doctorRes = await http.get(
      Uri.parse('http://172.20.10.2:8000/api/doctors'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (clinicRes.statusCode == 200 && doctorRes.statusCode == 200) {
      setState(() {
        clinics = json.decode(clinicRes.body)['clinics'];
        doctors = json.decode(doctorRes.body)['doctors'];
      });
    }
  }

  Future<void> searchPatients(String keyword) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://172.20.10.2:8000/api/patients/search?name=$keyword'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          patientsFound = data['patients'];
        });
      }
    });
  }

  Future<void> createNewPatient() async {
    final token = await _getToken();
    if (token == null) return;

    final body = jsonEncode({
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text),
      'gender': _selectedGender,
      'birth_date': _birthDate?.toIso8601String(),
      'keluhan': _keluhanController.text,
    });

    final response = await http.post(
      Uri.parse('http://172.20.10.2:8000/api/patients/new'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: body,
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      patientId = data['data']['id'];
    }
  }

  Future<void> submitBooking() async {
    setState(() => _isLoading = true);
    final token = await _getToken();
    if (token == null) return;

    if (isNewPatient == true && patientId == null) {
      await createNewPatient();
    }

    if (patientId == null) {
      setState(() {
        _error = 'ID pasien tidak tersedia.';
        _isLoading = false;
      });
      return;
    }

    final body = jsonEncode({
      'clinic_id': selectedClinicId,
      'doctor_id': selectedDoctorId,
      'keluhan': _keluhanController.text,
    });

    final response = await http.post(
      Uri.parse('http://172.20.10.2:8000/api/reservasi-poli/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      setState(() {
        queueNumber = data['queue_number'].toString();
        _submitDisabled = true;
      });
    } else {
      setState(() => _error = 'Gagal submit reservasi');
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    checkPatientStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading || isNewPatient == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reservasi Pasien',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(height: 24),
                    if (isNewPatient == true) ...[
                      buildLineInput('Nama', _nameController),
                      buildLineInput('Usia', _ageController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
  value: _selectedGender,
  dropdownColor: Colors.grey[200],
  decoration: const InputDecoration(
    labelText: 'Jenis Kelamin',
    floatingLabelStyle: TextStyle(color: Colors.grey),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
  ),
  items: const [
    DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
    DropdownMenuItem(value: 'female', child: Text('Perempuan')),
  ],
  onChanged: (val) => setState(() => _selectedGender = val),
),

                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _birthDate = picked);
                        },
                        child: Text(_birthDate == null
                            ? 'Pilih Tanggal Lahir'
                            : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'),
                      ),
                    ] else ...[
                      buildLineInput('Cari Nama Pasien', _nameController, onChanged: (val) {
  searchPatients(val);
  final match = patientsFound.firstWhere(
    (p) => p['name'].toString().toLowerCase() == val.toLowerCase(),
    orElse: () => null,
  );
  if (match != null) {
    _rmController.text = match['medical_record_number'];
  }
}),
                      
                      // buildLineInput('Nomor Rekam Medis', _rmController, readOnly: true),
                      buildLineInput('Keluhan', _keluhanController),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedClinicId,
                      dropdownColor: Colors.grey[200],
                      decoration: const InputDecoration(labelText: 'Pilih Poli', 
                      floatingLabelStyle: TextStyle(color: Colors.grey),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    ),
                      items: clinics.map<DropdownMenuItem<int>>((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(c['name'].toString()),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedClinicId = val),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: selectedDoctorId,
                      dropdownColor: Colors.grey[200],
                      decoration: const InputDecoration(labelText: 'Pilih Dokter', floatingLabelStyle: TextStyle(color: Colors.grey),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    ),
                      items: doctors
                          .where((d) => d['clinic_id'] == selectedClinicId)
                          .map<DropdownMenuItem<int>>((d) {
                            return DropdownMenuItem<int>(
                              value: d['id'] as int,
                              child: Text(d['name'].toString()),
                            );
                          }).toList(),
                      onChanged: (val) => setState(() => selectedDoctorId = val),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_submitDisabled || selectedClinicId == null || selectedDoctorId == null)
                            ? null
                            : submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Kirim Reservasi',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    if (queueNumber != null) ...[
                      const SizedBox(height: 24),
                      Text('Reservasi Berhasil!',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 4),
                      Text('Nomor Antrian Anda: #$queueNumber',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ]
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildLineInput(String label, TextEditingController controller,
    {bool readOnly = false, TextInputType? keyboardType, void Function(String)? onChanged}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        cursorColor: Colors.grey, // warna kursor saat fokus
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          floatingLabelStyle: const TextStyle(color: Colors.grey), // label saat fokus
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // garis bawah saat fokus
          ),
        ),
      ),
      const SizedBox(height: 8),
    ],
  );
}

}
