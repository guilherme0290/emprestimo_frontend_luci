class Usuario {
  final int id;
  final String nome;
  final String? cnpj;
  final String? telefone;
  final String email;
  final String? rua;
  final String? bairro;
  final int? cidadeId;
  final String? cep;
  final String? numero;
  final String? complemento;
  final String? status;
  final String? password;
  final int? empresaId;
  final String? createdAt;
  final String? updatedAt;

  Usuario({
    required this.id,
    required this.nome,
    this.cnpj,
    this.telefone,
    required this.email,
    this.rua,
    this.bairro,
    this.cidadeId,
    this.cep,
    this.numero,
    this.complemento,
    this.status,
    this.password,
    this.empresaId,
    this.createdAt,
    this.updatedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json["id"],
      nome: json["nome"],
      cnpj: json["cnpj"],
      telefone: json["telefone"],
      email: json["email"],
      rua: json["rua"],
      bairro: json["bairro"],
      cidadeId: json["cidadeId"],
      cep: json["cep"],
      numero: json["numero"],
      complemento: json["complemento"],
      status: json["status"],
      password: json["password"],
      empresaId: json["empresaId"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "cnpj": cnpj,
      "telefone": telefone,
      "email": email,
      "rua": rua,
      "bairro": bairro,
      "cidadeId": cidadeId,
      "cep": cep,
      "numero": numero,
      "complemento": complemento,
      "status": status,
      "password": password,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
