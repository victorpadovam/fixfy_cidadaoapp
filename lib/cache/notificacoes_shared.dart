import 'dart:convert';
import 'package:fixfycidadaoapp/models/notificacoes/notificacoes_model.dart';
import 'package:fixfycidadaoapp/view/componets/busca_data_hora_atual.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacoesSharedService {
  static final NotificacoesSharedService _instance =
      NotificacoesSharedService._internal();
  factory NotificacoesSharedService() => _instance;
  NotificacoesSharedService._internal() {
    _atualizarBadge();
  }

  static const String _key = 'notificacoes_cache';

  // ✅ Notificador de quantidade de notificações não lidas
  ValueNotifier<int> notificacoesNaoLidas = ValueNotifier<int>(0);

  Future<void> _atualizarBadge() async {
    final todas = await buscarNotificacoes();
    notificacoesNaoLidas.value = todas.where((n) => !n.foiLido).length;
  }

  Future<List<NotificacoesModel>> buscarNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List lista = jsonDecode(jsonString);
    final result = lista.map((e) => NotificacoesModel.fromJson(e)).toList();

    // Atualiza badge
    notificacoesNaoLidas.value = result.where((n) => !n.foiLido).length;
    return result;
  }

  Future<bool> salvarNotificacao(NotificacoesModel notificacao) async {
    final prefs = await SharedPreferences.getInstance();
    final listaAtual = await buscarNotificacoes();
    listaAtual.insert(0, notificacao);
    await prefs.setString(
      _key,
      jsonEncode(listaAtual.map((e) => e.toJson()).toList()),
    );

    // ✅ Atualiza badge usando a mesma instância
    notificacoesNaoLidas.value = listaAtual.where((n) => !n.foiLido).length;
    return true;
  }

  Future<void> marcarComoLida(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Busca notificações e garante o tipo certo
    final List<NotificacoesModel> lista = await buscarNotificacoes();

    // Marca a notificação como lida
    final List<NotificacoesModel> atualizada = lista.map((n) {
      if (n.id == id) {
        return NotificacoesModel(
          id: n.id,
          titulo: n.titulo,
          body: n.body,
          data: n.data,
          hora: n.hora,
          foiLido: true, // aqui marcamos como lida
        );
      }
      return n;
    }).toList();

    // Salva de volta
    await prefs.setString(
      _key,
      jsonEncode(atualizada.map((e) => e.toJson()).toList()),
    );

    // Atualiza badge
    notificacoesNaoLidas.value = atualizada.where((n) => !n.foiLido).length;
  }

  Future<void> limparNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notificacoesNaoLidas.value = 0;
  }
}
