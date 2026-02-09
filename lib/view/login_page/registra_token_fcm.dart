import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:http/http.dart' as http;

Future<void> enviarTokenParaServidorLaravel({
  required String? token,
  required String userId,
}) async {
  final url = Uri.parse(urlServer + '/salvar-token');
  final response = await http.post(url, body: {
    'cidadao_id': userId,
    'fcm_token': token,
    'tipo': 'cidadao',
  });

  print(response);

  if (response.statusCode == 200) {
    print('✅ Token salvo com sucesso no backend');
  } else {
    print('❌ Falha ao salvar token');
  }
}
