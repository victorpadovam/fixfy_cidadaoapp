import 'package:fixfycidadaoapp/view/rive_app/models/tab_item.dart';
import 'package:flutter/material.dart';

class MenuItemModel {
  MenuItemModel({
    this.id,
    this.title = "",
    this.riveIcon,
    this.icon,
  });

  UniqueKey? id = UniqueKey();
  String title;

  /// 🔹 Um item pode ter OU Rive OU Icon normal
  TabItem? riveIcon;
  IconData? icon;

  static List<MenuItemModel> menuItems = [
    MenuItemModel(
      title: "Home",
      riveIcon: TabItem(stateMachine: "HOME_interactivity", artboard: "HOME"),
    ),
    MenuItemModel(
      title: "Search",
      riveIcon:
          TabItem(stateMachine: "SEARCH_Interactivity", artboard: "SEARCH"),
    ),
    MenuItemModel(
      title: "Favorites",
      riveIcon:
          TabItem(stateMachine: "STAR_Interactivity", artboard: "LIKE/STAR"),
    ),
    MenuItemModel(
      title: "Help",
      riveIcon: TabItem(stateMachine: "CHAT_Interactivity", artboard: "CHAT"),
    ),
    MenuItemModel(
      title: "Sair",
      icon: Icons.logout,
    ),
  ];

  static List<MenuItemModel> menuItems2 = [
    MenuItemModel(
      title: "History",
      riveIcon: TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
    ),
    MenuItemModel(
      title: "Notification",
      riveIcon: TabItem(stateMachine: "BELL_Interactivity", artboard: "BELL"),
    ),
  ];

  static List<MenuItemModel> menuItems3 = [
    MenuItemModel(
      title: "Dark Mode",
      riveIcon:
          TabItem(stateMachine: "SETTINGS_Interactivity", artboard: "SETTINGS"),
    ),
  ];
}
