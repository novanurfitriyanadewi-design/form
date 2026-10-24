import 'package:flutter/material.dart';
import '../main.dart';
import '../data/book_store.dart';
import 'admin_shell.dart';

// ============================================================
// ADMIN: DATA BUKU (CRUD)
// ============================================================
class AdminBooksPage extends StatefulWidget {
  const AdminBooksPage({super.key});

  @override
  State<AdminBooksPage> createState() => _AdminBooksPageState();
}

class _AdminBooksPageState extends State<AdminBooksPage> {
  final _store = BookStore.instance;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- FORM TAMBAH / UBAH ----------------
  Future<void> _openForm({Book? book}) async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController(text: book?.title ?? '');
    final author = TextEditingController(text: book?.author ?? '');
    String category = book?.category ?? kGenres.first;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            book == null ? 'Tambah Buku' : 'Ubah Buku',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: title,
                    textCapitalization: TextCapitalization.words,
                    decoration: inputStyle('Judul Buku', Icons.menu_book_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Judul tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: author,
                    textCapitalization: TextCapitalization.words,
                    decoration: inputStyle('Penulis', Icons.person_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Penulis tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: category,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    decoration: inputStyle('Kategori', Icons.category_rounded),
                    items: kGenres
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setS(() => category = v ?? category),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: kMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                if (book == null) {
                  _store.add(title.text, author.text, category);
                  showAppSnack(context, 'Buku berhasil ditambahkan', kSuccess,
                      Icons.check_circle_rounded);
                } else {
                  _store.update(book, title.text, author.text, category);
                  showAppSnack(context, 'Buku berhasil diperbarui', kSuccess,
                      Icons.check_circle_rounded);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    title.dispose();
    author.dispose();
  }

  // ---------------- HAPUS ----------------
  Future<void> _confirmDelete(Book b) async {
    if (b.borrowed) {
      showAppSnack(
        context,
        '"${b.title}" sedang dipinjam ${b.borrowedBy}, tidak bisa dihapus.',
        Colors.orange.shade800,
        Icons.warning_amber_rounded,
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus buku?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('"${b.title}" akan dihapus dari katalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: kMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      _store.delete(b);
      if (mounted) {
        showAppSnack(context, 'Buku dihapus', kPrimaryDeep,
            Icons.delete_rounded);
      }
    }
  }

  // ---------------- UI ----------------
  Widget _bookCard(Book b) {
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
            width: 52,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [kPrimary, kPrimaryDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(kGenreIcons[b.category] ?? Icons.book_rounded,
                color: Colors.white, size: 26),
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
                const SizedBox(height: 2),
                Text(b.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(b.category, kSoft, kPrimaryDeep),
                    b.borrowed
                        ? _chip('Dipinjam: ${b.borrowedBy}',
                        Colors.orange.shade50, Colors.orange.shade800)
                        : _chip('Tersedia', const Color(0xFFE3F5EE), kSuccess),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ubah',
            icon: const Icon(Icons.edit_rounded, color: kPrimary),
            onPressed: () => _openForm(book: b),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_rounded, color: kError),
            onPressed: () => _confirmDelete(b),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration:
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(text,
        style: TextStyle(
            color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final q = _query.toLowerCase();
        final list = _store.books.where((b) {
          return q.isEmpty ||
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q) ||
              b.category.toLowerCase().contains(q);
        }).toList();

        return PageFrame(
          title: 'Data Buku',
          subtitle: '${_store.books.length} buku di katalog',
          action: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: kPrimary,
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Buku'),
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration:
                inputStyle('Cari judul, penulis, atau kategori',
                    Icons.search_rounded)
                    .copyWith(fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                  child: Text('Buku tidak ditemukan.',
                      style: TextStyle(color: kMuted)),
                )
                    : ListView(children: list.map(_bookCard).toList()),
              ),
            ],
          ),
        );
      },
    );
  }
}