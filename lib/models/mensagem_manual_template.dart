import 'package:emprestimos_app/models/mensagem_manual.dart';

class MensagemManualTemplate {
  final String id;
  final TipoMensagemManual tipo;
  final String titulo;
  final String conteudo;

  const MensagemManualTemplate({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.conteudo,
  });

  factory MensagemManualTemplate.fromJson(Map<String, dynamic> json) {
    return MensagemManualTemplate(
      id: (json['id'] ?? json['templateId'] ?? '').toString(),
      tipo: tipoMensagemManualFromString((json['tipo'] ?? '').toString()),
      titulo: (json['titulo'] ?? json['nome'] ?? 'Modelo').toString(),
      conteudo: (json['conteudo'] ?? '').toString(),
    );
  }
}
