import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioSharedPreferences {
  static const String _key = 'usuario_logado';

  /// Salva o usuário inteiro
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user));
  }

  /// Retorna o usuário completo
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// Atualiza apenas alguns campos (merge)
  Future<void> updateUser(Map<String, dynamic> novosDados) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return;

    final dadosAtuais = jsonDecode(jsonString) as Map<String, dynamic>;
    final dadosAtualizados = {
      ...dadosAtuais,
      ...novosDados,
    };

    await prefs.setString(_key, jsonEncode(dadosAtualizados));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<Map<String, dynamic>?> getUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return jsonDecode(json);
  }
}
