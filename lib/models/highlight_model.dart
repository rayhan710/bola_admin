class Highlight {
  final String id, judul, gambar, tanggal;

  Highlight({
    required this.id,
    required this.judul,
    required this.gambar,
    required this.tanggal,
  });

  factory Highlight.fromJson(Map json) => Highlight(
    id: json['id'],
    judul: json['judul'],
    gambar: json['gambar'],
    tanggal: json['tanggal'],
  );
}
