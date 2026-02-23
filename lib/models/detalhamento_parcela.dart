class DetalheParcelaDTO {
  final int parcelaId;
  final String clienteNome;
  final String? contratoNumero;
  final DateTime vencimento;
  final double valorParcela;
  final int numeroParcela;
  final String status;
  final DateTime? dataPagamento;
  final String? vendedorNome;
  final String? caixaDescricao;
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

  factory DetalheParcelaDTO.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return DetalheParcelaDTO(
      parcelaId: parseInt(json['parcelaId']),
      clienteNome: (json['clienteNome'] ?? '').toString(),
      contratoNumero: json['contratoNumero']?.toString(),
      vencimento: parseDate(json['vencimento']),
      valorParcela: parseDouble(json['valorParcela']),
      numeroParcela: parseInt(json['numeroParcela']),
      status: (json['status'] ?? '').toString(),
      dataPagamento: parseNullableDate(json['dataPagamento']),
      vendedorNome: json['vendedorNome']?.toString(),
      caixaDescricao: json['caixaDescricao']?.toString(),
      contasReceberId: parseInt(json['contasReceberId']),
    );
  }
}
