import 'package:emprestimos_app/models/planos.dart';

class Empresa {
  final int? id;
  final String responsavel;
  final String telefone;
  final String email;
  final String? senha;
  final int planoId;  
  bool planoAtivo = false;
  final Plano? plano; 
  final DateTime? createdAt;

  

  Empresa({
    this.id,
    required this.responsavel,
    required this.telefone,
    required this.email,
    this.senha,
    required this.planoId,    
    this.planoAtivo = false,
    this.createdAt,
    this.plano    
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'],
      responsavel: json['responsavel'],
      telefone: json['telefone'],
      email: json['email'],
      senha: json['senha'],
      planoId: json['planoId'],      
      planoAtivo: json['planoAtivo'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      plano: json['plano'] != null
          ? Plano.fromJson(json['plano'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responsavel': responsavel,
      'telefone': telefone,
      'email': email,
      'senha': senha,
      'planoId': planoId,      
    };
  }
}
