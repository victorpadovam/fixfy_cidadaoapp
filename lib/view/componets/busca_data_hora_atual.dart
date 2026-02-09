import 'package:intl/intl.dart';

buscaDataAtual() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM');
  final String formatted = formatter.format(now);
  var tratamentoDaString = formatted.split('-');
  String dataAtual = tratamentoDaString[0] + '/' + tratamentoDaString[1];

  return dataAtual;
}

buscaHoraAtual() {
  var date = DateTime.now().toString();

  var dateSplit = date.split(' ');
  var hourSplit = dateSplit[1].split(':');
  var horaFormatada = hourSplit[0] + ":" + hourSplit[1];

  String horaAtual = horaFormatada;

  return horaAtual;
}
