class ResumoFinanceiro {
  final int totalContasReceber;
  final double valorTotalEmprestado;
  final double jurosAcumulados;
  final List<CobrancaPendente> cobrancasPendentes;
  final Map<String, double>
      lucratividadeMensal; // Exemplo: {"01": 1500.0, "02": 1800.0}

  ResumoFinanceiro({
    required this.totalContasReceber,
    required this.valorTotalEmprestado,
    required this.jurosAcumulados,
    required this.cobrancasPendentes,
    required this.lucratividadeMensal,
  });

  factory ResumoFinanceiro.fromJson(Map<String, dynamic> json) {
    return ResumoFinanceiro(
      totalContasReceber: json["totalContasReceber"],
      valorTotalEmprestado: json["valorTotalEmprestado"].toDouble(),
      jurosAcumulados: json["jurosAcumulados"].toDouble(),
      cobrancasPendentes: (json["cobrancasPendentes"] as List)
          .map((e) => CobrancaPendente.fromJson(e))
          .toList(),
      lucratividadeMensal:
          Map<String, double>.from(json["lucratividadeMensal"]),
    );
  }
}

class CobrancaPendente {
  final String clienteNome;
  final String dataVencimento;
  final double valor;

  CobrancaPendente({
    required this.clienteNome,
    required this.dataVencimento,
    required this.valor,
  });

  factory CobrancaPendente.fromJson(Map<String, dynamic> json) {
    return CobrancaPendente(
      clienteNome: json["clienteNome"],
      dataVencimento: json["dataVencimento"],
      valor: json["valor"].toDouble(),
    );
  }
}
