class Notificacao {
  final int id;
  final String titulo;
  final String mensagem;
  final bool visualizado;
  final DateTime? dataEnvio;
  final String? tipo;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.visualizado,
    this.dataEnvio,
    this.tipo,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'],
      titulo: json['titulo'],
      mensagem: json['mensagem'],
      visualizado: json['visualizado'],
      dataEnvio: json['dataEnvio'] != null
          ? DateTime.tryParse(json['dataEnvio'])
          : null,
      tipo: json['tipo'],
    );
  }
}
