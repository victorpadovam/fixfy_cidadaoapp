import 'dart:convert';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:fixfycidadaoapp/view/componets/app_images.dart';
import 'package:fixfycidadaoapp/view/componets/styles.dart';
import 'package:fixfycidadaoapp/view/esqueci_minha_senha/verificacao_de_codigo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _cpfController = TextEditingController();
  bool isButtonEnabled = false;
  bool emailLoaded = false;
  bool emailConfirmed = false;
  bool isLoading = false;
  bool isSendingCode = false;

  String? userEmail;
  int? userID;

  @override
  void initState() {
    super.initState();
    _cpfController.addListener(() {
      final cpfFormatado = _cpfController.text;

      setState(() {
        isButtonEnabled = cpfFormatado.isNotEmpty;
      });

      // ✅ Quando tiver 11 dígitos dispara a busca automática
      if (cpfFormatado.length == 14 && !isLoading && !emailLoaded) {
        fetchEmailByCpf(cpfFormatado);
      }
    });
  }

  Future<void> fetchEmailByCpf(String cpf) async {
    setState(() {
      isLoading = true;
      emailLoaded = false;
      emailConfirmed = false;
      userEmail = null;
    });

    final uri = Uri.parse('$urlServer/buscar-email/$cpf');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          userEmail = json['email'];
          userID = json['id'];
          emailLoaded = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CPF não encontrado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar e-mail: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 45, left: 15),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFF1E63F1)),
                ),
              ),

              // Conteúdo animado
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child:
                      emailLoaded ? _buildEmailConfirmation() : _buildCpfForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CPF Form
  Widget _buildCpfForm() {
    return Column(
      key: const ValueKey('cpfForm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SvgPicture.asset(
            AppImages.esqueceuASenha,
            width: 280,
          ),
        ),
        Text(
          'Esqueceu sua senha',
          style: urbanist500.copyWith(fontSize: 25),
        ),
        const SizedBox(height: 8),
        Text('Por favor, insira seu CPF para redefinir a senha',
            style: urbanist300.copyWith(fontSize: 15)),
        const SizedBox(height: 32),
        TextFormField(
          controller: _cpfController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CpfInputFormatter(),
          ],
          decoration: InputDecoration(
            floatingLabelStyle: const TextStyle(color: Color(0xFF1E63F1)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1E63F1),
                width: 2,
              ),
            ),
            labelText: 'CPF',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isButtonEnabled && !isLoading
                ? () => fetchEmailByCpf(_cpfController.text)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled && !isLoading
                  ? const Color(0xFF1E63F1)
                  : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Pesquisar',
                    style: TextStyle(
                      color: isButtonEnabled ? Colors.white : Colors.black26,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // E-mail Confirmation
  Widget _buildEmailConfirmation() {
    return Column(
      key: const ValueKey('emailConfirm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Center(
          child: Image.asset(
            AppImages.confirmarEmailPNG,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Selecione o e-mail correspondente ao seu CPF para envio do código',
          style: urbanist500.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 15),
        CheckboxListTile(
          activeColor: const Color(0xFF1E63F1),
          title: Text(userEmail ?? ''),
          value: emailConfirmed,
          onChanged: (value) {
            setState(() {
              emailConfirmed = value ?? false;
            });
          },
        ),
        const SizedBox(height: 32),
        if (emailConfirmed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSendingCode
                  ? null
                  : () async {
                      setState(() => isSendingCode = true);
                      await enviarCodigoParaEmail(
                        userEmail!,
                        userID!,
                      );
                      setState(() => isSendingCode = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E63F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isSendingCode
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Confirmar E-mail',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
      ],
    );
  }

  Future<void> enviarCodigoParaEmail(String email, int userId) async {
    final uri = Uri.parse('$urlServer/enviar-codigo');

    try {
      final response = await http.post(uri, body: {'email': email});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código enviado para o e-mail')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationScreen(email: email, userId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar código')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }
}
