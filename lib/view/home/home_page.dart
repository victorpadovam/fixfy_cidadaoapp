import 'package:fixfycidadaoapp/cache/usuario_cpf_shared.dart';
import 'package:fixfycidadaoapp/models/service/firebase_messaging_service.dart';
import 'package:fixfycidadaoapp/view/componets/app_images.dart';
import 'package:fixfycidadaoapp/view/componets/styles.dart';
import 'package:fixfycidadaoapp/view/notificacao/notificacoes_page.dart';
import 'package:fixfycidadaoapp/view/rive_app/navigation/custom_tab_bar.dart';
import 'package:fixfycidadaoapp/view/rive_app/navigation/home_tab_view.dart';
import 'package:fixfycidadaoapp/view/rive_app/navigation/side_menu.dart';
import 'package:fixfycidadaoapp/view/rive_app/on_boarding/onboarding_view.dart';
import 'package:fixfycidadaoapp/view/rive_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'dart:math' as math;
import 'package:fixfycidadaoapp/view/rive_app/assets.dart' as app_assets;

// Future<void> chat() async {
//   Navigator.of(context).push(MaterialPageRoute(
//     builder: (context) => ChatScreen(
//       reclamacaoId: '58',
//       estabelecimentoId: 1,
//     ),
//   ));
// }

