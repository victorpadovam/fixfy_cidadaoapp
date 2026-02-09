import 'dart:async'; // <--- importante
import 'dart:convert';

import 'package:fixfycidadaoapp/view/chat.dart';
import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;

class ReclamacoesListScreen extends StatefulWidget {
  @override
  _ReclamacoesListScreenState createState() => _ReclamacoesListScreenState();
}

Map<int, int> mensagensNaoLidas = {};

class _ReclamacoesListScreenState extends State<ReclamacoesListScreen> {
  String usuarioId = '1';
  List reclamacoes = [];
  bool isLoading = true;
  Timer? _mensagensTimer; // <--- Timer adicionado

  @override
  void initState() {
    super.initState();
    fetchReclamacoes();

    // Inicia verificação periódica de mensagens não lidas
    _mensagensTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      await fetchMensagensNaoLidas();
    });
  }

  @override
  void dispose() {
    _mensagensTimer?.cancel(); // <--- Cancelar o timer ao sair da tela
    super.dispose();
  }

  Future<void> fetchMensagensNaoLidas() async {
    final response = await http.get(
      Uri.parse('$urlServer/mensagens-nao-lidas/$usuarioId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      Map<int, int> temp = {};
      for (var item in data) {
        temp[item['reclamacao_id']] = item['quantidade'];
      }

      if (mounted) {
        setState(() {
          mensagensNaoLidas = temp;
        });
      }
    } else {
      print('Erro ao buscar mensagens não lidas');
    }
  }

  Future<void> fetchReclamacoes() async {
    await Future.delayed(Duration(seconds: 1));
    final fakeData = [
      {'id': 1, 'status_nome': 'Aberta'},
      {'id': 2, 'status_nome': 'Resolvida'},
      {'id': 50, 'status_nome': 'Fechada'},
      {'id': 49, 'status_nome': 'Recusada'},
      {'id': 48, 'status_nome': 'Recusada'},
      {'id': 47, 'status_nome': 'Recusada'},
    ];

    if (mounted) {
      setState(() {
        reclamacoes = fakeData;
        isLoading = false;
      });
    }

    await fetchMensagensNaoLidas();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Minhas Reclamações')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Minhas Reclamações')),
      body: ListView.builder(
        itemCount: reclamacoes.length,
        itemBuilder: (context, index) {
          final reclamacao = reclamacoes[index];
          int rec = reclamacao['id'];
          int quantidadeNaoLida = mensagensNaoLidas[rec] ?? 0;

          return ListTile(
            title: Text('Reclamação #${reclamacao['id']}'),
            subtitle: Text(reclamacao['status_nome']),
            trailing: quantidadeNaoLida > 0
                ? badges.Badge(
                    badgeContent: Text(
                      '$quantidadeNaoLida',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.red,
                      padding: EdgeInsets.all(6),
                    ),
                    position: badges.BadgePosition.topEnd(top: -5, end: -5),
                    child: Icon(Icons.chat_bubble_outline),
                  )
                : Icon(Icons.chat_bubble_outline),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    estabelecimentoId: 1,
                    reclamacaoId: rec.toString(),
                  ),
                ),
              );
              await fetchMensagensNaoLidas();
            },
          );
        },
      ),
    );
  }
}
