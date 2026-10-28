import 'package:faker/faker.dart' show Faker;

class Kontak {
  final String nama;
  final String telepon;
  final String email;
  final String foto; // URL foto profil
  final String kategori; // Keluarga, Teman, Kerja, dst.
  final DateTime ditambahkan;

  const Kontak({
    required this.nama,
    required this.telepon,
    required this.email,
    required this.foto,
    required this.kategori,
    required this.ditambahkan,
  });
}

// Data kontak dibuat SEKALI lalu dipakai bersama oleh halaman Kontak dan Cari,
// supaya kontak yang tampil di dua halaman itu sama.
class KontakStore {
  static const List<String> kategori = [
    'Keluarga',
    'Teman',
    'Kerja',
    'Sekolah',
    'Kampus',
    'Tetangga',
  ];

  static final List<Kontak> semua = _buat();

  static List<Kontak> _buat() {
    final f = Faker();
    return List.generate(
      20, // minimal 15
          (i) => Kontak(
        nama: f.person.name(),
        telepon: '08${f.randomGenerator.integer(999999999, min: 100000000)}',
        email: f.internet.email(),
        foto: 'https://i.pravatar.cc/150?img=${(i % 70) + 1}',
        kategori: kategori[i % kategori.length],
        ditambahkan: DateTime.now().subtract(
          Duration(days: f.randomGenerator.integer(365)),
        ),
      ),
    );
  }
}