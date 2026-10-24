import 'package:flutter/material.dart';
import '../main.dart';
import '../data/book_store.dart';
import 'admin_shell.dart';

// ============================================================
// ADMIN: RIWAYAT PEMINJAMAN
// ============================================================
class AdminLoansPage extends StatelessWidget {
  const AdminLoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = BookStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final loans = store.loans;
        return PageFrame(
          title: 'Peminjaman',
          subtitle: '${store.borrowedCount} buku sedang dipinjam',
          child: loans.isEmpty
              ? const Center(
            child: Text('Belum ada transaksi peminjaman.',
                style: TextStyle(color: kMuted)),
          )
              : ListView.builder(
            itemCount: loans.length,
            itemBuilder: (_, i) {
              final l = loans[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kSoft),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: l.returned
                          ? const Color(0xFFE3F5EE)
                          : kSoft,
                      child: Icon(
                        l.returned
                            ? Icons.check_circle_rounded
                            : Icons.bookmark_rounded,
                        color: l.returned ? kSuccess : kPrimaryDeep,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.bookTitle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            'Peminjam: ${l.borrower}\n'
                                'Dipinjam: ${formatDate(l.date)}'
                                '${l.returned ? '\nDikembalikan: ${formatDate(l.returnedAt!)}' : ''}',
                            style: const TextStyle(
                                color: kMuted, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    if (!l.returned)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryDeep,
                          side: const BorderSide(color: kPrimary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final idx = store.books
                              .indexWhere((b) => b.id == l.bookId);
                          if (idx != -1) {
                            store.giveBack(store.books[idx]);
                            showAppSnack(
                              context,
                              '"${l.bookTitle}" ditandai sudah kembali',
                              kSuccess,
                              Icons.check_circle_rounded,
                            );
                          }
                        },
                        child: const Text('Tandai Kembali'),
                      )
                    else
                      const Text('Selesai',
                          style: TextStyle(
                              color: kSuccess,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}