class ResumoTransacao {
  final String tipo; // "recebimento" ou "emprestimo"
  final String descricao;
  final double valor;

  ResumoTransacao({
    required this.tipo,
    required this.descricao,
    required this.valor,
  });
}
