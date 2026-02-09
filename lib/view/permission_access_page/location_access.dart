import 'package:fixfycidadaoapp/view/permission_access_page/notificacao_permission.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:fixfycidadaoapp/view/componets/styles.dart';

class LocationAccessPage extends StatefulWidget {
  const LocationAccessPage({super.key});

  @override
  State<LocationAccessPage> createState() => _LocationAccessPageState();
}

class _LocationAccessPageState extends State<LocationAccessPage>
    with WidgetsBindingObserver {
  bool isChecking = false;
  bool isDialogOpen = false;
  bool handledPermanentlyDenied = false;
  bool openedAppSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, _checkAndRequestPermission);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && openedAppSettings) {
      openedAppSettings = false;

      handledPermanentlyDenied = false;

      _checkAndRequestPermission();
    }
  }

  Future<void> _checkAndRequestPermission() async {
    if (!mounted || isChecking) return;
    setState(() => isChecking = true);

    final status = await Geolocator.checkPermission();

    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      await _obterEArmazenarLocalizacao();
      return;
    }

    if (status == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.always ||
          result == LocationPermission.whileInUse) {
        // ✅ Agora chamamos o método separado
        await _obterEArmazenarLocalizacao();
        return;
      } else if (result == LocationPermission.deniedForever) {
        if (!handledPermanentlyDenied) {
          handledPermanentlyDenied = true;
          _showOpenSettingsDialog();
        }
      }
    } else if (status == LocationPermission.deniedForever) {
      if (!handledPermanentlyDenied) {
        handledPermanentlyDenied = true;
        _showOpenSettingsDialog();
      }
    }

    if (mounted) setState(() => isChecking = false);
  }

  Future<void> _obterEArmazenarLocalizacao() async {
    try {
      _goToNextPage();
    } catch (e) {
      print('Erro ao obter localização: $e');
    } finally {}
  }

  void _showOpenSettingsDialog() {
    if (isDialogOpen) return;

    isDialogOpen = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Localização'),
        content: const Text(
          'A permissão de localização foi negada permanentemente.\n\n'
          'Para continuar, ative a localização manualmente nas configurações do aplicativo:\n'
          'Abrir Ajustes > Permissões > Localização > Permitir',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isDialogOpen = false;
                isChecking = false;
                handledPermanentlyDenied = false;
              });
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                isDialogOpen = false;
                isChecking = false;
                openedAppSettings = true;
              });
              await Geolocator.openAppSettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  void _goToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationNotificacaoPermission(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Precisamos da sua localização',
                    style: urbanist500.copyWith(fontSize: 25),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Isso permite que a gente verifique se o FixFy está disponível na sua cidade.',
                    style: urbanist300.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Lottie.asset(
              'assets/lottie/location.json',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color.fromARGB(255, 230, 246, 250),
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
    );
  }
}
