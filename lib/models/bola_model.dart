class Bola {
  final String id;
  final String judul; // Di Flutter kita sebut 'judul' biar gampang
  final String skor;

  Bola({required this.id, required this.judul, required this.skor});

  factory Bola.fromJson(Map<String, dynamic> json) {
    return Bola(
      id: json['id'] ?? '0', // Jaga-jaga kalau null
      // KUNCINYA DI SINI:
      // Ambil dari 'pertandingan'. Kalau gak ada, coba cari 'judul'.
      judul: json['pertandingan'] ?? json['judul'] ?? 'Tanpa Judul',
      skor: json['skor'] ?? '0 - 0',
    );
  }
}
