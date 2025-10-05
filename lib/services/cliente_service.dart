import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environments/environment.dart';
import 'session_service.dart';

class ClienteService {
  final String baseUrl = Environment.apiUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token =
        await SessionService.getToken(); 
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<dynamic>> getAll({String qs = ''}) async {
    final headers = await _getHeaders();
    final url = Uri.parse("${baseUrl}clientes$qs");

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Error al obtener clientes (${response.statusCode})');
    }
  }
}
