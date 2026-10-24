import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/welcome_page.dart';
import 'pages/admin_shell.dart';
import 'pages/member_home_page.dart';

void main() => runApp(const PerpustakaanApp());

// ============================================================
// WARNA & TEMA (PLUM ELEGAN)
// ============================================================
const Color kBg = Color(0xFFF8EEF3);
const Color kPrimary = Color(0xFFA24A74);
const Color kPrimaryDeep = Color(0xFF7A2E5A);
const Color kSoft = Color(0xFFF3DDE8);
const Color kField = Color(0xFFFBF4F8);
const Color kText = Color(0xFF3A1F2E);
const Color kMuted = Color(0xFF9A7B8B);
const Color kError = Color(0xFFD64561);
const Color kSuccess = Color(0xFF2E9E78);

class PerpustakaanApp extends StatelessWidget {
  const PerpustakaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          surface: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: kText,
          displayColor: kText,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

// ============================================================
// HELPER
// ============================================================
InputDecoration inputStyle(String label, IconData icon, {Widget? suffix}) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: kMuted, fontSize: 14),
    floatingLabelStyle:
    const TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
    prefixIcon: Icon(icon, color: kPrimary, size: 22),
    suffixIcon: suffix,
    filled: true,
    fillColor: kField,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(kSoft),
    enabledBorder: border(kSoft),
    focusedBorder: border(kPrimary, 1.6),
    errorBorder: border(kError),
    focusedErrorBorder: border(kError, 1.6),
    errorStyle: const TextStyle(color: kError, fontSize: 12),
  );
}

void showAppSnack(
    BuildContext context, String msg, Color color, IconData icon) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
}

