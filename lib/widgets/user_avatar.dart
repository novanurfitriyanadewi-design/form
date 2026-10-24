import 'package:flutter/material.dart';
import '../main.dart';

// ============================================================
// AVATAR: tampilkan foto dari URL, kalau kosong / gagal dimuat
// otomatis pakai huruf inisial nama.
// ============================================================
class UserAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    this.url,
    this.radius = 26,
  });

  Widget _initial() {
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      color: kSoft,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: kPrimaryDeep,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: !hasUrl
            ? _initial()
            : Image.network(
          url!,
          fit: BoxFit.cover,
          // Kalau gambar gagal dimuat -> tampilkan inisial
          errorBuilder: (_, __, ___) => _initial(),
          // Selama loading -> tampilkan inisial dulu
          loadingBuilder: (context, child, progress) =>
          progress == null ? child : _initial(),
        ),
      ),
    );
  }
}