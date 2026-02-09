import 'dart:convert';

import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String reclamacaoId;
  final int estabelecimentoId;

  const ChatScreen({
    super.key,
    required this.reclamacaoId,
    required this.estabelecimentoId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var userPhoto =
      "https://militaryhealthinstitute.org/wp-content/uploads/sites/37/2021/08/blank-profile-picture-png.png";
  var userNome = 'User'; //DADOS FAKE
  int usuarioId = 113; ////DADOS FAKE

  final database = FirebaseDatabase.instance.ref();
  late DatabaseReference digitandoRef;
  final TextEditingController _controller = TextEditingController();
  late DatabaseReference _mensagensRef;
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> marcarMensagensComoLidas() async {
    final snapshot = await _mensagensRef.once();

    if (snapshot.snapshot.value != null) {
      final mensagens =
          Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);

      mensagens.forEach((key, value) {
        if (value is Map && value['tipo'] != 'cidadao') {
          final List<dynamic> lidoPor = List.from(value['lidoPor'] ?? []);

          if (!lidoPor.contains('cidadao')) {
            _mensagensRef.child(key).update({
              'lidoPor': [...lidoPor, 'cidadao'],
            });
          }
        }
      });
    }
  }

  final ScrollController scrollToBottomList = ScrollController();

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  late FlutterLocalNotificationsPlugin localNotifications;

  @override
  void initState() {
    super.initState();
    _mensagensRef =
        database.child('reclamacoes/${widget.reclamacaoId}/mensagens');
    digitandoRef =
        database.child('reclamacoes/${widget.reclamacaoId}/digitando');

    marcarMensagensComoLidas();
    initializeNotifications();
    marcarComoLida();
  }

  Future<void> marcarComoLida() async {
    final response = await http.post(
      Uri.parse('$urlServer/mensagens-nao-lidas/marcar-como-lida'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cidadao_id': usuarioId,
        'reclamacao_id': widget.reclamacaoId,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Mensagem marcada como lida');
    } else {
      print('❌ Erro ao marcar como lida');
    }
  }

  void initializeNotifications() async {
    // Configurações para Android e iOS (Darwin para iOS/macOS)
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    // Inicializa o plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Aqui você trata o toque na notificação
        if (response.payload != null) {
          print('Notificação clicada com payload: ${response.payload}');
          // Pode navegar ou executar ação conforme payload
        }
      },
    );
  }

  // Exemplo de como criar os detalhes da notificação
  NotificationDetails getNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'Descrição do canal',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Exemplo de método para mostrar a notificação
  void showNotification(String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      0, // id da notificação
      title,
      body,
      getNotificationDetails(),
      payload: 'Dados adicionais aqui',
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    _mensagensRef.push().set({
      'foto': userPhoto,
      'hora': getHoraAtual(),
      'mensagem': _controller.text.trim(),
      'nome': userNome,
      'tipo': "cidadao",
      'timestamp': DateTime.now().millisecondsSinceEpoch // ✅ aqui!
    });

    digitandoRef.remove();
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final contadorRef = FirebaseDatabase.instance.ref(
        'nao_lidas/estabelecimento_${widget.estabelecimentoId}/${widget.reclamacaoId}');

    await contadorRef.runTransaction((currentData) {
      final current = (currentData as int?) ?? 0;
      return Transaction.success(current + 1);
    });
  }

  Widget _buildMessage(
      {required Map<dynamic, dynamic> msg, required bool isSender}) {
    final messageText = msg['mensagem'] ?? '';
    final isAudio = messageText.startsWith('audio:');

    if (isAudio) {
      return _buildAudioMessage(isSender: isSender);
    }

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xFFE0F7F1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isSender ? 18 : 0),
            bottomRight: Radius.circular(isSender ? 0 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSender)
              Text(
                msg['nome'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            Text(
              messageText,
              style: TextStyle(
                color: isSender ? const Color(0xFF00796B) : Colors.black87,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              getHoraFormatada(msg['hora']),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage({bool isSender = false}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xFFE0F7F1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isSender ? 18 : 0),
            bottomRight: Radius.circular(isSender ? 0 : 18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow,
                color: isSender ? Colors.teal : Colors.black54),
            const SizedBox(width: 10),
            Container(
              width: 100,
              height: 20,
              child: CustomPaint(painter: WaveformPainter(isSender: isSender)),
            ),
            const SizedBox(width: 8),
            Text("0:15", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLabel(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            date,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                onChanged: (text) {
                  if (text.trim().isNotEmpty) {
                    digitandoRef.set({
                      'nome': userNome,
                      'tipo': 'cidadao',
                    });
                  } else {
                    digitandoRef.remove();
                  }
                },
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Digite uma mensagem...",
                  border: InputBorder.none,
                ),
                onSubmitted: (text) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _getMessageDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(userPhoto),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userNome,
                    style: TextStyle(color: Colors.black, fontSize: 12)),
                StreamBuilder(
                  stream: digitandoRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        (snapshot.data! as DatabaseEvent).snapshot.value !=
                            null) {
                      final data = (snapshot.data! as DatabaseEvent)
                          .snapshot
                          .value as Map;
                      if (data['tipo'] != 'cidadao') {
                        return Text("Digitando...",
                            style:
                                TextStyle(color: Colors.green, fontSize: 12));
                      }
                    }
                    return Text("Online",
                        style: TextStyle(color: Colors.green, fontSize: 12));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
            stream: _mensagensRef.onValue, // sem orderByChild
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              }

              final messagesMap = (snapshot.data! as DatabaseEvent)
                  .snapshot
                  .value as Map<dynamic, dynamic>?;

              if (messagesMap == null || messagesMap.isEmpty) {
                return Center(child: Text('Nenhuma mensagem ainda'));
              }

              final messages = messagesMap.entries.toList();

              // Ordenar mensagens localmente por timestamp
              messages.sort((a, b) {
                int getTimestamp(dynamic value) {
                  if (value['timestamp'] != null) {
                    return value['timestamp'] is int
                        ? value['timestamp'] as int
                        : (value['timestamp'] as num).toInt();
                  } else if (value['hora'] != null) {
                    return horaParaSegundos(value['hora']);
                  } else {
                    return 0;
                  }
                }

                return getTimestamp(a.value).compareTo(getTimestamp(b.value));
              });

              // Construir lista achatada com separadores de data + mensagens
              List<Widget> messageWidgets = [];
              String? lastDate;

              for (var msgEntry in messages) {
                final msg = msgEntry.value;
                final timestamp = msg['timestamp'] ?? 0;
                final date = _getMessageDate(timestamp);
                final isSender = msg['tipo'] == 'cidadao';

                if (date != lastDate) {
                  messageWidgets.add(_buildDateLabel(date));
                  lastDate = date;
                }

                messageWidgets.add(_buildMessage(msg: msg, isSender: isSender));
              }

              // ✅ Scroll para o fim após atualizar a lista
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollToBottom();
              });

              return ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8),
                children: messageWidgets,
              );
            },
          )),
          _buildInputField(),
        ],
      ),
    );
  }

  int horaParaSegundos(String hora) {
    final partes = hora.split(':');
    if (partes.length != 3) return 0;
    final h = int.tryParse(partes[0]) ?? 0;
    final m = int.tryParse(partes[1]) ?? 0;
    final s = int.tryParse(partes[2]) ?? 0;
    return h * 3600 + m * 60 + s;
  }

  // Helpers:
  String getHoraAtual() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  String getHoraFormatada(String? hora) {
    return hora ?? '';
  }
}

class WaveformPainter extends CustomPainter {
  final bool isSender;
  WaveformPainter({required this.isSender});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSender ? Colors.teal : Colors.black54
      ..strokeWidth = 2;

    final barCount = 20;
    final spacing = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final barHeight = (i % 2 == 0 ? size.height : size.height / 2);
      final dx = i * spacing;
      canvas.drawLine(
          Offset(dx, size.height), Offset(dx, size.height - barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
