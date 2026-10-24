import 'package:flutter/foundation.dart';

// ============================================================
// MODEL BUKU & PEMINJAMAN
// ============================================================
class Book {
  final String id;
  String title, author, category;
  String? borrowedBy; // null = tersedia, selain itu = nama peminjam

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    this.borrowedBy,
  });

  bool get borrowed => borrowedBy != null;
}

class Loan {
  final String bookId, bookTitle, borrower;
  final DateTime date;
  DateTime? returnedAt;

  Loan({
    required this.bookId,
    required this.bookTitle,
    required this.borrower,
    required this.date,
    this.returnedAt,
  });

  bool get returned => returnedAt != null;
}

// ============================================================
// STORE (di memori, dipakai bersama halaman admin & anggota)
// ============================================================
class BookStore extends ChangeNotifier {
  BookStore._();
  static final BookStore instance = BookStore._();

  int _seq = 9;

  final List<Book> books = [
    Book(id: '1', title: 'Laskar Pelangi', author: 'Andrea Hirata', category: 'Novel'),
    Book(id: '2', title: 'Bumi Manusia', author: 'Pramoedya Ananta Toer', category: 'Novel'),
    Book(id: '3', title: 'Pemrograman Mobile dengan Flutter', author: 'Tim Dosen SI', category: 'Teknologi'),
    Book(id: '4', title: 'Sistem Informasi Manajemen', author: 'Jogiyanto H.M.', category: 'Teknologi'),
    Book(id: '5', title: 'Sejarah Islam Nusantara', author: 'Azyumardi Azra', category: 'Agama'),
    Book(id: '6', title: 'Fikih Muamalah Kontemporer', author: 'Tim Penulis', category: 'Agama'),
    Book(id: '7', title: 'Atomic Habits', author: 'James Clear', category: 'Pengembangan Diri'),
    Book(id: '8', title: 'Filosofi Teras', author: 'Henry Manampiring', category: 'Pengembangan Diri'),
  ];

  final List<Loan> loans = [];

  int get availableCount => books.where((b) => !b.borrowed).length;
  int get borrowedCount => books.length - availableCount;
  int borrowedBy(String name) => books.where((b) => b.borrowedBy == name).length;

  // ---------- CRUD (admin) ----------
  void add(String title, String author, String category) {
    books.add(Book(
      id: '${_seq++}',
      title: title.trim(),
      author: author.trim(),
      category: category,
    ));
    notifyListeners();
  }

  void update(Book b, String title, String author, String category) {
    b.title = title.trim();
    b.author = author.trim();
    b.category = category;
    notifyListeners();
  }

  /// false jika buku sedang dipinjam (tidak boleh dihapus)
  bool delete(Book b) {
    if (b.borrowed) return false;
    books.remove(b);
    notifyListeners();
    return true;
  }

  // ---------- Peminjaman ----------
  void borrow(Book b, String who) {
    if (b.borrowed) return;
    b.borrowedBy = who;
    loans.insert(
      0,
      Loan(bookId: b.id, bookTitle: b.title, borrower: who, date: DateTime.now()),
    );
    notifyListeners();
  }

  void giveBack(Book b) {
    for (final l in loans) {
      if (l.bookId == b.id && !l.returned) {
        l.returnedAt = DateTime.now();
        break;
      }
    }
    b.borrowedBy = null;
    notifyListeners();
  }
}