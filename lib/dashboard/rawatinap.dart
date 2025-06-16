// tambahkan ini di pubspec.yaml dependencies jika belum
// shared_preferences: ^2.2.0

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';


class AuthService {
  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://172.20.10.2:8000/api/login'),
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    } else {
      throw Exception('Login gagal');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

class ApiService {
  static Future<http.Response> postWithAuth(String endpoint, Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    return await http.post(
      Uri.parse('http://172.20.10.2:8000/api/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
  }

  static Future<http.Response> getWithAuth(String endpoint) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    return await http.get(
      Uri.parse('http://172.20.10.2:8000/api/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
}

class InpatientRoomPage extends StatefulWidget {
  const InpatientRoomPage({super.key});

  @override
  State<InpatientRoomPage> createState() => _InpatientRoomPageState();
}

class _InpatientRoomPageState extends State<InpatientRoomPage> {
  List<dynamic> rooms = [];
  Map<String, dynamic>? selectedRoom;
  bool isLoading = true;
  bool showSuccessPage = false;
  Map<String, dynamic>? receiptData;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final response = await http.get(Uri.parse('http://172.20.10.2:8000/api/rooms'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        rooms = data['rooms'];
        isLoading = false;
      });
    } else {
      print('Gagal mengambil data kamar');
    }
  }

  void selectRoom(Map<String, dynamic> room) {
    setState(() {
      selectedRoom = room;
    });
  }

  void goBackToList() {
    setState(() {
      selectedRoom = null;
      showSuccessPage = false;
      receiptData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : showSuccessPage
              ? ReservationReceiptCard(receipt: receiptData!, onBack: goBackToList)
              : selectedRoom != null
                  ? ReservationForm(
                      room: selectedRoom!,
                      onBack: goBackToList,
                      onSuccess: (receipt) {
                        setState(() {
                          showSuccessPage = true;
                          receiptData = receipt;
                          selectedRoom = null;
                        });
                      },
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'Tipe Kamar Rawat Inap',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pilih tipe kamar yang sesuai dengan kebutuhan Anda.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Reservasi Kamar',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              final imageName = (room['photo_path'] ?? 'default.jpg').trim();
                              print('📷 Load gambar: assets/$imageName');
                              return RoomCard(
                                name: room['type'],
                                description: room['description'] ?? '-',
                                imageName: imageName,
                                price: room['price'].toString(),
                                onPressed: () => selectRoom(room),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageName;
  final String price;
  final VoidCallback onPressed;

  const RoomCard({
    super.key,
    required this.name,
    required this.description,
    required this.imageName,
    required this.price,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String fileName = imageName.isNotEmpty ? imageName : 'default.jpg';
    final AssetImage imageProvider = AssetImage('assets/$fileName');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image(
              image: imageProvider,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('⚠️ Gagal load gambar kamar: assets/$fileName');
                return const SizedBox(
                  height: 200,
                  child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                Text('Rp $price', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Pesan Kamar", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ReservationForm extends StatefulWidget {
  final Map<String, dynamic> room;
  final VoidCallback onBack;
  final void Function(Map<String, dynamic> receipt) onSuccess;

  const ReservationForm({
    super.key,
    required this.room,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();

  String? selectedGender;
  DateTime? birthDate;
  DateTime? reservationDate;
  String paymentMethod = 'mandiri';

  Future<void> submitReservation() async {
    final token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User belum login')));
      return;
    }

    final payload = {
      'room_id': widget.room['id'],
      'reservation_date': reservationDate?.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'insurance_number': paymentMethod == 'asuransi' ? insuranceController.text : null,
      'patient_name': nameController.text,
      'patient_age': ageController.text,
      'patient_gender': selectedGender,
      'patient_birth_date': birthDate?.toIso8601String().split('T')[0],
    };

    try {
      final response = await ApiService.postWithAuth('reservasi', payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        final receiptRes = await ApiService.getWithAuth('reservasi/receipt/${result['reservation_id']}');

        if (receiptRes.statusCode == 200) {
          final receiptData = json.decode(receiptRes.body);
          widget.onSuccess(receiptData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal ambil struk: ${receiptRes.body}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim: ${response.statusCode} ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> pickDate(BuildContext context, DateTime? initialDate, Function(DateTime) onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
       builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue, // warna lingkaran tanggal aktif
            onPrimary: Colors.white, // warna teks dalam lingkaran aktif
            onSurface: Colors.grey[700]!, // warna teks tanggal
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // warna tombol OK & Cancel
            ),
          ),
          dialogBackgroundColor: Colors.grey[100], // background picker
        ),
        child: child!,
      );
    },
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text('Reservasi Kamar', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Kamar: ${widget.room['type']}'),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
  controller: nameController,
  cursorColor: Colors.grey, // kursor abu muda saat fokus
  decoration: InputDecoration(
    labelText: "Nama Pasien",
    floatingLabelStyle: const TextStyle(color: Colors.grey), // label saat fokus
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey), // underline saat fokus
    ),
  ),
),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ageController,
                    cursorColor: Colors.grey,
                    decoration: const InputDecoration(labelText: "Umur",
                      floatingLabelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: const UnderlineInputBorder(
                       borderSide: BorderSide(color: Colors.grey), // underline saat fokus
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    dropdownColor: Colors.grey[200],
                    decoration: const InputDecoration(
                      labelText: "Jenis Kelamin",
                      floatingLabelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey), // underline saat fokus
                        ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                    ],
                    onChanged: (value) => setState(() => selectedGender = value),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
  onTap: () => pickDate(context, birthDate, (d) => setState(() => birthDate = d)),
  child: AbsorbPointer(
    child: TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Tanggal Lahir",
        suffixIcon: Icon(Icons.calendar_today),
      ),
      style: TextStyle(color: Colors.grey[400]), // <- selalu abu muda
      controller: TextEditingController(
        text: birthDate == null
            ? ''
            : '${birthDate!.day.toString().padLeft(2, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.year}',
      ),
    ),
  ),
),


                  const SizedBox(height: 12),
                  GestureDetector(
  onTap: () => pickDate(context, reservationDate, (d) => setState(() => reservationDate = d)),
  child: AbsorbPointer(
    child: TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Tanggal Reservasi",
        suffixIcon: Icon(Icons.calendar_today),
      ),
      style: TextStyle(
        color: reservationDate == null ? Colors.grey[400] : Colors.black,
      ),
      controller: TextEditingController(
        text: reservationDate == null
            ? ''
            : '${reservationDate!.day.toString().padLeft(2, '0')}-${reservationDate!.month.toString().padLeft(2, '0')}-${reservationDate!.year}',
      ),
    ),
  ),
),

                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    dropdownColor: Colors.grey[200],
                    decoration: const InputDecoration(labelText: "Metode Pembayaran",floatingLabelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: const UnderlineInputBorder(
                       borderSide: BorderSide(color: Colors.grey), // underline saat fokus
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'mandiri', child: Text('Mandiri')),
                      DropdownMenuItem(value: 'bpjs', child: Text('BPJS')),
                      DropdownMenuItem(value: 'asuransi', child: Text('Asuransi Lain')),
                    ],
                    onChanged: (value) => setState(() => paymentMethod = value!),
                  ),
                  if (paymentMethod == 'asuransi') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: insuranceController,
                      decoration: const InputDecoration(labelText: "Nomor Asuransi"),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              submitReservation();
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text("Kirim Reservasi", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onBack,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text("Batal", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReservationReceiptCard extends StatelessWidget {
  final Map<String, dynamic> receipt;
  final VoidCallback onBack;

  const ReservationReceiptCard({
    super.key,
    required this.receipt,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final reservation = receipt['reservation'];
    final room = receipt['room'];
    final patient = receipt['patient'];
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatted = DateFormat('dd-MM-yyyy').format(DateTime.parse(reservation['reservation_date']));

    double price = 0;
    try {
      final raw = room['price'];
      if (raw is String) {
        price = double.tryParse(raw) ?? 0;
      } else if (raw is int) {
        price = raw.toDouble();
      } else if (raw is double) {
        price = raw;
      }
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          const Text("HealthyCare Hospital", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 4),
          const Text("Jl. Kesehatan No.123, Jakarta, Indonesia", textAlign: TextAlign.center),
          const Text("Telp: (021) 12345678 | Email: info@healthycare.com", textAlign: TextAlign.center),
          const Divider(height: 32, thickness: 1),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nama Pasien: ${patient['name']}", style: const TextStyle(fontSize: 16)),
                      Text("Metode Pembayaran: ${reservation['payment_method']}", style: const TextStyle(fontSize: 16)),
                      if (reservation['insurance_number'] != null && reservation['insurance_number'] != '')
                        Text("No. Asuransi: ${reservation['insurance_number']}", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Kamar: ${room['type']}", style: const TextStyle(fontSize: 16)),
                      Text("Tanggal: $dateFormatted", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Reservasi Kamar ${room['type']}", style: const TextStyle(fontSize: 16)),
                    Text(currencyFormatter.format(price), style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const Divider(thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(currencyFormatter.format(price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text("Terima kasih telah mempercayakan layanan kami.", style: TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              backgroundColor: Colors.blue,
            ),
            onPressed: onBack,
            child: const Text("Kembali ke Halaman Awal", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
