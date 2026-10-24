import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

// Form untuk membuat (POST) dan mengubah (PUT) data anggota
class UserFormPage extends StatefulWidget {
  final UserModel? user; // null = tambah baru, berisi = edit
  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserService();
  late final _first = TextEditingController(text: widget.user?.firstName);
  late final _last = TextEditingController(text: widget.user?.lastName);
  late final _email = TextEditingController(text: widget.user?.email);
  final _lastFocus = FocusNode();
  final _emailFocus = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _lastFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final input = UserModel(
      email: _email.text.trim(),
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      avatar: widget.user?.avatar ?? '',
    );

    try {
      final isEdit = widget.user != null;
      final result = isEdit
          ? await _service.updateUser(widget.user!.id!, input)
          : await _service.createUser(input);
      if (!mounted) return;
      showAppSnack(
        context,
        isEdit
            ? 'Data ${result.fullName} berhasil diperbarui'
            : '${result.fullName} berhasil ditambahkan (id: ${result.id})',
        kSuccess,
        Icons.check_circle_rounded,
      );
      Navigator.pop(context, result);
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Gagal: ${e.message}', kError,
          Icons.error_outline_rounded);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kPrimaryDeep,
        title: Text(isEdit ? 'Edit Anggota' : 'Tambah Anggota',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.10),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _first,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputStyle('Nama Depan', Icons.person_rounded),
                  validator: (v) =>
                  v!.trim().isEmpty ? 'Nama depan tidak boleh kosong' : null,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_lastFocus),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _last,
                  focusNode: _lastFocus,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                  inputStyle('Nama Belakang', Icons.person_outline_rounded),
                  validator: (v) => v!.trim().isEmpty
                      ? 'Nama belakang tidak boleh kosong'
                      : null,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_emailFocus),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: inputStyle('Email', Icons.email_rounded),
                  validator: (v) {
                    if (v!.trim().isEmpty) return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Email harus mengandung "@"';
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white))
                        : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Anggota',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}