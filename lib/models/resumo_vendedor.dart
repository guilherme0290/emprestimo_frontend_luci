class ResumoTotalizadoresContasReceber {
  final double capitalInvestido;
  final double totalReceber;
  final double totalRecebidos;
  final double inadimplentes;
  final double adimplentes;

  ResumoTotalizadoresContasReceber({
    required this.capitalInvestido,
    required this.totalReceber,
    required this.totalRecebidos,
    required this.inadimplentes,
    required this.adimplentes,
  });

  factory ResumoTotalizadoresContasReceber.fromJson(Map<String, dynamic> json) {
    return ResumoTotalizadoresContasReceber(
      capitalInvestido: (json['capitalInvestido'] ?? 0).toDouble(),
      totalReceber: (json['totalReceber'] ?? 0).toDouble(),
      totalRecebidos: (json['totalRecebidos'] ?? 0).toDouble(),
      inadimplentes: (json['inadimplentes'] ?? 0).toDouble(),
      adimplentes: (json['adimplentes'] ?? 0).toDouble(),
    );
  }
}
