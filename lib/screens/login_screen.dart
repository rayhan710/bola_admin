import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/bola_provider.dart'; // Pastikan path ini benar sesuai folder Anda
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Tambahkan 'SingleTickerProviderStateMixin' untuk fitur Animasi
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  // Variabel untuk Animasi
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Setup Durasi Animasi (1.2 Detik)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2. Setup Fade (Muncul pelan-pelan)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    // 3. Setup Slide (Gerak dari bawah ke atas)
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.5), // Mulai dari agak bawah
          end: Offset.zero, // Berhenti di posisi asli
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOutBack,
          ), // Efek membal sedikit
        );

    // Jalankan Animasi saat layar dibuka
    _animController.forward();
  }

  @override
  void dispose() {
    _animController
        .dispose(); // Wajib matikan animasi saat keluar halaman agar tidak memory leak
    super.dispose();
  }

  // LOGIKA LOGIN (SAMA SEPERTI SEBELUMNYA)
  Future<void> _login() async {
    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {'username': userCtrl.text, 'password': passCtrl.text},
      );

      final data = json.decode(res.body);

      if (data['status'] == 'success') {
        // AMBIL ROLE DARI SERVER
        String role = data['role'];

        if (mounted) {
          Navigator.pushReplacement(
            context,
            // KIRIM ROLE KE HOME PAGE
            MaterialPageRoute(builder: (_) => HomePage(role: role)),
          );
        }
      } else {
        // ... error handling ...
      }
    } catch (e) {
      // ... error handling ...
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ResizeToAvoidBottomInset agar background tidak rusak saat keyboard muncul
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ------------------------------------------------
          // LAYER 1: BACKGROUND IMAGE (STADION)
          // ------------------------------------------------
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Gambar Stadion Keren dari Unsplash
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1518091043644-c1d4457512c6?q=80&w=1000",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ------------------------------------------------
          // LAYER 2: DARK OVERLAY (Supaya tulisan terbaca)
          // ------------------------------------------------
          Container(
            color: Colors.black.withOpacity(0.6), // Hitam transparan 60%
          ),

          // ------------------------------------------------
          // LAYER 3: KONTEN UTAMA (LOGO & CARD)
          // ------------------------------------------------
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Bola (Animasi Fade In)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: const [
                        Icon(
                          Icons.sports_soccer,
                          size: 100,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "BOLA ADMIN",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // CARD LOGIN (Animasi Slide Up + Fade)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.9,
                          ), // Putih agak transparan (Glass effect)
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Welcome Back!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: userCtrl,
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: passCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: isLoading ? null : _login,
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            "LOGIN SEKARANG",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
