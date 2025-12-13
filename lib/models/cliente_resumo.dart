class ClienteResumo {
  final int id;
  final String nome;

  ClienteResumo({
    required this.id,
    required this.nome,
  });

  // Construtor a partir de JSON
  factory ClienteResumo.fromJson(Map<String, dynamic> json) {
    return ClienteResumo(
      id: json['id'] as int,
      nome: json['nome'] as String,
    );
  }
}
