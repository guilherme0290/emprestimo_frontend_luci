class RelatorioRecebimentoItem {
  final int cobradorId;
  final String cobradorNome;
  final double valorPago;

  const RelatorioRecebimentoItem({
    required this.cobradorId,
    required this.cobradorNome,
    required this.valorPago,
  });

  factory RelatorioRecebimentoItem.fromJson(Map<String, dynamic> json) {
    return RelatorioRecebimentoItem(
      cobradorId: json['cobradorId'] as int,
      cobradorNome: json['cobradorNome'] as String? ?? '',
      valorPago: (json['valorPago'] as num).toDouble(),
    );
  }
}
