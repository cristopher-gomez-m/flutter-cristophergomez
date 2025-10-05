import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environments/environment.dart';
import 'session_service.dart';

class CitaService {
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
    final url = Uri.parse("${baseUrl}citas$qs");

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Error al obtener citas (${response.statusCode})');
    }
  }

  Future<void> save(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final url = Uri.parse("${baseUrl}citas");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al guardar cita (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final headers = await _getHeaders();
    final url = Uri.parse("${baseUrl}citas/$id");

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Error al obtener cita (${response.statusCode})');
    }
  }

  Future<void> edit(int id, Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final url = Uri.parse("${baseUrl}citas/$id");

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar cita (${response.statusCode})');
    }
  }

  Future<void> delete(int id) async {
    final headers = await _getHeaders();
    final url = Uri.parse("${baseUrl}citas/$id");

    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar cita (${response.statusCode})');
    }
  }
}
