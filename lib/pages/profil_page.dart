import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../main.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final me = MemberRegistry.current;
    final nama = me?.name ?? 'Pengguna';
    final email = me?.email ?? '-';

    // Foto anime hanya untuk akun Nova, akun lain tampil inisial
    final pakaiFoto = nama == 'Nova';

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Akun yang sedang login',
              style: TextStyle(color: kMuted, fontSize: 13)),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarGlow(
                    glowColor: kPrimary,
                    duration: const Duration(milliseconds: 2000),
                    repeat: true,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: kSoft,
                      backgroundImage: pakaiFoto
                          ? const AssetImage('assets/1.jpg')
                          : null,
                      child: pakaiFoto
                          ? null
                          : Text(
                        nama[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryDeep),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(nama,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: kMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}