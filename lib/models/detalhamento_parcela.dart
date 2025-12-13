class DetalheParcelaDTO {
  final int parcelaId;
  final String clienteNome;
  final String? contratoNumero;
  final DateTime vencimento;
  final double valorParcela;
  final int numeroParcela;
  final String status; // ex.: "PENDENTE", "PAGA"
  final DateTime? dataPagamento; // pode ser null
  final String? vendedorNome; // pode ser null
  final String? caixaDescricao; // pode ser null
  final int contasReceberId;

  const DetalheParcelaDTO({
    required this.parcelaId,
    required this.clienteNome,
    this.contratoNumero,
    required this.vencimento,
    required this.valorParcela,
    required this.numeroParcela,
    required this.status,
    this.dataPagamento,
    this.vendedorNome,
    this.caixaDescricao,
    required this.contasReceberId,
  });

  /// Cria a partir de um JSON (Map).
  factory DetalheParcelaDTO.fromJson(Map<String, dynamic> json) {
    return DetalheParcelaDTO(
      parcelaId: json['parcelaId'] as int,
      clienteNome: json['clienteNome'] as String,
      contratoNumero: json['contratoNumero'] as String?,
      vencimento: DateTime.parse(json['vencimento'] as String),
      valorParcela: (json['valorParcela'] as num).toDouble(),
      numeroParcela: json['numeroParcela'] as int,
      status: json['status'] as String,
      dataPagamento: json['dataPagamento'] != null
          ? DateTime.parse(json['dataPagamento'] as String)
          : null,
      vendedorNome: json['vendedorNome'] as String?,
      caixaDescricao: json['caixaDescricao'] as String?,
      contasReceberId: json['contasReceberId'] as int,
    );
  }
}
