class RelatorioRecebimentoItem {
  final int baixaId;
  final int contasReceberId;
  final int parcelaId;
  final String clienteNome;
  final int numeroParcela;
  final double valorPago;
  final DateTime? dataPagamento;
  final String criadoPor;
  final String recebidoPor;
  final String caixaDescricao;

  const RelatorioRecebimentoItem({
    required this.baixaId,
    required this.contasReceberId,
    required this.parcelaId,
    required this.clienteNome,
    required this.numeroParcela,
    required this.valorPago,
    this.dataPagamento,
    required this.criadoPor,
    required this.recebidoPor,
    required this.caixaDescricao,
  });

  factory RelatorioRecebimentoItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return RelatorioRecebimentoItem(
      baixaId: parseInt(json['baixaId']),
      contasReceberId: parseInt(json['contasReceberId']),
      parcelaId: parseInt(json['parcelaId']),
      clienteNome: (json['clienteNome'] ?? '').toString(),
      numeroParcela: parseInt(json['numeroParcela']),
      valorPago: parseDouble(json['valorPago']),
      dataPagamento: parseNullableDate(json['dataPagamento']),
      criadoPor: (json['criadoPor'] ?? '').toString(),
      recebidoPor: (json['recebidoPor'] ?? '').toString(),
      caixaDescricao: (json['caixaDescricao'] ?? '').toString(),
    );
  }
}
