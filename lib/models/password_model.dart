import 'dart:convert';

class PasswordModel {
  final String id;
  final String title;
  final String email;
  final String password;
  final String imageUrl;

  PasswordModel({
    required this.id,
    required this.title,
    required this.email,
    required this.password,
    required this.imageUrl,
  });

  /// Factory constructor untuk bikin instance dari JSON
  factory PasswordModel.fromJson(Map<String, dynamic> json) {
    return PasswordModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  /// Convert instance ke JSON (buat POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'email': email,
      'password': password,
      'imageUrl': imageUrl,
    };
  }

  /// Bikin copy baru dengan beberapa field diganti
  PasswordModel copyWith({
    String? id,
    String? title,
    String? email,
    String? password,
    String? imageUrl,
  }) {
    return PasswordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Untuk debugging / print object
  @override
  String toString() {
    return 'PasswordModel(id: $id, title: $title, email: $email, password: $password, imageUrl: $imageUrl)';
  }

  /// Untuk bandingin object
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordModel &&
        other.id == id &&
        other.title == title &&
        other.email == email &&
        other.password == password &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        email.hashCode ^
        password.hashCode ^
        imageUrl.hashCode;
  }

  /// Helper: parse list dari string JSON
  static List<PasswordModel> listFromJson(String source) {
    final List<dynamic> data = json.decode(source);
    return data.map((e) => PasswordModel.fromJson(e)).toList();
  }

  /// Helper: convert list ke JSON string
  static String listToJson(List<PasswordModel> list) {
    final data = list.map((e) => e.toJson()).toList();
    return json.encode(data);
  }
}
