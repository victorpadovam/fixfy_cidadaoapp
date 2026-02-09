import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;
  final String? linkExterno;
  final String? linkInterno;

  CustomNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
    this.linkExterno,
    this.linkInterno,
  });

  String toPayload() {
    return jsonEncode({
      "link_externo": linkExterno,
      "link_interno": linkInterno,
    });
  }
}

class ServicoDeNotificacoes {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidNotificationDetails;
  late DarwinInitializationSettings iosNotificationDetails;

  ServicoDeNotificacoes() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _ativarNotificacoes();
  }

  _ativarNotificacoes() async {
    await _inicializaNotificacoes();
  }

  enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  _inicializaNotificacoes() async {
    //@mimap/launcher_icon acessa android/app/src/main/res/
    //ele vai pegar o icon na pasta minpmap
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: initializationSettingsIOS,
      ),
      onDidReceiveNotificationResponse: _notificacaoSelecionada,
    );
  }

  //app Aberto
  void _notificacaoSelecionada(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    final data = jsonDecode(response.payload!);
  }

  mostrarNotificacaoLocal(CustomNotification notification) async {
    androidNotificationDetails = const AndroidNotificationDetails(
      'unisuam_notificacoes',
      'Lembretes',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    localNotificationsPlugin.show(
      notification.id!,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      ),
      payload: notification.toPayload(),
    );
  }
}
