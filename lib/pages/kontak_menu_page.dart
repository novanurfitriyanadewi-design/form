import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../main.dart';
import 'kontak_page.dart';
import 'cari_page.dart';
import 'profil_page.dart';

// Dipakai sebagai salah satu halaman di dalam AdminShell,
// jadi sidebar admin tetap tampil. ConvexAppBar ada di bawah area isi.
class KontakMenuPage extends StatefulWidget {
  const KontakMenuPage({super.key});

  @override
  State<KontakMenuPage> createState() => _KontakMenuPageState();
}

class _KontakMenuPageState extends State<KontakMenuPage> {
  int _index = 0;

  final List<Widget> _pages = const [
    KontakPage(),
    CariPage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: kPrimary,
        activeColor: Colors.white,
        color: Colors.white70,
        items: const [
          TabItem(icon: Icons.contacts_rounded, title: 'Kontak'),
          TabItem(icon: Icons.search_rounded, title: 'Cari'),
          TabItem(icon: Icons.person_rounded, title: 'Profil'),
        ],
        initialActiveIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}