class ParcelaSimulada {
  final int numero;
  double valor;
  final DateTime dataVencimento;

  ParcelaSimulada({
    required this.numero,
    required this.valor,
    required this.dataVencimento,
  });

  Map<String, dynamic> toJson() {
    final data = DateTime(dataVencimento.year, dataVencimento.month,
        dataVencimento.day);
    return {
      'numeroParcela': numero,
      'valor': valor,
      'dataVencimento': data.toIso8601String().split('T').first,
    };
  }
}
