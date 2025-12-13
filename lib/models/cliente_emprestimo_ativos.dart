class ClientesContasReceberAtivos {
  final int contasreceber;
  final int clientes;

  ClientesContasReceberAtivos({
    required this.contasreceber,
    required this.clientes,
  });

  // Construtor a partir de JSON
  factory ClientesContasReceberAtivos.fromJson(Map<String, dynamic> json) {
    return ClientesContasReceberAtivos(
      contasreceber: json['contasReceber'] as int,
      clientes: json['clientes'] as int,
    );
  }
}
