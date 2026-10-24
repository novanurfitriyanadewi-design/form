// Simpan di: lib/pages/user_list_page.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/user_service.dart'; // sesuaikan path jika berbeda
import 'admin_shell.dart' show PageFrame;

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _service = UserService();

  List<UserModel> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------------- READ ----------------
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getUsers();
      if (!mounted) return;
      setState(() => _users = data);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : kSuccess,
      ),
    );
  }

  // ---------------- FORM (tambah / ubah) ----------------
  Future<UserModel?> _showForm({UserModel? user}) {
    final formKey = GlobalKey<FormState>();
    final firstCtrl = TextEditingController(text: user?.firstName ?? '');
    final lastCtrl = TextEditingController(text: user?.lastName ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');

    return showDialog<UserModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user == null ? 'Tambah Anggota' : 'Ubah Anggota'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Nama depan'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama depan wajib diisi'
                        : null,
                  ),
                  TextFormField(
                    controller: lastCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Nama belakang'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama belakang wajib diisi'
                        : null,
                  ),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(t)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                ctx,
                UserModel(
                  id: user?.id ?? 0,
                  firstName: firstCtrl.text.trim(),
                  lastName: lastCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  avatar: user?.avatar ?? '',
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ---------------- CREATE ----------------
  Future<void> _add() async {
    final input = await _showForm();
    if (input == null) return;
    try {
      final created = await _service.createUser(input);
      if (!mounted) return;
      setState(() => _users.insert(0, created));
      _snack('Anggota berhasil ditambahkan');
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, error: true);
    }
  }

  // ---------------- UPDATE ----------------
  Future<void> _edit(UserModel old) async {
    final input = await _showForm(user: old);
    if (input == null) return;
    final oldId = old.id;
    if (oldId == null) return;
    try {
      final updated = await _service.updateUser(oldId, input);
      if (!mounted) return;
      setState(() {
        final i = _users.indexWhere((u) => u.id == old.id);
        if (i != -1) _users[i] = updated;
      });
      _snack('Data anggota berhasil diubah');
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, error: true);
    }
  }

  // ---------------- DELETE ----------------
  Future<void> _delete(UserModel u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus anggota?'),
        content: Text('${u.fullName} akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final uid = u.id;
    if (uid == null) return;
    try {
      await _service.deleteUser(uid);
      if (!mounted) return;
      setState(() => _users.removeWhere((x) => x.id == u.id));
      _snack('Anggota berhasil dihapus');
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, error: true);
    }
  }

  // ---------------- UI ----------------
  Widget _avatar(UserModel u) {
    final initial =
    u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : '?';
    if (u.avatar.isEmpty) {
      return CircleAvatar(
        backgroundColor: kSoft,
        child: Text(initial, style: const TextStyle(color: kPrimaryDeep)),
      );
    }
    return CircleAvatar(
      backgroundColor: kSoft,
      backgroundImage: NetworkImage(u.avatar),
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: kMuted),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMuted)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(
        child:
        Text('Belum ada anggota.', style: TextStyle(color: kMuted)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final u = _users[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kSoft),
            ),
            child: Row(
              children: [
                _avatar(u),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.fullName,
                          style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                      Text(u.email,
                          style: const TextStyle(
                              color: kMuted, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Ubah',
                  icon: const Icon(Icons.edit_rounded, color: kPrimary),
                  onPressed: () => _edit(u),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  icon: Icon(Icons.delete_rounded,
                      color: Colors.red.shade700),
                  onPressed: () => _delete(u),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Data Anggota',
      subtitle: 'Kelola anggota perpustakaan (REST API)',
      action: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
        ),
        onPressed: _add,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah'),
      ),
      child: _body(),
    );
  }
}