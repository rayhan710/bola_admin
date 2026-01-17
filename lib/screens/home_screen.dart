import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/bola_provider.dart';
import '../models/highlight_model.dart';
import 'login_screen.dart';

class HomePage extends ConsumerWidget {
  final String role;
  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listBola = ref.watch(bolaProvider);
    final listNews = ref.watch(highlightProvider);
    bool isAdmin = (role == 'admin');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isAdmin ? "Admin Mode" : "Client View"),
        backgroundColor: isAdmin ? Colors.green[800] : Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),

      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add),
              onPressed: () => _dialogTambah(context, ref),
            )
          : null,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: SLIDER BERITA (PAGEVIEW) ---
            listNews.when(
              loading: () => const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, s) => SizedBox(
                height: 250,
                child: Center(child: Text("Gagal load berita: $err")),
              ),
              data: (allNews) {
                if (allNews.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text("Belum ada berita")),
                  );
                }

                // PageView.builder membuat efek slider yang bisa digeser
                return SizedBox(
                  height: 250, // Tinggi area slider
                  child: PageView.builder(
                    // viewportFraction: 0.9 artinya kartu mengambil 90% lebar layar,
                    // sisanya 10% untuk mengintip kartu sebelah (supaya user tahu bisa digeser)
                    controller: PageController(viewportFraction: 0.9),
                    itemCount: allNews.length,
                    itemBuilder: (ctx, i) {
                      final item = allNews[i];

                      // Desain Kartu Slider
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        // ClipRRect supaya gambar mengikuti lengkungan border radius
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Gambar Background
                              Image.network(
                                item.gambar,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  color: Colors.grey,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ),

                              // 2. Lapisan Hitam Transparan (Gradient)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),

                              // 3. Teks Judul & Tanggal
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        "NEWS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.judul,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.tanggal,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // --- BAGIAN 2: LIVE SCORE ---
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text(
                "Live Score",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // List Jadwal Bola (Tetap Sama)
            listBola.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (data) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (ctx, i) {
                  final item = data[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.sports_soccer, color: Colors.white),
                      ),
                      title: Text(
                        item.pertandingan,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Skor: ${item.skor}",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: isAdmin
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusData(ref, item.id),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA API (Tetap Sama) ---
  final String _apiUrl = "http://localhost/bola_api";

  Future<void> _hapusData(WidgetRef ref, String id) async {
    await http.post(
      Uri.parse("$_apiUrl/aksi.php"),
      body: {'action': 'hapus', 'id': id},
    );
    ref.refresh(bolaProvider);
  }

  void _dialogTambah(BuildContext context, WidgetRef ref) {
    final judulCtrl = TextEditingController();
    final skorCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Jadwal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: judulCtrl,
              decoration: const InputDecoration(labelText: "Tim (vs)"),
            ),
            TextField(
              controller: skorCtrl,
              decoration: const InputDecoration(labelText: "Skor"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () async {
              await http.post(
                Uri.parse("$_apiUrl/aksi.php"),
                body: {
                  'action': 'tambah',
                  'judul': judulCtrl.text,
                  'skor': skorCtrl.text,
                },
              );
              ref.refresh(bolaProvider);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
