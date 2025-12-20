class ParametroVendedor {
  final int id;
  final String chave;
  final String valor;
  final Object? valorConvertido;
  final bool parametroPendente;

  ParametroVendedor({
    required this.id,
    required this.chave,
    required this.valor,
    this.valorConvertido,
    this.parametroPendente = false,
  });

  factory ParametroVendedor.fromJson(Map<String, dynamic> json) {
    return ParametroVendedor(
      id: json['id'],
      chave: json['chave'],
      valor: json['valor'] ?? '',
      valorConvertido: json['valorConvertido'],
      parametroPendente: json['parametroPendente'] ?? false,
    );
  }
}
