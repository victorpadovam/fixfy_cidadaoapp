import 'package:fixfycidadaoapp/view/login_page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fixfycidadaoapp/view/componets/styles.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationNotificacaoPermission extends StatefulWidget {
  const LocationNotificacaoPermission({super.key});

  @override
  State<LocationNotificacaoPermission> createState() =>
      _LocationNotificacaoPermissionState();
}

class _LocationNotificacaoPermissionState
    extends State<LocationNotificacaoPermission> with WidgetsBindingObserver {
  bool isChecking = false;
  bool isDialogOpen = false;
  bool hasNavigated = false;
  bool fromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Espera o primeiro frame renderizar para evitar múltiplos rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && fromSettings) {
      fromSettings = false;
      isDialogOpen = false; // ✅ reset para permitir reabrir o diálogo
      isChecking = false; // ✅ garante nova verificação
      _checkAndRequestPermission();
    }
  }

  Future<void> _checkAndRequestPermission() async {
    if (isChecking || hasNavigated) return;

    setState(() => isChecking = true);

    final status = await Permission.notification.status;

    if (status.isGranted) {
      _goToNextPage();
    } else if (status.isDenied) {
      final result = await Permission.notification.request();

      if (result.isGranted) {
        _goToNextPage();
      } else if (result.isPermanentlyDenied) {
        _showOpenSettingsDialog();
      } else if (result.isDenied) {
        _showOpenSettingsDialog();
      } else {
        setState(() => isChecking = false);
      }
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog();
    } else {
      setState(() => isChecking = false);
    }
  }

  void _showOpenSettingsDialog() {
    if (isDialogOpen) return;

    // Garante que não está no estado de loading
    setState(() {
      isDialogOpen = true;
      isChecking = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // evita fechar ao clicar fora
      builder: (context) => AlertDialog(
        title: const Text('Notificações'),
        content: const Text(
          'As notificações estão desativadas.\n\n'
          'Para receber atualizações importantes, ative-as manualmente:\n'
          'Abrir Ajustes > Notificações > Permitir',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isDialogOpen = false;
              });
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isDialogOpen = false;
                fromSettings = true;
              });
              openAppSettings();
            },
            child: const Text('Abrir Ajustes'),
          ),
        ],
      ),
    );
  }

  void _goToNextPage() {
    if (hasNavigated) return;
    hasNavigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isChecking
            ? Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 300,
                  height: 200,
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Precisamos da sua permissão para enviar notificações',
                          style: urbanist500.copyWith(fontSize: 25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Isso permite que a gente envie notificações sobre o andamento das solicitações feitas no app.',
                          style: urbanist300.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Lottie.asset(
                    'assets/lottie/notification_acesso.json',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: const Color.fromARGB(255, 230, 246, 250),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E63F1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _checkAndRequestPermission,
                            child: const Text(
                              'Permitir acesso',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
