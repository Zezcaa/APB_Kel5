import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboard.dart';
import 'ForgetPass.dart';
import 'regis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.2:8000/api/login'),
        headers: {'Accept': 'application/json'},
        body: {
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final role = data['role'];

        if (token != null && role != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('role', role);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          setState(() {
            errorMessage = "Data login tidak lengkap dari server.";
          });
        }
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Login gagal';
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        errorMessage = "Terjadi kesalahan. Coba lagi.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/logo.jpeg', width: 120, height: 120),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: usernameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (errorMessage != null)
                                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: isLoading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size(double.infinity, 40),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text("Login", style: TextStyle(color: Colors.white)),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ForgetPass()),
                                      );
                                    },
                                    child: const Text("Forgot password?", style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const Divider(thickness: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                                      );
                                    },
                                    child: const Text("Sign up", style: TextStyle(color: Colors.blue)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
