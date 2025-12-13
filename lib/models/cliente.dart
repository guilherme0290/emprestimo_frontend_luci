class Cliente {
  final int? id;
  final String? nome;
  final String? cpf;
  // final DateFormat? dataNascimento;
  final String? telefone;
  final String? email;
  final String? rua;
  final String? bairro;
  final int? cidadeId;
  final String? cidadeNome;
  final String? estado;
  final String? cep;
  final String? complemento;
  final String? numero;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? empresaId;
  final int? vendedorId;
  final int? score;
  final String? scoreDescricao;
  final String? statusContasReceber;

  Cliente(
      {this.id,
      this.nome,
      this.cpf,
      // this.dataNascimento,
      this.telefone,
      this.email,
      this.rua,
      this.bairro,
      this.cidadeId,
      this.cep,
      this.complemento,
      this.numero,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.empresaId,
      this.vendedorId,
      this.score,
      this.scoreDescricao,
      this.statusContasReceber,
      this.cidadeNome,
      this.estado});

  /// Construtor para criar a instância a partir de um JSON (Map)
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
        id: json['id'] as int?,
        nome: json['nome'] as String?,
        cpf: json['cpf'] as String?,
        // dataNascimento: json['dataNascimento'] as DateFormat,
        telefone: json['telefone'] as String?,
        email: json['email'] as String?,
        rua: json['rua'] as String?,
        bairro: json['bairro'] as String?,
        cidadeId: json['cidadeId'] as int?,
        cep: json['cep'] as String?,
        complemento: json['complemento'] as String?,
        numero: json['numero'] as String?,
        status: json['status'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
        empresaId: json['empresaId'] as int?,
        vendedorId: json['vendedorId'] as int?,
        score: json['score'] as int?,
        scoreDescricao: json['scoreDescricao'] as String?,
        statusContasReceber: json['statusContasReceber'] as String?,
        cidadeNome: json['cidadeNome'] as String?,
        estado: json['estado'] as String?);
  }

  /// Converte a instância em um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      // 'dataNascimento': dataNascimento,
      'telefone': telefone,
      'email': email,
      'rua': rua,
      'bairro': bairro,
      'cidadeId': cidadeId,
      'cep': cep,
      'complemento': complemento,
      'numero': numero,
      'status': status,
      'empresaId': empresaId,
      'vendedorId': vendedorId,
    };
  }
}
