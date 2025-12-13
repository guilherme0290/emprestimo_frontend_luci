class Notificacao {
  final int id;
  final String titulo;
  final String mensagem;
  final bool visualizado;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.visualizado,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'],
      titulo: json['titulo'],
      mensagem: json['mensagem'],
      visualizado: json['visualizado'],
    );
  }
}
