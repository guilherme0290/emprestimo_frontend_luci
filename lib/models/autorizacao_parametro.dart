class AutorizacaoParametro {
  final int parametroId;
  final String novoValor;
  final int usuarioId;
  final int clienteId;

  AutorizacaoParametro({
    required this.parametroId,
    required this.novoValor,
    required this.usuarioId,
    required this.clienteId,
  });

  Map<String, dynamic> toJson() {
    return {
      "parametroId": parametroId,
      'novoValor': novoValor,
      'usuarioId': usuarioId,
      'clienteId': clienteId,
    };
  }
}
