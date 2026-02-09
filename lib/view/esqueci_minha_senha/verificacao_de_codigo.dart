import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:fixfycidadaoapp/view/componets/app_images.dart';
import 'package:fixfycidadaoapp/view/componets/styles.dart';
import 'package:fixfycidadaoapp/view/esqueci_minha_senha/resetar_senha.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;
  final int? userId;
  const EmailVerificationScreen({Key? key, this.email, this.userId})
      : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  TextEditingController _pinCodeController = TextEditingController();
  String _enteredCode = "";
  bool _isLoading = false;

  void _verifyCode() async {
    if (_enteredCode.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite os 4 dígitos do código")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$urlServer/verificar-codigo-alterar-senha');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'codigo': _enteredCode,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Código verificado com sucesso")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetNewPasswordScreen(
              userId: widget.userId,
            ),
          ),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ?? "Erro ao verificar")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro de conexão")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> reenviarCodigo(String email, BuildContext context) async {
    final url = Uri.parse(urlServer + '/reenviar-codigo-alterar-senha');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código reenviado com sucesso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao reenviar o código')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        minimum: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              Center(
                child: Image.asset(
                  AppImages.verificarEmailPNG,
                  width: 300,
                ),
              ),
              Text(
                'Verifique seu e-mail',
                style: urbanist500.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 8),
              Text(
                "Enviamos um código de redefinição para " +
                    widget.email.toString(),
                style: urbanist300.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 30),
              PinCodeTextField(
                appContext: context,
                length: 4,
                controller: _pinCodeController,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.grey.shade700,
                  activeColor: Colors.grey,
                  activeFillColor: Colors.blue,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _enteredCode = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_enteredCode.length == 4 && !_isLoading)
                      ? _verifyCode
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _enteredCode.length == 4
                        ? const Color(0xFF1E63F1)
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirmar'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => reenviarCodigo(widget.email ?? '', context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E63F1),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Ainda não recebeu o e-mail? Reenvie o e-mail.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
