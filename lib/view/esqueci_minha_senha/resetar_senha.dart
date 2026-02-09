import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:fixfycidadaoapp/view/componets/app_images.dart';
import 'package:fixfycidadaoapp/view/componets/styles.dart';
import 'package:fixfycidadaoapp/view/login_page/registra_token_fcm.dart';
import 'package:fixfycidadaoapp/view/splash_page/splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SetNewPasswordScreen extends StatefulWidget {
  final int? userId;
  const SetNewPasswordScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _submitNewPassword() async {
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Preencha todos os campos");
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("As senhas não coincidem");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Substitua pela URL correta da sua API
      final response = await http.post(
        Uri.parse("$urlServer/set-new-password"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "new_password": newPassword,
          "user_id": widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Senha alterada com sucesso");
        FirebaseMessaging messaging = FirebaseMessaging.instance;

        final token = await messaging.getToken();
        await enviarTokenParaServidorLaravel(
          token: token,
          userId: widget.userId.toString(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashPage(),
          ),
        );
      } else {
        final data = json.decode(response.body);
        _showSnackBar(data['message'] ?? "Erro ao alterar senha");
      }
    } catch (e) {
      _showSnackBar("Erro de conexão");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Image.asset(
                  AppImages.novaSenhaPNG,
                  width: 200,
                ),
              ),
              const SizedBox(height: 10),
              Text("Nova senha", style: urbanist500.copyWith(fontSize: 25)),
              const SizedBox(height: 8),
              Text(
                  "Crie uma nova senha. Certifique-se de que ela seja diferente das anteriores por motivos de segurança",
                  style: urbanist300.copyWith(fontSize: 15)),
              const SizedBox(height: 32),
              TextField(
                obscureText: _obscurePassword,
                controller: _passwordController,
                cursorColor: const Color(0xFF1E63F1),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: const TextStyle(
                    color: Color(0xFF1E63F1),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF1E63F1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF1E63F1),
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E63F1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E63F1),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: _obscureConfirmPassword,
                controller: _confirmPasswordController,
                cursorColor: const Color(0xFF1E63F1),
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  labelStyle: const TextStyle(
                    color: Color(0xFF1E63F1),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF1E63F1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF1E63F1),
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E63F1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E63F1),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitNewPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E63F1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Confirmar",
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
