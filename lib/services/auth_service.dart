import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environments/environment.dart';

class AuthService {
  final String baseUrl = Environment.apiUrl;

  Future<Map<String, dynamic>> login(Map<String, dynamic> payload) async {
    final url = Uri.parse('${baseUrl}login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      // Decodifica el JSON y lo devuelve
      return jsonDecode(response.body);
    } else {
      // Lanza un error si el backend responde con error
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }
}
