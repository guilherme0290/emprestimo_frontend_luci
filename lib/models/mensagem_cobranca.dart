enum TipoMensagemCobranca {
  antesVencimento,
  diaVencimento,
  dividaoQuitada,
  emAtraso,
}

TipoMensagemCobranca tipoFromString(String tipo) {
  switch (tipo) {
    case 'ANTES_VENCIMENTO':
      return TipoMensagemCobranca.antesVencimento;
    case 'DIA_VENCIMENTO':
      return TipoMensagemCobranca.diaVencimento;
    case 'DIVIDA_QUITADA':
      return TipoMensagemCobranca.dividaoQuitada;
    case 'EM_ATRASO':
      return TipoMensagemCobranca.emAtraso;
    default:
      throw Exception("Tipo de mensagem inválido: $tipo");
  }
}

String tipoToString(TipoMensagemCobranca tipo) {
  switch (tipo) {
    case TipoMensagemCobranca.antesVencimento:
      return 'ANTES_VENCIMENTO';
    case TipoMensagemCobranca.diaVencimento:
      return 'DIA_VENCIMENTO';
    case TipoMensagemCobranca.dividaoQuitada:
      return 'DIVIDA_QUITADA';
    case TipoMensagemCobranca.emAtraso:
      return 'EM_ATRASO';
  }
}

class MensagemCobranca {
  final int? id;
  final TipoMensagemCobranca tipo;
  String conteudo;
  bool ativo;

  MensagemCobranca({
    this.id,
    required this.tipo,
    required this.conteudo,
    this.ativo = true,
  });

  factory MensagemCobranca.fromJson(Map<String, dynamic> json) {
    return MensagemCobranca(
      id: json['id'],
      tipo: tipoFromString(json['tipo']),
      conteudo: json['conteudo'],
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tipo': tipoToString(tipo),
      'conteudo': conteudo,
      'ativo': ativo,
    };
  }
}
