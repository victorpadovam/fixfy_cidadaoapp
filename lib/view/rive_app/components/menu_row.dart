import 'package:fixfycidadaoapp/view/rive_app/models/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rive/rive.dart';
import 'package:fixfycidadaoapp/view/rive_app/assets.dart' as app_assets;

import 'package:fixfycidadaoapp/view/rive_app/models/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rive/rive.dart';
import 'package:fixfycidadaoapp/view/rive_app/assets.dart' as app_assets;

class MenuRow extends StatelessWidget {
  const MenuRow({
    Key? key,
    required this.menu,
    this.selectedMenu = "Home",
    this.onMenuPress,
  }) : super(key: key);

  final MenuItemModel menu;
  final String selectedMenu;
  final Function? onMenuPress;

  void _onMenuIconInit(Artboard artboard) {
    if (menu.riveIcon == null) return;

    final controller = StateMachineController.fromArtboard(
      artboard,
      menu.riveIcon!.stateMachine,
    );

    if (controller != null) {
      artboard.addController(controller);
      menu.riveIcon!.status = controller.findInput<bool>("active") as SMIBool;
    }
  }

  void onMenuPressed() {
    onMenuPress?.call();

    // 🔹 Só anima se for Rive
    if (menu.riveIcon?.status != null) {
      menu.riveIcon!.status!.change(true);
      Future.delayed(const Duration(milliseconds: 600), () {
        menu.riveIcon!.status!.change(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedMenu == menu.title;
    final bool isLogout = menu.title == "Sair";

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSelected ? 288 - 16 : 0,
          height: 56,
          curve: const Cubic(0.2, 0.8, 0.2, 1),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.2) : Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        CupertinoButton(
          padding: const EdgeInsets.all(12),
          pressedOpacity: 1,
          onPressed: onMenuPressed,
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Opacity(
                  opacity: 0.8,
                  child: menu.riveIcon != null
                      // 🔹 RIVE
                      ? RiveAnimation.asset(
                          app_assets.iconsRiv,
                          artboard: menu.riveIcon!.artboard,
                          stateMachines: [menu.riveIcon!.stateMachine],
                          onInit: _onMenuIconInit,
                        )
                      // 🔹 ICON NORMAL
                      : Icon(
                          menu.icon,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                menu.title,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
