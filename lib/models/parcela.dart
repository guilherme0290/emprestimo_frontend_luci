import 'package:emprestimos_app/models/baixa-parcela.dart';

class ParcelaDTO {
  final int id;
  final double valor;
  final double? jurosParcela;
  final String dataVencimento;
  final int numeroParcela;
  final String? dataPagamento;
  final String status;
  final List<BaixaParcelaDTO>? baixas; // ⬅️ Adicionamos aqui
  

  ParcelaDTO({
    required this.id,
    required this.valor,
    this.jurosParcela,
    required this.dataVencimento,
    required this.numeroParcela,
    this.dataPagamento,
    required this.status,
    this.baixas,
  });

  factory ParcelaDTO.fromJson(Map<String, dynamic> json) {
    final baixasJson = json['baixas'] as List<dynamic>?;

    return ParcelaDTO(
      id: json['id'] as int,
      valor: (json['valor'] as num).toDouble(),
      jurosParcela: json['jurosParcela'] != null
          ? (json['jurosParcela'] as num).toDouble()
          : null,
      dataVencimento: json['dataVencimento'] ?? '',
      numeroParcela: json['numeroParcela'] as int,
      dataPagamento: json['dataPagamento'],
      status: json['status'] ?? '',
      baixas: baixasJson != null
          ? baixasJson
              .map((b) => BaixaParcelaDTO.fromJson(b as Map<String, dynamic>))
              .toList()
          : <BaixaParcelaDTO>[],
    );
  }
}
