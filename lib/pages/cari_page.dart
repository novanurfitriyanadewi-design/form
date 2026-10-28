import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../main.dart';
import '../models/kontak.dart';
import 'kontak_tile.dart';

class CariPage extends StatefulWidget {
  const CariPage({super.key});

  @override
  State<CariPage> createState() => _CariPageState();
}

class _CariPageState extends State<CariPage> {
  String? _terpilih;

  @override
  Widget build(BuildContext context) {
    // Filter kontak sesuai kategori yang dipilih
    final hasil = _terpilih == null
        ? <Kontak>[]
        : KontakStore.semua.where((k) => k.kategori == _terpilih).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cari Kategori',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Pilih kategori kontak dari daftar offline',
              style: TextStyle(color: kMuted, fontSize: 13)),
          const SizedBox(height: 18),
          DropdownSearch<String>(
            items: (filter, props) => KontakStore.kategori,
            selectedItem: _terpilih,
            onChanged: (v) => setState(() => _terpilih = v),
            decoratorProps: DropDownDecoratorProps(
              decoration: inputStyle('Kategori Kontak', Icons.category_rounded),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(hintText: 'Cari kategori...'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _terpilih == null
                ? 'Pilih kategori untuk melihat kontaknya'
                : '${hasil.length} kontak di kategori $_terpilih',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kPrimaryDeep),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: hasil.length,
              itemBuilder: (context, i) => KontakTile(kontak: hasil[i]),
            ),
          ),
        ],
      ),
    );
  }
}