import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/bola_model.dart';
import '../models/highlight_model.dart';

// Gunakan 10.0.2.2 agar emulator bisa akses XAMPP laptop
const String baseUrl = 'http://10.0.2.2/bola_api';

// Provider 1: Skor Bola (Lama)
final bolaProvider = FutureProvider.autoDispose<List<Bola>>((ref) async {
  final url = Uri.parse("http://10.0.2.2/bola_api/data.php");

  final res = await http.get(url);

  if (res.statusCode == 200) {
    return (json.decode(res.body) as List)
        .map((e) => Bola.fromJson(e))
        .toList();
  }
  return [];
});

// Provider 2: Highlight Berita (Lama)
final highlightProvider = FutureProvider.autoDispose<List<Highlight>>((
  ref,
) async {
  final res = await http.get(Uri.parse("$baseUrl/highlight.php"));
  if (res.statusCode == 200) {
    return (json.decode(res.body) as List)
        .map((e) => Highlight.fromJson(e))
        .toList();
  }
  return [];
});

// FUNGSI LOGIN
class AuthService {
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        // json.decode akan sukses jika di PHP sudah ada error_reporting(0)
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print("Error Login: $e");
      return false;
    }
  }
}

// --- TAMBAHKAN KELAS INI DI PALING BAWAH FILE ---

class BolaService {
  // URL ke file aksi.php
  final String urlAksi = "http://10.0.2.2/bola_api/aksi.php";

  // 1. FUNGSI TAMBAH DATA
  Future<bool> tambahBola(String judul, String skor) async {
    try {
      final response = await http.post(
        Uri.parse(urlAksi),
        body: {
          'action': 'tambah', // Wajib sama dengan di PHP
          'judul': judul,
          'skor': skor,
        },
      );

      final data = json.decode(response.body);
      return data['message'] == 'success';
    } catch (e) {
      print("Error Tambah: $e");
      return false;
    }
  }

  // 2. FUNGSI EDIT DATA (INI YANG KITA BUTUHKAN)
  Future<bool> editBola(String id, String judul, String skor) async {
    try {
      final response = await http.post(
        Uri.parse(urlAksi),
        body: {
          'action': 'edit', // Wajib 'edit' agar masuk ke logika update PHP
          'id': id, // ID lama wajib dikirim
          'judul': judul, // Judul baru
          'skor': skor, // Skor baru
        },
      );

      print("Respon Server: ${response.body}"); // Cek di debug console

      final data = json.decode(response.body);
      return data['message'] == 'success';
    } catch (e) {
      print("Error Edit: $e");
      return false;
    }
  }

  // 3. FUNGSI HAPUS DATA
  Future<bool> hapusBola(String id) async {
    try {
      final response = await http.post(
        Uri.parse(urlAksi),
        body: {'action': 'hapus', 'id': id},
      );

      final data = json.decode(response.body);
      return data['message'] == 'success';
    } catch (e) {
      print("Error Hapus: $e");
      return false;
    }
  }
}
