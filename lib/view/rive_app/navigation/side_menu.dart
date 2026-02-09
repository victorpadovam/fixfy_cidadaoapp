import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixfycidadaoapp/cache/usuario_cpf_shared.dart';
import 'package:fixfycidadaoapp/view/componets/app_images.dart';
import 'package:fixfycidadaoapp/view/rive_app/components/menu_row.dart';
import 'package:fixfycidadaoapp/view/rive_app/models/menu_item.dart';
import 'package:fixfycidadaoapp/view/rive_app/theme.dart';
import 'package:fixfycidadaoapp/view/splash_page/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart';

import 'package:fixfycidadaoapp/view/rive_app/assets.dart' as app_assets;
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  final List<MenuItemModel> _historyMenuIcons = MenuItemModel.menuItems2;
  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
  String _selectedMenu = MenuItemModel.menuItems[0].title;
  bool _isDarkMode = false;
  UsuarioSharedPreferences usuarioSharedPreferences =
      UsuarioSharedPreferences();

  void onThemeRiveIconInit(artboard) {
    final controller = StateMachineController.fromArtboard(
        artboard, _themeMenuIcon[0].riveIcon!.stateMachine);
    artboard.addController(controller!);
    _themeMenuIcon[0].riveIcon!.status =
        controller.findInput<bool>("active") as SMIBool;
  }

  Future<void> onMenuPress(MenuItemModel menu) async {
    setState(() {
      _selectedMenu = menu.title;
    });

    if (menu.title == "Sair") {
      try {
        final buscaUserLogado =
            await usuarioSharedPreferences.getUsuarioLogado();

        if (buscaUserLogado != null && buscaUserLogado.isNotEmpty) {
          final cpf = buscaUserLogado['cpf'];
          if (cpf != null && cpf.isNotEmpty) {
            await FirebaseMessaging.instance.unsubscribeFromTopic(cpf);
          }
        }

        await FirebaseMessaging.instance.unsubscribeFromTopic("todosUsuarios");

        print("🚪 Usuário desinscrito dos tópicos com sucesso!");
      } catch (e) {
        print("❌ Erro ao desinscrever dos tópicos: $e");
      }

      await usuarioSharedPreferences.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('manterLogado', false);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashPage()),
        (route) => false,
      );
    }
  }

  void onThemeToggle(value) {
    setState(() {
      _isDarkMode = value;
    });
    _themeMenuIcon[0].riveIcon!.status!.change(value);
  }

  String nomeCompleto = '';
  String cidade = '';
  String estado = '';
  String? foto;

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
  }

  @override
  void initState() {
    _carregarUsuarioCache();
    super.initState();
  }

  String primeiroNome(String nomeCompleto) {
    if (nomeCompleto.trim().isEmpty) return '';
    return nomeCompleto.trim().split(' ').first;
  }

  String limitarTexto(String texto, {int limite = 12}) {
    if (texto.trim().isEmpty) return '';

    if (texto.length <= limite) {
      return texto;
    }

    return texto.substring(0, limite - 3) + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom - 60),
      constraints: const BoxConstraints(maxWidth: 288),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RiveAppTheme.background2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
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
                SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${primeiroNome(nomeCompleto)}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontFamily: "Inter"),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          limitarTexto('$cidade - $estado', limite: 15),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15,
                              fontFamily: "Inter"),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        SvgPicture.asset(
                          AppImages.seta_para_baixo,
                          width: 15,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          MenuButtonSection(
              title: "BROWSE",
              selectedMenu: _selectedMenu,
              menuIcons: _browseMenuIcons,
              onMenuPress: onMenuPress),
          MenuButtonSection(
              title: "HISTORY",
              selectedMenu: _selectedMenu,
              menuIcons: _historyMenuIcons,
              onMenuPress: onMenuPress),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Opacity(
                  opacity: 0.6,
                  child: RiveAnimation.asset(
                    app_assets.iconsRiv,
                    stateMachines: [_themeMenuIcon[0].riveIcon!.stateMachine],
                    artboard: _themeMenuIcon[0].riveIcon!.artboard,
                    onInit: onThemeRiveIconInit,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _themeMenuIcon[0].title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600),
                ),
              ),
              CupertinoSwitch(value: _isDarkMode, onChanged: onThemeToggle),
            ]),
          )
        ],
      ),
    );
  }
}

class MenuButtonSection extends StatelessWidget {
  const MenuButtonSection(
      {Key? key,
      required this.title,
      required this.menuIcons,
      this.selectedMenu = "Home",
      this.onMenuPress})
      : super(key: key);

  final String title;
  final String selectedMenu;
  final List<MenuItemModel> menuIcons;
  final Function(MenuItemModel menu)? onMenuPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              for (var menu in menuIcons) ...[
                Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                    height: 1,
                    indent: 16,
                    endIndent: 16),
                MenuRow(
                  menu: menu,
                  selectedMenu: selectedMenu,
                  onMenuPress: () => onMenuPress!(menu),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
