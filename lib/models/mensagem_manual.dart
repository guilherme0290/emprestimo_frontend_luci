enum TipoMensagemManual {
  cobrancaAtraso,
  baixaParcela,
}

TipoMensagemManual tipoMensagemManualFromString(String tipo) {
  switch (tipo) {
    case 'COBRANCA_ATRASO':
      return TipoMensagemManual.cobrancaAtraso;
    case 'BAIXA_PARCELA':
      return TipoMensagemManual.baixaParcela;
    default:
      throw Exception("Tipo de mensagem manual inválido: $tipo");
  }
}

String tipoMensagemManualToString(TipoMensagemManual tipo) {
  switch (tipo) {
    case TipoMensagemManual.cobrancaAtraso:
      return 'COBRANCA_ATRASO';
    case TipoMensagemManual.baixaParcela:
      return 'BAIXA_PARCELA';
  }
}

class MensagemManual {
  final TipoMensagemManual tipo;
  String conteudo;
  bool ativo;
  String? templateId;
  bool? personalizada;

  MensagemManual({
    required this.tipo,
    required this.conteudo,
    this.ativo = true,
    this.templateId,
    this.personalizada,
  });

  factory MensagemManual.fromJson(Map<String, dynamic> json) {
    return MensagemManual(
      tipo: tipoMensagemManualFromString(json['tipo']),
      conteudo: json['conteudo'],
      ativo: json['ativo'] ?? true,
      templateId: json['templateId']?.toString(),
      personalizada: json['personalizada'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipoMensagemManualToString(tipo),
      'conteudo': conteudo,
      'ativo': ativo,
    };
  }

  MensagemManual copyWith({
    TipoMensagemManual? tipo,
    String? conteudo,
    bool? ativo,
    String? templateId,
    bool? personalizada,
  }) {
    return MensagemManual(
      tipo: tipo ?? this.tipo,
      conteudo: conteudo ?? this.conteudo,
      ativo: ativo ?? this.ativo,
      templateId: templateId ?? this.templateId,
      personalizada: personalizada ?? this.personalizada,
    );
  }
}
