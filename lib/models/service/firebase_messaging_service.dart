import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixfycidadaoapp/cache/notificacoes_shared.dart';
import 'package:fixfycidadaoapp/models/custom_notification/notification_service.dart';
import 'package:fixfycidadaoapp/models/notificacoes/notificacoes_model.dart';
import 'package:fixfycidadaoapp/view/componets/busca_data_hora_atual.dart';

class FirebaseMessaginService {
  final ServicoDeNotificacoes servicoDeNotificacoes;
  FirebaseMessaginService(this.servicoDeNotificacoes);

  Future<void> inicializaFirebase(cpf) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );
    await resetDeviceTokenTopic(cpf);
    await getDeviceFirebaseToken();
    await controleDeNotificacoesDoFirebase(cpf);
    print('inicializaFirebase');
  }

  resetDeviceTokenTopic(cpf) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(
      cpf,
    );

    await FirebaseMessaging.instance.deleteToken();
    print('resetDeviceTokenTopic');
  }

  getDeviceFirebaseToken() async {
    await FirebaseMessaging.instance.getToken();
    print('getDeviceFirebaseToken');
  }

  controleDeNotificacoesDoFirebase(cpf) async {
    await FirebaseMessaging.instance.subscribeToTopic(
      "todosUsuarios",
    );

    await FirebaseMessaging.instance.subscribeToTopic(
      cpf,
    );

    // //Recebimento de notificacao
    FirebaseMessaging.onMessage.listen((RemoteMessage mensagem) async {
      print("CHEGOU");
      print(mensagem);

      String titulo = mensagem.notification?.title ?? "Sem título";
      String corpo = mensagem.notification?.body ?? "Sem corpo";

      if (Platform.isAndroid) {
        servicoDeNotificacoes.mostrarNotificacaoLocal(
          CustomNotification(
            id: 1,
            title: titulo,
            body: corpo,
          ),
        );
      }

      String dataAtual = buscaDataAtual();
      String horaAtual = buscaHoraAtual();

      var notificacoes = NotificacoesModel(
        id: mensagem.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: titulo,
        body: corpo,
        data: dataAtual,
        hora: horaAtual,
        foiLido: false,
      );

      print('foreground message (controleDeNotificacoesDoFirebase)');

      final service = NotificacoesSharedService();
      await service.salvarNotificacao(notificacoes);
    });

    // app em Segundo Plano
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("onMessageOpenedApp");

      if (Platform.isAndroid) {
        // final linkExterno = message.data['link_externo'];
        // final linkInterno = message.data["link_interno"];

        // if (linkInterno != null && linkInterno.isNotEmpty) {
        //   Get.toNamed(linkInterno);
        // }
        // print("onMessageOpenedApp");
        // if (message.data['link_externo'] != null) {
        //   launchUrl(
        //     Uri.parse(
        //       message.data['link_externo'],
        //     ),
        //     mode: LaunchMode.externalApplication,
        //   );
        // }
      }
    });
  }
}

recebeNotificaoFirebaseAndroidAppFechado() {
  Future.microtask(() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      // final link_externo = message.data['link_externo'];
      // final link_interno = message.data['link_interno'];

      // if (link_externo != null && link_externo.isNotEmpty) {
      //   launchUrl(
      //     Uri.parse(link_externo),
      //     mode: LaunchMode.externalApplication,
      //   );
      // }

      // if (link_interno != null && link_interno.isNotEmpty) {
      //   Get.toNamed(link_interno);
      // }
    }
  });
}
