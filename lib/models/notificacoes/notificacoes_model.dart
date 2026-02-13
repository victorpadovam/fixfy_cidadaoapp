class NotificacoesModel {
  final String? id;
  final String? titulo;
  final String? body;
  final String data;
  final String hora;
  final bool foiLido;


  NotificacoesModel({
    this.id,
    this.titulo,
    this.body,
    required this.data,
    required this.hora,
    required this.foiLido,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'body': body,
      'data': data,
      'hora': hora,
      'foiLido': foiLido,
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
    );
  }
}
