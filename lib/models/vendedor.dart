import 'package:emprestimos_app/models/resumo_vendedor.dart';

class Vendedor {
  final int? id;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final String? rua;
  final String? bairro;
  final String? cep;
  final String? numero;
  final String? complemento;
  final int? cidadeId;
  final String? status;
  final String? password;
  final ResumoTotalizadoresContasReceber? resumoVendedorDTO;

  Vendedor(
      {this.id,
      required this.nome,
      required this.cpf,
      required this.telefone,
      required this.email,
      this.rua,
      this.bairro,
      this.cep,
      this.numero,
      this.complemento,
      this.cidadeId,
      this.status,
      this.password,
      this.resumoVendedorDTO});

  factory Vendedor.fromJson(Map<String, dynamic> json) {
    return Vendedor(
      id: json['id'],
      nome: json['nome'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      email: json['email'],
      rua: json['rua'],
      bairro: json['bairro'],
      cep: json['cep'],
      numero: json['numero'],
      complemento: json['complemento'],
      cidadeId: json['cidadeId'],
      status: json['status'],
      resumoVendedorDTO: json['resumoVendedorDTO'] != null
          ? ResumoTotalizadoresContasReceber.fromJson(json['resumoVendedorDTO'])
          : ResumoTotalizadoresContasReceber(
              capitalInvestido: 0,
              totalReceber: 0,
              totalRecebidos: 0,
              inadimplentes: 0,
              adimplentes: 0,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "cpf": cpf,
      "telefone": telefone,
      "email": email,
      "rua": rua,
      "bairro": bairro,
      "cep": cep,
      "numero": numero,
      "complemento": complemento,
      "cidadeId": cidadeId,
      "status": status,
      'password': password,
    };
  }
}
