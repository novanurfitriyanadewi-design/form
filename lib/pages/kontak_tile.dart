import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/kontak.dart';

// Satu item kontak (dipakai di halaman Kontak dan halaman Cari)
class KontakTile extends StatelessWidget {
  final Kontak kontak;
  const KontakTile({super.key, required this.kontak});

  // Foto kontak; kalau gagal dimuat, tampil inisial nama
  Widget _avatar() {
    final inisial = CircleAvatar(
      radius: 24,
      backgroundColor: kSoft,
      child: Text(
        kontak.nama[0],
        style: const TextStyle(
            color: kPrimaryDeep, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: 48,
        height: 48,
        child: Image.network(
          kontak.foto,
          fit: BoxFit.cover,
          // Penting di Chrome: pakai elemen <img> HTML supaya tidak kena CORS
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, progress) =>
          progress == null ? child : inisial,
          errorBuilder: (context, error, stack) => inisial,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSoft),
      ),
      child: ListTile(
        leading: _avatar(),
        title: Text(kontak.nama,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${kontak.telepon}  •  ${kontak.kategori}\n${kontak.email}\n'
              'Ditambahkan pada ${formatter.format(kontak.ditambahkan)}',
          style: const TextStyle(color: kMuted, fontSize: 12.5),
        ),
        isThreeLine: true,
      ),
    );
  }
}