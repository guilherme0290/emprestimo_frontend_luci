class AgrupamentoParcelaDTO {
  final String responsavel;
  final int contagem;
  final double total;
  final List<int> parcelasIds;
  final List<int> contasReceberIds;

  AgrupamentoParcelaDTO({
    required this.responsavel,
    required this.contagem,
    required this.total,
    required this.parcelasIds,
    required this.contasReceberIds,
  });

  factory AgrupamentoParcelaDTO.fromJson(Map<String, dynamic> json) {
    return AgrupamentoParcelaDTO(
      responsavel: json['responsavel'],
      contagem: json['contagem'],
      total: (json['total'] as num).toDouble(),
      parcelasIds: List<int>.from(json['parcelasIds']),
      contasReceberIds: List<int>.from(json['contasReceberIds']),
    );
  }
}
