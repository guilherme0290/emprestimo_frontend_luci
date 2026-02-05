class BaixaParcelaDTO {
  int? id;
  double valor;
  String? tipoBaixa; // "JUROS", "PARCIAL", "TOTAL", "QUITADA"
  String? dataPagamento; // "2025-03-03T23:57:47.921016"
  int? vendedorId;
  String? vendedorNome;
  int parcelaId;
  String? createdAt;
  bool? aplicarJurosAtraso;

  BaixaParcelaDTO({
    this.id,
    required this.valor,
    this.tipoBaixa,
    this.dataPagamento,
    this.vendedorId,
    this.vendedorNome,
    required this.parcelaId,
    this.createdAt,
    this.aplicarJurosAtraso,
  });

  factory BaixaParcelaDTO.fromJson(Map<String, dynamic> json) {
    return BaixaParcelaDTO(
      id: json['id'] as int,
      valor: (json['valor'] as num).toDouble(),
      tipoBaixa: json['tipoBaixa'] as String,
      dataPagamento: json['dataPagamento'] ?? '',
      vendedorId: json['vendedorId'] as int?,
      vendedorNome: json['vendedorNome'],
      parcelaId: json['parcelaId'] as int,
      createdAt: json['createdAt'],
      aplicarJurosAtraso: json['aplicarJurosAtraso'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "valor": valor,
      "tipoBaixa": tipoBaixa,
      "dataPagamento": dataPagamento,
      "vendedorId": vendedorId,
      "parcelaId": parcelaId,
      "createdAt": createdAt,
      "aplicarJurosAtraso": aplicarJurosAtraso,
    };
  }
}
