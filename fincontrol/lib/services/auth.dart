import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://mobile-ios-login.zani0x03.eti.br/api';

  // 🚀 O ID correto da sua turma obtido no PDF de aula
  static const String sistemaId = 'f6865a12-6717-4f06-a520-85f09d767eab';

  // ==========================================
  // LOGIN 100% CONECTADO À API (COM ISOLAMENTO DE USUÁRIO)
  // ==========================================
  static Future<String> fazerLogin({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'sistemaId': sistemaId,
        }),
      );

      print("🌐 [HTTP LOGIN STATUS]: ${response.statusCode}");
      print("🌐 [HTTP LOGIN BODY]: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        
        final token = data['access_token'] ?? data['token'] ?? data['accessToken'] ?? 'token_provisorio';
        await prefs.setString('token', token);
        
        // 🚀 ADICIONADO: Salva o username de quem acabou de logar para usar no SQLite!
        await prefs.setString('username', username);

        return "sucesso";
      }
      return "credenciais_invalidas";
    } catch (e) {
      print("🚨 [CATCH LOGIN ERROR]: $e");
      return "erro_conexao";
    }
  }

  // ==========================================
  // CADASTRO 100% CONECTADO À API
  // ==========================================
  static Future<bool> register({
    required String name,
    required String surname,
    required String login,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          'name': name,
          'surname': surname,
          'login': login,
          'email': email,
          'password': password,
          'sistemaId': sistemaId,
        }),
      );

      print("🌐 [HTTP REGISTER STATUS]: ${response.statusCode}");
      print("🌐 [HTTP REGISTER BODY]: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("🚨 [CATCH REGISTER ERROR]: $e");
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username'); // 🚀 ADICIONADO: Limpa o usuário ao deslogar
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 🚀 ADICIONADO: Método que o seu novo DBHelper usa para isolar as contas!
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<bool> isLogged() async {
    final token = await getToken();
    return token != null;
  }
}