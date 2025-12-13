class Cobranca {
  final int id;
  final String clienteNome;
  final double valor;
  final DateTime dataVencimento;
  final String status;

  Cobranca({
    required this.id,
    required this.clienteNome,
    required this.valor,
    required this.dataVencimento,
    required this.status,
  });

  factory Cobranca.fromJson(Map<String, dynamic> json) {
    return Cobranca(
      id: json['id'],
      clienteNome: json['clienteNome'],
      valor: (json['valor'] as num).toDouble(),
      dataVencimento: DateTime.parse(json['dataVencimento']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "clienteNome": clienteNome,
      "valor": valor,
      "dataVencimento": dataVencimento.toIso8601String(),
      "status": status,
    };
  }
}
