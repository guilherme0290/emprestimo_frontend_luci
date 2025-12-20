class AutorizacaoParametro {
  final int parametroId;
  final String novoValor;
  final int usuarioId;
  final int? clienteId;

  AutorizacaoParametro({
    required this.parametroId,
    required this.novoValor,
    required this.usuarioId,
    this.clienteId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "parametroId": parametroId,
      'novoValor': novoValor,
      'usuarioId': usuarioId,
    };
    if (clienteId != null) {
      data['clienteId'] = clienteId!;
    }
    return data;
  }
}
