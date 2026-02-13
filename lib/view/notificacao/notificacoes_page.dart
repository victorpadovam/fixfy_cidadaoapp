import 'package:fixfycidadaoapp/cache/notificacoes_shared.dart';
import 'package:fixfycidadaoapp/models/notificacoes/notificacoes_model.dart';
import 'package:fixfycidadaoapp/view/componets/styles.dart';
import 'package:flutter/material.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final NotificacoesSharedService _service = NotificacoesSharedService();

  late Future<List<NotificacoesModel>> _futureNotificacoes;

  @override
  void initState() {
    super.initState();
    _futureNotificacoes = _service.buscarNotificacoes();
  }

  Future<void> _recarregar() async {
    setState(() {
      _futureNotificacoes = _service.buscarNotificacoes();
    });
  }

  void _abrirModalNotificacao(NotificacoesModel item) async {
    if (!item.foiLido && item.id != null) {
      await _service.marcarComoLida(item.id!);
      _recarregar();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  item.titulo ?? "Sem título",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  item.body ?? "Sem descrição",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Notificações',
          style: plusJakartaDisplayMedium.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0D6EFD),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
            onPressed: () async {
              await _service.limparNotificacoes();
              _recarregar();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<NotificacoesModel>>(
        future: _futureNotificacoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar notificações'),
            );
          }

          final notificacoes = snapshot.data ?? [];

          if (notificacoes.isEmpty) {
            return const Center(
              child: Text('Nenhuma notificação encontrada'),
            );
          }

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notificacoes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = notificacoes[index];

                return _NotificacaoItem(
                  notificacao: item,
                  onTap: () async {
                    if (!item.foiLido && item.id != null) {
                      await _service.marcarComoLida(item.id!);
                      _recarregar();
                    }

                    _abrirModalNotificacao(item);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificacaoItem extends StatelessWidget {
  final NotificacoesModel notificacao;
  final VoidCallback onTap;

  const _NotificacaoItem({
    required this.notificacao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool naoLida = !notificacao.foiLido;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: naoLida ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications,
              color: naoLida ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificacao.titulo.toString(),
                    style: TextStyle(
                      fontWeight: naoLida ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notificacao.body.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${notificacao.data} • ${notificacao.hora}',
                    style: Theme.of(context).textTheme.bodySmall,
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
