class Caixa {
  final int? id;
  final String descricao;
  final double valorInicial;
  final bool defaultCaixa;
  final String? status;
  final DateTime? dataFechamento;
  final DateTime? dataCadastro;

  Caixa({
    this.id,
    required this.descricao,
    required this.valorInicial,
    required this.defaultCaixa,
    this.status,
    this.dataFechamento,
    this.dataCadastro,
  });

  factory Caixa.fromJson(Map<String, dynamic> json) => Caixa(
        id: json['id'],
        descricao: json['descricao'],
        valorInicial: (json['valorInicial'] as num?)?.toDouble() ?? 0,
        defaultCaixa: json['defaultCaixa'] ?? false,
        status: json['status'],
        dataFechamento: json['dataFechamento'] != null
            ? DateTime.parse(json['dataFechamento'])
            : null,
        dataCadastro: json['dataCadastro'] != null
            ? DateTime.parse(json['dataCadastro'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "descricao": descricao,
        "valorInicial": valorInicial,
        "defaultCaixa": defaultCaixa,
      };
}
