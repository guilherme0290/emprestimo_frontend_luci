// lib/models/empresa_dto.dart
class EmpresaCompleto {
  final int? id;
  final String? nome;
  final String? cnpj;
  final String? telefone;
  final String? email;
  final String? rua;
  final String? bairro;
  final int? cidadeId;
  final String? cep;
  final String? numero;
  final String? complemento;

  EmpresaCompleto({
    this.id,
    this.nome,
    this.cnpj,
    this.telefone,
    this.email,
    this.rua,
    this.bairro,
    this.cidadeId,
    this.cep,
    this.numero,
    this.complemento,
  });

  factory EmpresaCompleto.fromJson(Map<String, dynamic> json) =>
      EmpresaCompleto(
        id: (json['id'] as num?)?.toInt(),
        nome: json['nome'],
        cnpj: json['cnpj'],
        telefone: json['telefone'],
        email: json['email'],
        rua: json['rua'],
        bairro: json['bairro'],
        cidadeId: (json['cidadeId'] as num?)?.toInt(),
        cep: json['cep'],
        numero: json['numero'],
        complemento: json['complemento'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'cnpj': cnpj,
        'telefone': telefone,
        'email': email,
        'rua': rua,
        'bairro': bairro,
        'cidadeId': cidadeId,
        'cep': cep,
        'numero': numero,
        'complemento': complemento,
      };
}
