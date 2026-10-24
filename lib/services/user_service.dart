import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UserService {
  static const _baseUrl = 'https://reqres.in/api';

  // Kosongkan = mode demo (tanpa key). Kalau punya key dari
  // app.reqres.in, isi di sini. JANGAN push key asli ke repo publik.
  static const _apiKey = '';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_apiKey.isNotEmpty) 'x-api-key': _apiKey,
  };

  /// Pembungkus try-catch yang dipakai semua fungsi CRUD.
  /// Menangani: tidak ada internet, timeout, dan status code di luar [ok].
  Future<http.Response> _send(
      Future<http.Response> Function() request, {
        List<int> ok = const [200, 201],
      }) async {
    try {
      final res = await request().timeout(const Duration(seconds: 15));
      if (!ok.contains(res.statusCode)) {
        throw ApiException('Server error (kode ${res.statusCode})');
      }
      return res;
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw ApiException('Koneksi timeout, coba lagi');
    } on http.ClientException {
      throw ApiException('Tidak ada koneksi internet');
    } on FormatException {
      throw ApiException('Format respons tidak valid');
    }
  }

  // READ -> GET /users
  Future<List<UserModel>> getUsers({int page = 1}) async {
    final res = await _send(
          () => http.get(Uri.parse('$_baseUrl/users?page=$page'),
          headers: _headers),
    );
    final list = jsonDecode(res.body)['data'] as List;
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  // CREATE -> POST /users
  Future<UserModel> createUser(UserModel u) async {
    final res = await _send(
          () => http.post(Uri.parse('$_baseUrl/users'),
          headers: _headers, body: jsonEncode(u.toJson())),
    );
    final id = int.tryParse('${jsonDecode(res.body)['id']}') ??
        DateTime.now().millisecondsSinceEpoch % 100000;
    return UserModel(
      id: id,
      email: u.email,
      firstName: u.firstName,
      lastName: u.lastName,
      avatar: u.avatar,
    );
  }

  // UPDATE -> PUT /users/{id}
  Future<UserModel> updateUser(int id, UserModel u) async {
    await _send(
          () => http.put(Uri.parse('$_baseUrl/users/$id'),
          headers: _headers, body: jsonEncode(u.toJson())),
    );
    return UserModel(
      id: id,
      email: u.email,
      firstName: u.firstName,
      lastName: u.lastName,
      avatar: u.avatar,
    );
  }

  // DELETE -> DELETE /users/{id} (sukses = 204 No Content)
  Future<void> deleteUser(int id) async {
    await _send(
          () => http.delete(Uri.parse('$_baseUrl/users/$id'), headers: _headers),
      ok: const [200, 204],
    );
  }
}