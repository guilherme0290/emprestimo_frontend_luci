class ClienteScoreHistorico {
  final int id;
  final int variacao;
  final String motivo;
  final DateTime createdAt;

  ClienteScoreHistorico({
    required this.id,
    required this.variacao,
    required this.motivo,
    required this.createdAt,
  });

  // 🔹 Método para converter um JSON em um objeto ClienteScoreHistorico
  factory ClienteScoreHistorico.fromJson(Map<String, dynamic> json) {
    return ClienteScoreHistorico(
      id: json['id'],
      variacao: json['variacao'],
      motivo: json['motivo'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // 🔹 Método para converter um objeto ClienteScoreHistorico em JSON (se precisar enviar via API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variacao': variacao,
      'motivo': motivo,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
