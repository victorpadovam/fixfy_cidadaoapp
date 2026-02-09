import 'dart:convert';
import 'package:fixfycidadaoapp/models/notificacoes/notificacoes_model.dart';
import 'package:fixfycidadaoapp/view/componets/busca_data_hora_atual.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacoesSharedService {
  static const String _key = 'notificacoes_cache';

  /// 🔹 Buscar todas as notificações
  Future<List<NotificacoesModel>> buscarNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List lista = jsonDecode(jsonString);

    return lista.map((e) => NotificacoesModel.fromJson(e)).toList();
  }

  /// 🔹 Salvar nova notificação (mais recente primeiro)
  Future<bool> salvarNotificacao(NotificacoesModel notificacoesModel) async {
    final prefs = await SharedPreferences.getInstance();

    final String dataAtual = buscaDataAtual();
    final String horaAtual = buscaHoraAtual();

    final notificacao = NotificacoesModel(
      id: notificacoesModel.id,
      titulo: notificacoesModel.titulo,
      body: notificacoesModel.body,
      data: dataAtual,
      hora: horaAtual,
      foiLido: false,
      dataHoraEnvio: notificacoesModel.dataHoraEnvio,
      linkExterno: notificacoesModel.linkExterno,
      linkInterno: notificacoesModel.linkInterno,
    );

    // Recupera lista atual
    final List<NotificacoesModel> listaAtual = await buscarNotificacoes();

    // Insere no topo
    listaAtual.insert(0, notificacao);

    // Salva novamente
    await prefs.setString(
      _key,
      jsonEncode(listaAtual.map((e) => e.toJson()).toList()),
    );

    return true;
  }

  /// 🔹 Marcar notificação como lida
  Future<void> marcarComoLida(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await buscarNotificacoes();

    final atualizada = lista.map((n) {
      if (n.id == id) {
        return NotificacoesModel(
          id: n.id,
          titulo: n.titulo,
          body: n.body,
          data: n.data,
          hora: n.hora,
          foiLido: true,
          dataHoraEnvio: n.dataHoraEnvio,
          linkExterno: n.linkExterno,
          linkInterno: n.linkInterno,
        );
      }
      return n;
    }).toList();

    await prefs.setString(
      _key,
      jsonEncode(atualizada.map((e) => e.toJson()).toList()),
    );
  }

  /// 🔹 Limpar todas as notificações
  Future<void> limparNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
