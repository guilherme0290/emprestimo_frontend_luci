class Plano {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final String? productIdGooglePlay;
  final bool? incluiWhatsapp;
  final List<String> beneficios;

  Plano({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.beneficios,
    this.incluiWhatsapp,
    this.productIdGooglePlay,
  });

  factory Plano.fromJson(Map<String, dynamic> json) {
    return Plano(
      id: json['id'] as int,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      preco: (json['preco'] as num).toDouble(),
      incluiWhatsapp: json['incluiWhatsapp'] ?? false,
      beneficios: List<String>.from(json['beneficios'] ?? []),
      productIdGooglePlay: json['product_id_google_play'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'beneficios': beneficios,
    };
  }
}
