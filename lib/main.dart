import 'dart:io';

import 'package:fixfycidadaoapp/cache/notificacoes_shared.dart';
import 'package:fixfycidadaoapp/models/custom_notification/notification_service.dart';
import 'package:fixfycidadaoapp/models/notificacoes/notificacoes_model.dart';
import 'package:fixfycidadaoapp/models/service/firebase_messaging_service.dart';
import 'package:fixfycidadaoapp/view/componets/busca_data_hora_atual.dart';
import 'package:fixfycidadaoapp/view/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider_ios/path_provider_ios.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await inicializaFirebase();
  setupFirebaseMessagingHandler();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFF1E63F1),
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        Provider<ServicoDeNotificacoes>(
          create: (context) => ServicoDeNotificacoes(),
        ),
        Provider<FirebaseMessaginService>(
          create: (context) => FirebaseMessaginService(
            context.read<ServicoDeNotificacoes>(),
          ),
        ),
      ],
      child: App(),
    ),
  );
}

Future<void> inicializaFirebase() async {
  try {
    await Firebase.initializeApp();
    print('Firebase inicializado com sucesso!');
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
}

void setupFirebaseMessagingHandler() {
  FirebaseMessaging.onBackgroundMessage(
    recebeNotificacaoFirebaseAppFechado,
  );
}

Future<void> recebeNotificacaoFirebaseAppFechado(
  RemoteMessage message,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) PathProviderAndroid.registerWith();
  if (Platform.isIOS) PathProviderIOS.registerWith();

  String dataAtual = buscaDataAtual();
  String horaAtual = buscaHoraAtual();

  final notificacao = NotificacoesModel(
    id: message.messageId,
    titulo: message.notification?.title,
    body: message.notification?.body,
    data: dataAtual,
    hora: horaAtual,
    foiLido: false,
  );

  await NotificacoesSharedService().salvarNotificacao(notificacao);

  print('📩 background message salva no SharedPreferences');
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reclamações',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: ReclamacoesListScreen(),
      home: OnboardingPage(),
      // home: SplashPage(),
    );
  }
}
