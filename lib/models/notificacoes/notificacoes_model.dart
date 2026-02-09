class NotificacoesModel {
  final String? id;
  final String? titulo;
  final String? body;
  final String data;
  final String hora;
  final bool foiLido;
  final DateTime dataHoraEnvio;
  final String? linkExterno;
  final String? linkInterno;

  NotificacoesModel({
    this.id,
    this.titulo,
    this.body,
    required this.data,
    required this.hora,
    required this.foiLido,
    required this.dataHoraEnvio,
    this.linkExterno,
    this.linkInterno,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'body': body,
      'data': data,
      'hora': hora,
      'foiLido': foiLido,
      'dataHoraEnvio': dataHoraEnvio.toIso8601String(),
      'linkExterno': linkExterno,
      'linkInterno': linkInterno,
    };
  }

  factory NotificacoesModel.fromJson(Map<String, dynamic> json) {
    return NotificacoesModel(
      id: json['id'],
      titulo: json['titulo'],
      body: json['body'],
      data: json['data'],
      hora: json['hora'],
      foiLido: json['foiLido'] ?? false,
      dataHoraEnvio: DateTime.parse(json['dataHoraEnvio']),
      linkExterno: json['linkExterno'],
      linkInterno: json['linkInterno'],
    );
  }
}
