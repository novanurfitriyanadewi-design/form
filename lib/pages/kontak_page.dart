import 'package:flutter/material.dart';
import '../main.dart';
import '../models/kontak.dart';
import 'kontak_tile.dart';

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kontak = KontakStore.semua;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Kontak',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('${kontak.length} kontak tersimpan',
              style: const TextStyle(color: kMuted, fontSize: 13)),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: kontak.length,
              itemBuilder: (context, i) => KontakTile(kontak: kontak[i]),
            ),
          ),
        ],
      ),
    );
  }
}