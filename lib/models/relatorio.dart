class Relatorio {
  final int totalContasReceber;
  final int totalAtrasados;
  final double jurosRecebidos;
  final Map<String, double>
      projecaoMensal; // Exemplo: {"01": 1500.0, "02": 1800.0}

  Relatorio({
    required this.totalContasReceber,
    required this.totalAtrasados,
    required this.jurosRecebidos,
    required this.projecaoMensal,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    return Relatorio(
      totalContasReceber: json["totalContasReceber"],
      totalAtrasados: json["totalAtrasados"],
      jurosRecebidos: json["jurosRecebidos"].toDouble(),
      projecaoMensal: Map<String, double>.from(json["projecaoMensal"]),
    );
  }
}
