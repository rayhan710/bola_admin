import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/bola_provider.dart';
import '../models/highlight_model.dart';
import 'login_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  final String role;
  const HomePage({super.key, required this.role});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _keyword = "";
  final String _apiUrl = "http://10.0.2.2/bola_api";

  // --- UI CONSTANTS ---
  final Color _primaryColor = const Color(0xFF1B5E20); // Hijau Tua Premium
  final Color _accentColor = const Color(0xFFFF9800); // Oranye Aksen

  Future<void> _hapusData(String id) async {
    await http.post(
      Uri.parse("$_apiUrl/aksi.php"),
      body: {'action': 'hapus', 'id': id},
    );
    ref.refresh(bolaProvider);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listBola = ref.watch(bolaProvider);
    final listNews = ref.watch(highlightProvider);
    bool isAdmin = (widget.role == 'admin');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background Abu Sangat Muda
      // Tombol Floating Action (Hanya Admin)
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: _accentColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Jadwal Baru",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _dialogTambah(),
            )
          : null,

      body: Column(
        children: [
          // --- BAGIAN 1: HEADER CUSTOM (Gradient + Search) ---
          _buildHeader(isAdmin),

          // --- BAGIAN 2: KONTEN SCROLLABLE ---
          Expanded(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(), // Efek mantul saat scroll mentok
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // SECTION: BERITA UTAMA
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Text("Highlight Berita", style: _headerStyle()),
                  ),
                  _buildNewsSlider(listNews),

                  const SizedBox(height: 25),

                  // SECTION: LIVE SCORE
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Match Update", style: _headerStyle()),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.circle, color: Colors.red, size: 10),
                              SizedBox(width: 5),
                              Text(
                                "LIVE",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // LIST SCORE
                  _buildScoreList(listBola, isAdmin),

                  const SizedBox(
                    height: 80,
                  ), // Ruang kosong bawah biar gak ketutup tombol
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, const Color(0xFF43A047)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Baris Atas (Judul & Logout)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdmin ? "Admin Dashboard" : "Football Info",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Update Skor Terkini",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar Modern
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _keyword = val.toLowerCase()),
              decoration: const InputDecoration(
                hintText: "Cari tim favoritmu...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSlider(AsyncValue<List<Highlight>> listNews) {
    return listNews.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox(
        height: 100,
        child: Center(child: Text("Gagal memuat berita")),
      ),
      data: (news) {
        if (news.isEmpty) return const SizedBox();
        return SizedBox(
          height: 220,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return Container(
                margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(item.gambar),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          "HOT NEWS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
    );
  }

  Widget _buildScoreList(AsyncValue<List<dynamic>> listBola, bool isAdmin) {
    return listBola.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
      data: (data) {
        final filtered = data
            .where((item) => item.judul.toLowerCase().contains(_keyword))
            .toList();
        if (filtered.isEmpty)
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Tidak ada pertandingan"),
            ),
          );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bagian Score
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tim Kiri (Logic sederhana memecah string vs)
                        Expanded(
                          child: Text(
                            item.judul.split("vs")[0],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        // Skor Tengah
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            item.skor,
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Tim Kanan
                        Expanded(
                          child: Text(
                            item.judul.split("vs").length > 1
                                ? item.judul.split("vs")[1]
                                : "-",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bagian Tombol Admin (Jika Admin)
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              "Edit",
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () => _dialogEdit(item),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey[300],
                          ), // Divider
                          TextButton.icon(
                            icon: const Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Hapus",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => _hapusData(item.id),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  TextStyle _headerStyle() => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // --- DIALOGS (SAMA SEPERTI SEBELUMNYA) ---
  void _dialogTambah() {
    /* Copy logika dialog tambah dari kode sebelumnya di sini (biar gak kepanjangan, isinya sama) */
    // Biar Anda tidak repot, saya tulis ulang versi singkatnya:
    final judulCtrl = TextEditingController();
    final skorCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Jadwal Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: judulCtrl,
              decoration: const InputDecoration(
                labelText: "Tim A vs Tim B",
                hintText: "Contoh: Persib vs Persija",
              ),
            ),
            TextField(
              controller: skorCtrl,
              decoration: const InputDecoration(
                labelText: "Skor",
                hintText: "0 - 0",
              ),
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
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _dialogEdit(var item) {
    final judulCtrl = TextEditingController(text: item.judul);
    final skorCtrl = TextEditingController(text: item.skor);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Skor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: judulCtrl,
              decoration: const InputDecoration(labelText: "Pertandingan"),
            ),
            TextField(
              controller: skorCtrl,
              decoration: const InputDecoration(labelText: "Skor Akhir"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Update"),
            onPressed: () async {
              await http.post(
                Uri.parse("$_apiUrl/aksi.php"),
                body: {
                  'action': 'edit',
                  'id': item.id,
                  'judul': judulCtrl.text,
                  'skor': skorCtrl.text,
                },
              );
              ref.refresh(bolaProvider);
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
