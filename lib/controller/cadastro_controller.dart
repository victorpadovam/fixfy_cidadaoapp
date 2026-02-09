import 'dart:convert';
import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:fixfycidadaoapp/models/estabelecimento/estabelecimento_model.dart';
import 'package:http/http.dart' as http;

Future<List<Estabelecimento>> fetchEstabelecimentos() async {
  final response = await http.get(Uri.parse(urlServer + "/estabelecimentos"));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Estabelecimento.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load estabelecimentos');
  }
}
