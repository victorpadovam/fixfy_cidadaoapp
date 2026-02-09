import 'package:fixfycidadaoapp/view/componets/styles.dart';
import 'package:fixfycidadaoapp/view/permission_access_page/location_access.dart';
import 'package:fixfycidadaoapp/view/permission_access_page/notificacao_permission.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navegar(context);
    });
  }

  Future<void> _navegar(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 5));

    // Navega para a tela de permissão de localização
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationNotificacaoPermission(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Fundo SVG

          /// Conteúdo central (logo + animação)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  //height: 500,
                  child: Lottie.asset(
                    'assets/lottie/city2.json',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  " Uma cidade, mais inteligente.",
                  style: urbanist500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
