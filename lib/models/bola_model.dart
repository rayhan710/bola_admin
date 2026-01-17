// lib/models/bola_model.dart

class Bola {
  final String id, pertandingan, skor;
  Bola({required this.id, required this.pertandingan, required this.skor});

  factory Bola.fromJson(Map json) => Bola(
    id: json['id'],
    pertandingan: json['pertandingan'],
    skor: json['skor'],
  );
}
