import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/password_model.dart';

class PasswordsRepository {
  final String baseUrl;

  PasswordsRepository({required this.baseUrl});

  /// GET semua password
  Future<List<PasswordModel>> fetchAll() async {
    final response = await http.get(Uri.parse('$baseUrl/passwords'));

    if (response.statusCode == 200) {
      return PasswordModel.listFromJson(response.body);
    } else {
      throw Exception('Failed to load passwords');
    }
  }

  /// POST buat password baru
  Future<PasswordModel> create(PasswordModel password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/passwords'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(password.toJson()),
    );

    if (response.statusCode == 201) {
      return PasswordModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create password');
    }
  }

  /// PUT update password
  Future<PasswordModel> update(PasswordModel password) async {
    final response = await http.put(
      Uri.parse('$baseUrl/passwords/${password.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(password.toJson()),
    );

    if (response.statusCode == 200) {
      return PasswordModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update password');
    }
  }

  /// DELETE password by id
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/passwords/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete password');
    }
  }
}
