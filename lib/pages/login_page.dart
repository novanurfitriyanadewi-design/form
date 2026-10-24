import 'package:flutter/material.dart';
import '../main.dart';

// ============================================================
// HALAMAN LOGIN (Admin: username | Anggota: NIM atau Email)
// ============================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  final _passFocus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final member =
    MemberRegistry.login(_idController.text, _passController.text);

    if (member == null) {
      showAppSnack(context, 'Username/NIM/Email atau password salah', kError,
          Icons.error_outline_rounded);
      return;
    }

    // HomePage otomatis mengarahkan: admin -> panel admin, anggota -> katalog
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomePage(name: member.name)),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kPrimaryDeep,
      ),
      body: Center(
        child: ConstrainedBox(
          // Dibatasi lebarnya supaya rapi di Chrome desktop
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.local_library_rounded,
                      color: kPrimary, size: 34),
                ),
                const SizedBox(height: 18),
                const Text('Masuk',
                    style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                    'Admin masuk dengan username. Anggota masuk dengan NIM atau email.',
                    style: TextStyle(color: kMuted, fontSize: 14)),
                const SizedBox(height: 26),
                Container(
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
                          controller: _idController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: inputStyle('Username, NIM, atau Email',
                              Icons.account_circle_rounded),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Username, NIM, atau email tidak boleh kosong'
                              : null,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_passFocus),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passController,
                          focusNode: _passFocus,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          decoration: inputStyle(
                            'Password',
                            Icons.lock_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: kMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password tidak boleh kosong'
                              : null,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: kPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _login,
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Masuk',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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
}