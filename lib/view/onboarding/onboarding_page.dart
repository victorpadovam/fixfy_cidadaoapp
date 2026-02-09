import 'package:fixfycidadaoapp/cache/usuario_cpf_shared.dart';
import 'package:fixfycidadaoapp/view/splash_page/splash.dart';
import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _verificandoLogin = true;

  @override
  void initState() {
    super.initState();

    verificaSeUserEstaLogado();
  }

  final _pageController = PageController();
  int _index = 0;

  final data = [
    ItemData(
      title: 'Bem-vindo à Voz do Cidadão',
      subtitle:
          'Agora você pode ajudar a melhorar a sua cidade de forma simples e rápida',
      image: Lottie.asset(
        'assets/lottie/megaphone.json',
        width: 200,
        height: 200,
      ),
      backgroundColor: const Color(0xFF141218),
      titleColor: Colors.white,
      subtitleColor: Colors.white70,
    ),
    ItemData(
      title: 'Envie reclamações',
      subtitle:
          'Registre de forma rápida problemas como buracos, falhas na iluminação e outros pontos críticos da cidade.',
      image: Lottie.asset(
        'assets/lottie/marker.json',
        height: 150,
      ),
      backgroundColor: Color(0xFF1E63F1),
      titleColor: Colors.white,
      subtitleColor: Colors.white70,
    ),
  ];

  Future<void> verificaSeUserEstaLogado() async {
    final usuarioSharedPreferences = UsuarioSharedPreferences();
    final buscaUserLogado = await usuarioSharedPreferences.getUsuarioLogado();

    if (!mounted) return;

    if (buscaUserLogado != null && buscaUserLogado.isNotEmpty) {
      final String? cpf = buscaUserLogado['cpf'];

      if (cpf != null && cpf.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashPage()),
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
          /// ---------- ConcentricPageView ----------
          ConcentricPageView(
            pageController: _pageController, // ✅ usa pageController
            onChange: (i) => setState(() => _index = i),
            radius: 40,
            verticalPosition: 0.80,
            colors: data.map((e) => e.backgroundColor).toList(),
            itemCount: data.length,
            itemBuilder: (i) => ItemWidget(data: data[i]),
            // botão pronto dentro do próprio widget
            nextButtonBuilder: (context) => Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            ),
            onFinish: _finishOnboarding, // chamado ao final
          ),

          /// ---------- Botão Skip -----------
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: TextButton(
              onPressed: _finishOnboarding,
              child:
                  const Text('Fechar', style: TextStyle(color: Colors.white)),
            ),
          ),

          /// ---------- Dots indicador ----------
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: DotsIndicator(
              dotsCount: data.length,
              position: _index.toDouble(),
              decorator: DotsDecorator(
                size: const Size.square(6),
                activeSize: const Size(18, 6),
                activeColor: Colors.white,
                color: Colors.white38,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
                activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SplashPage()),
    );
  }
}

/* ------------------- modelos reutilizados ------------------- */

class ItemData {
  final String title;
  final String subtitle;
  final Widget image;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  ItemData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
  });
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({required this.data, super.key});
  final ItemData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 4),
          Flexible(flex: 18, child: data.image),
          const Spacer(flex: 2),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: data.titleColor,
              fontSize: 26,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: data.subtitleColor, fontSize: 15),
          ),
          const Spacer(flex: 10),
        ],
      ),
    );
  }
}
