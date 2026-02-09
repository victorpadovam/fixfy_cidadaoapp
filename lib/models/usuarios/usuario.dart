class Usuario {
  final String? nome;
  final String? senha;
  final String? foto;
  final String? email;
  final String? cpf;
  final String? telefone;
  final String? cidade;
  final String? estado;
  final String? tokenFcmFirebase;
  final String? estabelecimentoId;
  final String? zona;
  final String? bairro;
  final String? rua;
  final String? numero;
  final String? complemento;
  final String? cep;
  final String? pontoReferencia;
  final String? latitude;
  final String? longitude;

  Usuario({
    this.nome,
    this.senha,
    this.foto,
    this.email,
    this.cpf,
    this.telefone,
    this.cidade,
    this.estado,
    this.tokenFcmFirebase,
    this.estabelecimentoId,
    this.zona,
    this.bairro,
    this.rua,
    this.numero,
    this.complemento,
    this.cep,
    this.pontoReferencia,
    this.latitude,
    this.longitude,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        nome: json['nome'],
        senha: json['senha'],
        foto: json['foto'],
        email: json['email'],
        cpf: json['cpf'],
        telefone: json['telefone'],
        cidade: json['cidade'],
        estado: json['estado'],
        tokenFcmFirebase: json['token_fcm_firebase'],
        estabelecimentoId: json['estabelecimento_id'],
        zona: json['zona'],
        bairro: json['bairro'],
        rua: json['rua'],
        numero: json['numero'],
        complemento: json['complemento'],
        cep: json['cep'],
        pontoReferencia: json['ponto_referencia'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'senha': senha,
        'foto': foto,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'cidade': cidade,
        'estado': estado,
        'token_fcm_firebase': tokenFcmFirebase,
        'estabelecimento_id': estabelecimentoId,
        'zona': zona,
        'bairro': bairro,
        'rua': rua,
        'numero': numero,
        'complemento': complemento,
        'cep': cep,
        'ponto_referencia': pontoReferencia,
        'latitude': latitude,
        'longitude': longitude,
      };
}
