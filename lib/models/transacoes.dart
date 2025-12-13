class TransacaoCaixaDTO {
  final String data;
  final String tipo;
  final String descricao;
  final double valor;
  final int contasReceberId;

  TransacaoCaixaDTO({
    required this.data,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.contasReceberId,
  });

  factory TransacaoCaixaDTO.fromJson(Map<String, dynamic> json) {
    return TransacaoCaixaDTO(
      data: json['data'],
      tipo: json['tipo'],
      descricao: json['descricao'],
      valor: (json['valor'] as num).toDouble(),
      contasReceberId: json['contasReceberId'],
    );
  }
}
