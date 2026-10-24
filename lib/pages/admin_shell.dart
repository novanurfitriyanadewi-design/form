import 'package:flutter/material.dart';
import '../main.dart';
import '../data/book_store.dart';
import 'welcome_page.dart';
import 'user_list_page.dart';
import 'admin_books_page.dart';
import 'admin_loans_page.dart';

// ============================================================
// KERANGKA HALAMAN ADMIN (judul + tombol aksi + isi)
// ============================================================
class PageFrame extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  const PageFrame({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(color: kMuted, fontSize: 13)),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 18),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ============================================================
// SHELL ADMIN + SIDEBAR
//  - Lebar >= 900px (Chrome desktop): sidebar tetap di kiri
//  - Lebar < 900px: sidebar jadi Drawer (ikon hamburger)
// ============================================================
class AdminShell extends StatefulWidget {
  final String name;
  const AdminShell({super.key, required this.name});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _menu = <(IconData, String)>[
    (Icons.dashboard_rounded, 'Dashboard'),
    (Icons.menu_book_rounded, 'Data Buku'),
    (Icons.groups_rounded, 'Data Anggota'),
    (Icons.swap_horiz_rounded, 'Peminjaman'),
  ];

  final List<Widget> _pages = [
    const AdminDashboard(),
    const AdminBooksPage(),
    UserListPage(), // CRUD anggota via REST API (reqres.in) — khusus admin
    const AdminLoansPage(),
  ];

  void _logout() {
    MemberRegistry.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (route) => false,
    );
  }

  Widget _navTile({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon,
                    size: 22, color: selected ? kPrimaryDeep : Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? kPrimaryDeep : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebar({required bool inDrawer}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryDeep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_library_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Perpustakaan',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17)),
                        Text('Panel Admin',
                            style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Text(
                      widget.name.isNotEmpty
                          ? widget.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        const Text('Admin Perpus',
                            style:
                            TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (int i = 0; i < _menu.length; i++)
              _navTile(
                icon: _menu[i].$1,
                label: _menu[i].$2,
                selected: _index == i,
                onTap: () {
                  setState(() => _index = i);
                  if (inDrawer) Navigator.pop(context);
                },
              ),
            const Spacer(),
            Divider(color: Colors.white.withOpacity(0.2), height: 1),
            const SizedBox(height: 8),
            _navTile(
              icon: Icons.logout_rounded,
              label: 'Keluar',
              selected: false,
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(width: 270, child: _sidebar(inDrawer: false)),
                Expanded(
                  child: IndexedStack(index: _index, children: _pages),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: kPrimaryDeep,
            foregroundColor: Colors.white,
            title: Text(_menu[_index].$2),
          ),
          drawer: Drawer(
            width: 270,
            shape: const RoundedRectangleBorder(),
            child: _sidebar(inDrawer: true),
          ),
          body: IndexedStack(index: _index, children: _pages),
        );
      },
    );
  }
}

// ============================================================
// DASHBOARD ADMIN
// ============================================================
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Widget _stat(IconData icon, String label, String value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: kSoft,
            child: Icon(icon, color: kPrimaryDeep),
          ),
          const SizedBox(height: 14),
          Text(value,
              style:
              const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: kMuted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = BookStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final recent = store.loans.take(5).toList();
        return PageFrame(
          title: 'Dashboard',
          subtitle: 'Ringkasan perpustakaan',
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _stat(Icons.menu_book_rounded, 'Total Buku',
                        '${store.books.length}'),
                    _stat(Icons.library_books_rounded, 'Tersedia',
                        '${store.availableCount}'),
                    _stat(Icons.bookmark_rounded, 'Sedang Dipinjam',
                        '${store.borrowedCount}'),
                    _stat(Icons.history_rounded, 'Total Transaksi',
                        '${store.loans.length}'),
                  ],
                ),
                const SizedBox(height: 26),
                const Text('Peminjaman Terbaru',
                    style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Belum ada transaksi peminjaman.',
                        style: TextStyle(color: kMuted)),
                  )
                else
                  for (final l in recent)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kSoft),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            l.returned
                                ? Icons.check_circle_rounded
                                : Icons.bookmark_rounded,
                            color: l.returned ? kSuccess : kPrimary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.bookTitle,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text('${l.borrower} • ${formatDate(l.date)}',
                                    style: const TextStyle(
                                        color: kMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(l.returned ? 'Dikembalikan' : 'Dipinjam',
                              style: TextStyle(
                                  color: l.returned ? kSuccess : kPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}