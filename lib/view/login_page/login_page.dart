import 'package:brasil_fields/brasil_fields.dart';
import 'package:fixfycidadaoapp/cache/usuario_cpf_shared.dart';
import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:fixfycidadaoapp/view/esqueci_minha_senha/esqueci_minha_senha.dart';
import 'package:fixfycidadaoapp/view/home/home_page.dart';
import 'package:fixfycidadaoapp/view/login_page/cadastrar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UsuarioSharedPreferences usuarioSharedPreferences =
      UsuarioSharedPreferences();

  bool _obscurePassword = true;
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  bool isLoading = false;
  bool formPreenchido = false;
  bool manterLogado = false;
  bool _verificandoLogin = true;
  bool isCheckingLogin = true;

  @override
  void initState() {
    verificaSeUserEstaLogado();
    super.initState();
    _cpfController.addListener(_verificaCampos);
    _senhaController.addListener(_verificaCampos);
  }

  void _verificaCampos() {
    final cpfPreenchido = _cpfController.text.trim().isNotEmpty;
    final senhaPreenchida = _senhaController.text.trim().isNotEmpty;

    final preenchido = cpfPreenchido && senhaPreenchida;

    if (formPreenchido != preenchido) {
      setState(() {
        formPreenchido = preenchido;
      });
    }
  }

  Future<void> verificaSeUserEstaLogado() async {
    final usuarioSharedPreferences = UsuarioSharedPreferences();
    final buscaUserLogado = await usuarioSharedPreferences.getUsuarioLogado();

    if (!mounted) return;

    if (buscaUserLogado != null && buscaUserLogado.isNotEmpty) {
      final String? cpf = buscaUserLogado['cpf'];

      if (cpf != null && cpf.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
        return;
      }
    }

    setState(() {
      _verificandoLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_verificandoLogin) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/lottie/loading.json',
            width: 300,
            height: 200,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Fundo azul
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1E63F1),
              child: SvgPicture.asset(
                'assets/svg/elipse.svg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Conteúdo por cima
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/img/fixfylogo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Digite seu CPF e senha para fazer login',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  // Formulário de login
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CpfInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            floatingLabelStyle:
                                const TextStyle(color: Color(0xFF1E63F1)),
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
                        const SizedBox(height: 16),
                        TextField(
                          obscureText: _obscurePassword,
                          controller: _senhaController,
                          decoration: InputDecoration(
                            floatingLabelStyle:
                                const TextStyle(color: Color(0xFF1E63F1)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1E63F1),
                                width: 2,
                              ),
                            ),
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // Ícone clicável para alternar visibilidade
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Row(
                            //   children: [
                            //     Checkbox(
                            //       fillColor:
                            //           MaterialStateProperty.resolveWith<Color>(
                            //               (Set<MaterialState> states) {
                            //         if (states
                            //             .contains(MaterialState.selected)) {
                            //           return Color(0xFF1E63F1);
                            //         }
                            //         return Colors.white;
                            //       }),
                            //       checkColor: Colors.white,
                            //       value: manterLogado,
                            //       onChanged: (bool? valor) async {
                            //         if (valor == null) return;
                            //         setState(() {
                            //           manterLogado = valor;
                            //         });
                            //         final prefs =
                            //             await SharedPreferences.getInstance();
                            //         await prefs.setBool('manterLogado', valor);
                            //       },
                            //     ),
                            //     const Text(
                            //       'Manter logado',
                            //       style: TextStyle(fontSize: 13),
                            //     ),
                            //   ],
                            // ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()),
                                );
                              },
                              child: const Text(
                                'Esqueceu a senha?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E63F1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (!isLoading && formPreenchido)
                                ? () async {
                                    setState(() => isLoading = true);
                                    await _login(_cpfController.text,
                                        _senhaController.text);
                                    if (mounted)
                                      setState(() => isLoading = false);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: formPreenchido
                                  ? const Color(0xFF1E63F1)
                                  : Colors.grey.shade400,
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
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Acessar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Novo por aqui?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CadastroPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  color: Color(0xFF1E63F1),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login(String cpf, String senha) async {
    // Monta a URL do seu endpoint
    final uri = Uri.parse(urlServer + '/cidadao/login');

    try {
      // Envia POST
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'cpf': cpf,
          'senha': senha,
        }),
      );

      // Verifica o status
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final Map<String, dynamic> user =
            responseData['user'] as Map<String, dynamic>;

        await usuarioSharedPreferences.saveUser(user);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(cpf: user['cpf']),
            ),
          );
        }
      } else {
        // Decodifica a mensagem de erro vinda do backend
        final error = jsonDecode(response.body);
        final msg = (error['cpf'] != null &&
                error['cpf'] is List &&
                error['cpf'].isNotEmpty)
            ? error['cpf'][0]
            : 'CPF ou senha inválidos';

        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      // Erro de conexão ou time‑out
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Não foi possível conectar ao servidor')),
        );
      }
    }
  }
}
