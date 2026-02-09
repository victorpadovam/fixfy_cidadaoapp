class Estabelecimento {
  final int id;
  final String cidade;
  final String estado;

  Estabelecimento(
      {required this.id, required this.cidade, required this.estado});

  factory Estabelecimento.fromJson(Map<String, dynamic> json) {
    return Estabelecimento(
      id: json['id'],
      cidade: json['cidade'],
      estado: json['uf'],
    );
  }
}
