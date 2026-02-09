import 'package:firebase_database/firebase_database.dart';
import 'package:fixfycidadaoapp/models/mensagem/mensagem_nao_lidas.dart';

Future<List<UnreadMessageCount>> buscarNaoLidasDoAdmin(
    int estabelecimentoId) async {
  final ref = FirebaseDatabase.instance
      .ref('nao_lidas/estabelecimento_$estabelecimentoId');

  final snapshot = await ref.get();

  if (snapshot.exists) {
    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.entries
        .map((e) => UnreadMessageCount.fromMap(e.key.toString(), e.value))
        .toList();
  }

  return [];
}
