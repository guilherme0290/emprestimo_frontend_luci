class AprovacaoParametro {
  final int aprovacaoId;
  final int parametroId;
  final String chave;
  final String valorAnterior;
  final String valorSolicitado;
  final String status;
  final String nomeCliente;
  final String nomeSolicitante;
  final String dataSolicitacao;

  AprovacaoParametro({
    required this.aprovacaoId,
    required this.parametroId,
    required this.chave,
    required this.valorAnterior,
    required this.valorSolicitado,
    required this.status,
    required this.nomeCliente,
    required this.nomeSolicitante,
    required this.dataSolicitacao,
  });

  factory AprovacaoParametro.fromJson(Map<String, dynamic> json) {
    return AprovacaoParametro(
      aprovacaoId: json['aprovacaoId'],
      parametroId: json['parametroId'],
      chave: json['chave'],
      valorAnterior: json['valorAnterior'],
      valorSolicitado: json['valorSolicitado'],
      status: json['status'],
      nomeCliente: json['nomeCliente'],
      nomeSolicitante: json['nomeSolicitante'],
      dataSolicitacao: json['dataSolicitacao'],
    );
  }
}
