import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';

  /// Guarda el token y lo marca como autenticado
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Obtiene el token actual
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Elimina el token (cerrar sesión)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Verifica si el usuario está autenticado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }
}
