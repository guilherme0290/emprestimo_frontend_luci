class ParcelaResumoDTO {
  final int id;
  final int contasreceberId;
  final String clienteNome;
  final String telefone;
  final double valorParcela;
  final String dataVencimento;
  final String statusParcela;

  ParcelaResumoDTO({
    required this.id,
    required this.contasreceberId,
    required this.clienteNome,
    required this.telefone,
    required this.valorParcela,
    required this.dataVencimento,
    required this.statusParcela,
  });

  factory ParcelaResumoDTO.fromJson(Map<String, dynamic> json) {
    return ParcelaResumoDTO(
      id: json['id'],
      contasreceberId: json['contasReceberId'],
      clienteNome: json['clienteNome'],
      telefone: json['telefone'],
      valorParcela: (json['valorParcela'] as num).toDouble(),
      dataVencimento: json['dataVencimento'],
      statusParcela: json['statusParcela'],
    );
  }
}
