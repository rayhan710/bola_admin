import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/bola_model.dart';
import '../models/highlight_model.dart'; // Jangan lupa import ini

// Ganti localhost sesuai settingan Anda sebelumnya
const String baseUrl = "http://localhost/bola_api";

// Provider 1: Skor Bola (Yang Lama)
final bolaProvider = FutureProvider.autoDispose<List<Bola>>((ref) async {
  // ... (Kode lama tetap sama, tidak perlu diubah) ...
  final res = await http.get(Uri.parse("$baseUrl/data.php"));
  if (res.statusCode == 200) {
    return (json.decode(res.body) as List)
        .map((e) => Bola.fromJson(e))
        .toList();
  }
  return [];
});

// Provider 2: Highlight Berita (BARU)
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
