class ResumoContasReceberCliente {
  final int totalContasReceber;
  final double valorTotalEmprestado;
  final double saldoDevedor;
  final int parcelasAtrasadas;

  ResumoContasReceberCliente({
    required this.totalContasReceber,
    required this.valorTotalEmprestado,
    required this.saldoDevedor,
    required this.parcelasAtrasadas,
  });

  factory ResumoContasReceberCliente.fromJson(Map<String, dynamic> json) {
    return ResumoContasReceberCliente(
      totalContasReceber: json['totalContasReceber'],
      valorTotalEmprestado: json['valorTotalEmprestado'].toDouble(),
      saldoDevedor: json['saldoDevedor'].toDouble(),
      parcelasAtrasadas: json['parcelasAtrasadas'],
    );
  }
}