Widget commonTabScene(String tabName) {
  return Container(
    color: RiveAppTheme.background,
    alignment: Alignment.center,
    child: Text(
      tabName,
      style: const TextStyle(
        fontSize: 28,
        fontFamily: "Poppins",
        color: Colors.black,
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  final cpf;
  const HomePage({Key? key, this.cpf}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

UsuarioSharedPreferences usuarioSharedPreferences = UsuarioSharedPreferences();

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController? _animationController;
  late AnimationController? _onBoardingAnimController;
  late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;
  String nomeCompleto = '';
  String cidade = '';
  String estado = '';
  String? foto;

  late SMIBool _menuBtn;

  bool _showOnBoarding = false;
  final Widget _tabBody = const HomeTabView();

  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );

  void _onMenuIconInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, "State Machine");
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
    _menuBtn.value = true;
  }

  void _presentOnBoarding(bool show) {
    if (show) {
      setState(() {
        _showOnBoarding = true;
      });
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _onBoardingAnimController?.animateWith(springAnim);
    } else {
      _onBoardingAnimController?.reverse().whenComplete(() => {
            setState(() {
              _showOnBoarding = false;
            })
          });
    }
  }

  void onMenuPress() {
    final isOpen = _menuBtn.value;

    if (isOpen) {
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }

    _menuBtn.value = !isOpen;

    SystemChrome.setSystemUIOverlayStyle(
      !isOpen ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
  }

  Future<void> _carregarUsuarioCache() async {
    final user = await usuarioSharedPreferences.getUsuarioLogado();

    if (user != null && mounted) {
      setState(() {
        nomeCompleto = user['nome'] ?? '';
        cidade = user['cidade'] ?? '';
        estado = user['estado'] ?? '';
        foto = user['foto'];
      });
    }

    inicializaFirebaseMensagem(user!['cpf']);
  }

  inicializaFirebaseMensagem(cpf) async {
    await Provider.of<FirebaseMessaginService>(
      context,
      listen: false,
    ).inicializaFirebase(cpf);
  }

  @override
  void initState() {
    _carregarUsuarioCache();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );
    _onBoardingAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _onBoardingAnimController!,
      curve: Curves.linear,
    ));
    super.initState();
  }

  buscaDadosAPIPerfil() async {
    // // Dados de exemplo - substitua pela sua API
    // return {
    //   'nome': 'Rodrigo Hugo Padovam',
    //   'cidade': 'Marília',
    //   'estado': 'SP',
    //   'avatarUrl': null, // ou uma URL de imagem
    // };
  }

  bool buscandoDadoDoPerfil = false;

  @override
  void dispose() {
    _animationController?.dispose();
    _onBoardingAnimController?.dispose();
    super.dispose();
  }

  /// Inscreve o usuário no tópico

  Widget _buildHeader(double topPadding) {
    return Container(
      width: double.infinity,
      height: 140 + topPadding,
      padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D6EFD),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Container do perfil
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 230,
              ),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.22),
                      Colors.grey.shade300.withOpacity(0.35),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(1),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: foto != null && foto!.isNotEmpty
                              ? NetworkImage(foto!)
                              : null,
                          child: foto == null
                              ? const Icon(
                                  Icons.person,
                                  color: Color(0xFF0D6EFD),
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    // textos
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, ${primeiroNome(nomeCompleto)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: plusJakartaDisplayMedium.copyWith(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                // cidade.isNotEmpty && estado.isNotEmpty
                                //     ? '$cidade - $estado'
                                //     : 'Localização não informada',
                                limitarTexto('$cidade - $estado', limite: 15),
                                style: plusJakartaDisplayMedium.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 49),

          /// 🔔 NOTIFICAÇÃO
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificacoesPage()));
            },
            child: SvgPicture.asset(
              AppImages.notification,
              height: 40,
            ),
          ),

          const SizedBox(width: 15),

          /// 🍔 MENU
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              children: [
                RiveAnimation.asset(
                  app_assets.menuButtonRiv,
                  stateMachines: const ["State Machine"],
                  animations: const ["open", "close"],
                  onInit: _onMenuIconInit,
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        print("MENU CLICADO");
                        onMenuPress();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _sidebarAnim,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(((1 - _sidebarAnim.value) * -30) * math.pi / 180)
              ..translate((1 - _sidebarAnim.value) * -300),
            child: Opacity(
              opacity: _sidebarAnim.value, // Fade in/out
              child: IgnorePointer(
                ignoring: _sidebarAnim.value < 0.01,
                child: child,
              ),
            ),
          );
        },
        child: const SideMenu(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: !_showOnBoarding ? _sidebarAnim : _onBoardingAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              !_showOnBoarding
                  ? _sidebarAnim.value * 300
                  : _onBoardingAnim.value * 200,
            ),
            child: CustomTabBar(
              onTabChange: (tabIndex) {},
            ),
          );
        },
      ),
    );
  }

  String limitarTexto(String texto, {int limite = 12}) {
    if (texto.trim().isEmpty) return '';

    if (texto.length <= limite) {
      return texto;
    }

    return texto.substring(0, limite - 3) + '...';
  }

  Widget _buildOnboarding() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _onBoardingAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              -(MediaQuery.of(context).size.height +
                      MediaQuery.of(context).padding.bottom) *
                  (1 - _onBoardingAnim.value),
            ),
            child: child!,
          );
        },
        child: OnBoardingView(
          closeModal: () => _presentOnBoarding(false),
        ),
      ),
    );
  }

  Widget _buildContentWithTransformations() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _showOnBoarding ? _onBoardingAnim : _sidebarAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 -
                (_showOnBoarding
                    ? (_onBoardingAnim.value * 0.08)
                    : (_sidebarAnim.value * 0.1)),
            child: Transform.translate(
              offset: Offset(_sidebarAnim.value * 265, 0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY((_sidebarAnim.value * 30) * math.pi / 180),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 160),
                  child: _tabBody,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // CONTEÚDO PRINCIPAL COM SCROLL
          SingleChildScrollView(
            child: Column(
              children: [
                // HEADER FIXO (não scrolla)
                Container(
                  height: 140 + topPadding,
                  child: _buildHeader(topPadding),
                ),

                // CONTEÚDO SCROLLÁVEL
                _buildContentWithTransformations(),
              ],
            ),
          ),

          // MENU LATERAL
          _buildSideMenu(),

          // ONBOARDING
          if (_showOnBoarding) _buildOnboarding(),

          // GRADIENTE INFERIOR
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: !_showOnBoarding ? _sidebarAnim : _onBoardingAnim,
                builder: (context, child) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          RiveAppTheme.background.withOpacity(0),
                          RiveAppTheme.background.withOpacity(1 -
                              ((!_showOnBoarding
                                      ? _sidebarAnim.value
                                      : _onBoardingAnim.value) *
                                  1))
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  String primeiroNome(String nomeCompleto) {
    if (nomeCompleto.trim().isEmpty) return '';
    return nomeCompleto.trim().split(' ').first;
  }
}