String formatDate(DateTime d) {
  const m = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

// ============================================================
// DATA AKUN (di memori; hilang saat aplikasi ditutup)
//   Admin   : username adminperpus / password: password
//   Anggota : siti@gmail.com / NIM 87654321 / siti123
// ============================================================
class Member {
  final String name, email, nim, password;
  final String username; // dipakai untuk login admin (kosong untuk anggota)
  final bool isAdmin;
  const Member({
    required this.name,
    required this.email,
    required this.nim,
    required this.password,
    this.username = '',
    this.isAdmin = false,
  });
}

class MemberRegistry {
  // Akun yang sedang login (null = belum login)
  static Member? current;

  static final List<Member> _members = [
    const Member(
      name: 'Admin Perpus',
      username: 'adminperpus',
      email: 'adminperpus@perpus.local',
      nim: '00000000',
      password: 'password',
      isAdmin: true, // <-- admin perpustakaan
    ),
    const Member(
      name: 'Siti Aminah',
      email: 'siti@gmail.com',
      nim: '87654321',
      password: 'siti123',
    ),
  ];

  static bool emailExists(String email) =>
      _members.any((m) => m.email == email.trim().toLowerCase());

  static bool nimExists(String nim) =>
      _members.any((m) => m.nim == nim.trim());

  // Registrasi = selalu anggota biasa (bukan admin)
  static void add({
    required String name,
    required String email,
    required String nim,
    required String password,
  }) {
    final m = Member(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      nim: nim.trim(),
      password: password,
    );
    _members.add(m);
    current = m;
  }

  // Login memakai NIM, email, ATAU username (admin) + password
  static Member? login(String id, String password) {
    final key = id.trim().toLowerCase();
    for (final m in _members) {
      final idMatch = m.email == key ||
          m.nim == key ||
          (m.username.isNotEmpty && m.username == key);
      if (idMatch && m.password == password) {
        current = m;
        return m;
      }
    }
    return null;
  }

  static void logout() => current = null;
}

// Kategori buku (dipakai di form registrasi, katalog, dan form buku admin)
const List<String> kGenres = [
  'Novel',
  'Teknologi',
  'Agama',
  'Pengembangan Diri',
];

const Map<String, IconData> kGenreIcons = {
  'Novel': Icons.auto_stories_rounded,
  'Teknologi': Icons.memory_rounded,
  'Agama': Icons.mosque_rounded,
  'Pengembangan Diri': Icons.psychology_rounded,
};

// ============================================================
// HALAMAN: REGISTRASI ANGGOTA PERPUSTAKAAN
// ============================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nimController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // FocusNode (Nama -> Email -> Password -> Konfirmasi -> NIM -> HP -> Alamat)
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _nimFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  // State pilihan
  String? _gender;
  String? _major;
  String? _semester;
  DateTime? _birthDate;
  final Set<String> _selectedGenres = {};
  bool _agreed = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _genderError;
  String? _birthError;

  final List<String> _majors = [
    'Sistem Informasi',
    'Teknik Informatika',
    'Manajemen',
    'Akuntansi',
    'Pendidikan Agama Islam',
  ];
  final List<String> _semesters =
  List.generate(8, (i) => 'Semester ${i + 1}');

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmController,
      _nimController,
      _phoneController,
      _addressController,
    ]) {
      c.dispose();
    }
    for (final f in [
      _nameFocus,
      _emailFocus,
      _passwordFocus,
      _confirmFocus,
      _nimFocus,
      _phoneFocus,
      _addressFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  // ---------------- VALIDATOR ----------------
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!v.contains('@')) return 'Email harus mengandung "@"';
    if (MemberRegistry.emailExists(v)) {
      return 'Email sudah terdaftar. Gunakan email lain.';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (v != _passwordController.text) return 'Password tidak sama';
    return null;
  }

  String? _validateNim(String? v) {
    if (v == null || v.trim().isEmpty) return 'NIM tidak boleh kosong';
    if (v.trim().length < 8) return 'NIM minimal 8 digit';
    if (MemberRegistry.nimExists(v)) {
      return 'NIM ini sudah terdaftar sebagai anggota.';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'No. HP tidak boleh kosong';
    if (v.trim().length < 10 || v.trim().length > 13) {
      return 'No. HP harus 10-13 digit';
    }
    return null;
  }

  String? _validateAddress(String? v) {
    if (v == null || v.trim().isEmpty) return 'Alamat tidak boleh kosong';
    return null;
  }

  // Kekuatan password: 0.0 - 1.0
  double get _strength {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 6) s += 0.25;
    if (p.length >= 10) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(p) && RegExp(r'[A-Za-z]').hasMatch(p)) {
      s += 0.25;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s += 0.25;
    return s;
  }

  String get _strengthLabel {
    final s = _strength;
    if (s <= 0.25) return 'Lemah';
    if (s <= 0.5) return 'Cukup';
    if (s <= 0.75) return 'Kuat';
    return 'Sangat kuat';
  }

  Color get _strengthColor {
    final s = _strength;
    if (s <= 0.25) return kError;
    if (s <= 0.5) return Colors.orange;
    return kSuccess;
  }

  // ---------------- AKSI ----------------
  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2004, 1, 1),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthError = null;
      });
    }
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _genderError = _gender == null ? 'Pilih jenis kelamin' : null;
      _birthError = _birthDate == null ? 'Pilih tanggal lahir' : null;
    });

    // Checkbox belum dicentang -> SnackBar peringatan
    if (!_agreed) {
      showAppSnack(
        context,
        'Centang Syarat & Ketentuan terlebih dahulu!',
        Colors.orange.shade800,
        Icons.warning_amber_rounded,
      );
      return;
    }

    if (!formValid || _gender == null || _birthDate == null) return;

    _showConfirmationDialog();
  }

  // AlertDialog konfirmasi berisi ringkasan data
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: const CircleAvatar(
            radius: 28,
            backgroundColor: kSoft,
            child: Icon(Icons.fact_check_rounded, color: kPrimary, size: 30),
          ),
          title: const Text(
            'Konfirmasi Data',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kField,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kSoft),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _summaryRow('Nama', _nameController.text.trim()),
                  _summaryRow('Email', _emailController.text.trim()),
                  _summaryRow(
                      'Password', '*' * _passwordController.text.length),
                  _summaryRow('NIM', _nimController.text.trim()),
                  _summaryRow('No. HP', _phoneController.text.trim()),
                  _summaryRow('Lahir',
                      _birthDate == null ? '-' : formatDate(_birthDate!)),
                  _summaryRow('Gender', _gender ?? '-'),
                  _summaryRow('Alamat', _addressController.text.trim()),
                  _summaryRow('Prodi', _major ?? '-'),
                  _summaryRow('Semester', _semester ?? '-'),
                  _summaryRow(
                      'Minat',
                      _selectedGenres.isEmpty
                          ? '-'
                          : _selectedGenres.join(', ')),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: kMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final name = _nameController.text.trim();
                MemberRegistry.add(
                  name: name,
                  email: _emailController.text,
                  nim: _nimController.text,
                  password: _passwordController.text,
                );
                Navigator.pop(dialogContext);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage(name: name)),
                      (route) => false,
                );
              },
              child: const Text('Ya, Submit'),
            ),
          ],
        );
      },
    );
  }

  // ---------------- WIDGET BANTU ----------------
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(label,
                style: const TextStyle(color: kMuted, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: kMuted)),
          Expanded(
            child: Text(
              value,
              style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryDeep, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kPrimaryDeep,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: kSoft, thickness: 1.2)),
        ],
      ),
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimary, kPrimaryDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -50, right: -40, child: _circle(170, 0.10)),
            Positioned(bottom: -60, left: -50, child: _circle(150, 0.08)),
            Positioned(top: 60, left: 230, child: _circle(50, 0.10)),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Icon(Icons.local_library_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Daftar Anggota\nPerpustakaan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lengkapi data diri kamu untuk mulai\nmeminjam dan membaca buku.',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderOption(String value, IconData icon) {
    final selected = _gender == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() {
          _gender = value;
          _genderError = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? kPrimary.withOpacity(0.10) : kField,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? kPrimary : kSoft,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _gender,
                activeColor: kPrimary,
                onChanged: (v) => setState(() {
                  _gender = v;
                  _genderError = null;
                }),
              ),
              Icon(icon, size: 18, color: selected ? kPrimary : kMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? kPrimaryDeep : kText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthField() {
    final hasError = _birthError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _pickBirthDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: kField,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: hasError ? kError : kSoft),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_rounded, color: kPrimary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _birthDate == null
                        ? 'Tanggal Lahir'
                        : formatDate(_birthDate!),
                    style: TextStyle(
                      fontSize: 15,
                      color: _birthDate == null ? kMuted : kText,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month_rounded,
                    color: kMuted, size: 20),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6),
            child: Text(_birthError!,
                style: const TextStyle(color: kError, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildPasswordStrength() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _strength,
                minHeight: 6,
                backgroundColor: kSoft,
                valueColor: AlwaysStoppedAnimation(_strengthColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _strengthLabel,
            style: TextStyle(
                color: _strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kGenres.map((g) {
        final selected = _selectedGenres.contains(g);
        return FilterChip(
          avatar: Icon(kGenreIcons[g],
              size: 16, color: selected ? kPrimaryDeep : kMuted),
          label: Text(g),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? kPrimaryDeep : kText,
          ),
          selected: selected,
          showCheckmark: false,
          backgroundColor: kField,
          selectedColor: kSoft,
          side: BorderSide(color: selected ? kPrimary : kSoft),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (v) => setState(() {
            if (v) {
              _selectedGenres.add(g);
            } else {
              _selectedGenres.remove(g);
            }
          }),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 24, 20, 30),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== AKUN =====
                    _sectionTitle('Informasi Akun', Icons.lock_person_rounded),
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                      inputStyle('Nama Lengkap', Icons.person_rounded),
                      validator: _validateName,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_emailFocus),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: inputStyle('Email', Icons.email_rounded),
                      validator: _validateEmail,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
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
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_confirmFocus),
                    ),
                    _buildPasswordStrength(),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmController,
                      focusNode: _confirmFocus,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.next,
                      decoration: inputStyle(
                        'Konfirmasi Password',
                        Icons.lock_reset_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: kMuted,
                          ),
                          onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: _validateConfirm,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_nimFocus),
                    ),

                    // ===== DATA DIRI =====
                    const SizedBox(height: 22),
                    _sectionTitle('Data Diri', Icons.badge_rounded),
                    TextFormField(
                      controller: _nimController,
                      focusNode: _nimFocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputStyle('NIM', Icons.badge_rounded),
                      validator: _validateNim,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_phoneFocus),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputStyle('No. HP', Icons.phone_rounded),
                      validator: _validatePhone,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_addressFocus),
                    ),
                    const SizedBox(height: 14),
                    _buildBirthField(),
                    const SizedBox(height: 18),
                    const Text('Jenis Kelamin',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _genderOption('Laki-laki', Icons.male_rounded),
                        const SizedBox(width: 12),
                        _genderOption('Perempuan', Icons.female_rounded),
                      ],
                    ),
                    if (_genderError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 14, top: 6),
                        child: Text(_genderError!,
                            style:
                            const TextStyle(color: kError, fontSize: 12)),
                      ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressController,
                      focusNode: _addressFocus,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: inputStyle(
                          'Alamat Lengkap', Icons.location_on_rounded),
                      validator: _validateAddress,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).unfocus(),
                    ),

                    // ===== AKADEMIK =====
                    const SizedBox(height: 22),
                    _sectionTitle('Data Akademik', Icons.school_rounded),
                    DropdownButtonFormField<String>(
                      value: _major,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: kPrimary),
                      decoration:
                      inputStyle('Program Studi', Icons.school_rounded),
                      items: _majors
                          .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      validator: (v) =>
                      v == null ? 'Pilih program studi' : null,
                      onChanged: (v) => setState(() => _major = v),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _semester,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: kPrimary),
                      decoration: inputStyle(
                          'Semester', Icons.calendar_view_month_rounded),
                      items: _semesters
                          .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      validator: (v) => v == null ? 'Pilih semester' : null,
                      onChanged: (v) => setState(() => _semester = v),
                    ),

                    // ===== PREFERENSI BACA =====
                    const SizedBox(height: 22),
                    _sectionTitle('Minat Bacaan', Icons.menu_book_rounded),
                    _buildGenreChips(),

                    // ===== SYARAT & KETENTUAN =====
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: kField,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kSoft),
                      ),
                      child: CheckboxListTile(
                        value: _agreed,
                        activeColor: kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'Saya setuju dengan Syarat & Ketentuan perpustakaan',
                          style: TextStyle(fontSize: 13),
                        ),
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: kPrimary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submit,
                        icon: const Icon(Icons.how_to_reg_rounded),
                        label: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HomePage = pengarah berdasarkan peran (role)
//   admin   -> AdminShell (sidebar: Buku, Anggota/REST API, Peminjaman)
//   anggota -> MemberHomePage (katalog + pinjam saja)
// Nama `HomePage(name: ...)` dipertahankan supaya login_page.dart
// dan RegisterPage tidak perlu diubah.
// ============================================================
class HomePage extends StatelessWidget {
  final String name;
  const HomePage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final me = MemberRegistry.current;
    if (me != null && me.isAdmin) {
      return AdminShell(name: name);
    }
    return MemberHomePage(name: name);
  }
}