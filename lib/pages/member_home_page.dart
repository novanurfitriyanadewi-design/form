import 'package:flutter/material.dart';
import '../main.dart';
import '../data/book_store.dart';
import 'welcome_page.dart';

// ============================================================
// BERANDA ANGGOTA: hanya katalog + pinjam/kembalikan
// (TIDAK ada menu Data Anggota / REST API di sini)
// ============================================================
class MemberHomePage extends StatefulWidget {
  final String name;
  const MemberHomePage({super.key, required this.name});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  final _store = BookStore.instance;
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> get _filtered {
    final q = _query.toLowerCase();
    return _store.books.where((b) {
      final matchCat = _category == 'Semua' || b.category == _category;
      final matchQuery = q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
      return matchCat && matchQuery;
    }).toList();
  }

  void _borrow(Book b) {
    _store.borrow(b, widget.name);
    showAppSnack(context, '"${b.title}" berhasil dipinjam', kPrimary,
        Icons.bookmark_added_rounded);
  }

  void _giveBack(Book b) {
    _store.giveBack(b);
    showAppSnack(context, '"${b.title}" sudah dikembalikan', kSuccess,
        Icons.check_circle_rounded);
  }

  void _logout() {
    MemberRegistry.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (route) => false,
    );
  }

  Widget _buildStatsCard() {
    final mine = _store.borrowedBy(widget.name);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Koleksi Perpustakaan',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            '${_store.books.length} Buku',
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _miniStat('Tersedia', _store.availableCount,
                    Icons.library_books_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                    'Dipinjam saya', mine, Icons.bookmark_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text('$value',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final cats = ['Semua', ...kGenres];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cats.map((c) {
        final selected = _category == c;
        return ChoiceChip(
          label: Text(c),
          selected: selected,
          showCheckmark: false,
          backgroundColor: Colors.white,
          selectedColor: kPrimary,
          side: BorderSide(color: selected ? kPrimary : kSoft),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kText,
          ),
          onSelected: (_) => setState(() => _category = c),
        );
      }).toList(),
    );
  }

  Widget _actionButton(Book b) {
    if (!b.borrowed) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _borrow(b),
        child: const Text('Pinjam',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
    if (b.borrowedBy == widget.name) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: kSoft,
          foregroundColor: kPrimaryDeep,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _giveBack(b),
        child: const Text('Kembalikan',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
    // Dipinjam anggota lain
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('Sedang dipinjam',
          style: TextStyle(
              color: kMuted, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBookTile(Book b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [kPrimary, kPrimaryDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(kGenreIcons[b.category] ?? Icons.book_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.5)),
                const SizedBox(height: 3),
                Text(b.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: kSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(b.category,
                      style: const TextStyle(
                          color: kPrimaryDeep,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _actionButton(b),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final books = _filtered;
        return Scaffold(
          body: SafeArea(
            child: Center(
              // Dibatasi lebarnya supaya rapi di Chrome desktop
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: kPrimary,
                          child: Text(
                            widget.name.isNotEmpty
                                ? widget.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Selamat datang,',
                                  style:
                                  TextStyle(color: kMuted, fontSize: 13)),
                              Text(
                                widget.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded,
                              color: kPrimary),
                          tooltip: 'Keluar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStatsCard(),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: inputStyle(
                          'Cari judul atau penulis', Icons.search_rounded)
                          .copyWith(fillColor: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryChips(),
                    const SizedBox(height: 20),
                    const Text('Katalog Buku',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (books.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('Buku tidak ditemukan.',
                              style: TextStyle(color: kMuted)),
                        ),
                      )
                    else
                      ...books.map(_buildBookTile),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}