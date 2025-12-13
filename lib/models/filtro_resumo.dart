class FiltroResumo {
  final String? status;
  final String? dataInicio; // ISO 8601 (yyyy-MM-dd / toIsoString)
  final String? dataFim;
  final String? vencimentoOuPagamento; // "vencimento" | "pagamento" | null
  final int? caixaId;
  final int? vendedorId;

  const FiltroResumo({
    this.status,
    this.dataInicio,
    this.dataFim,
    this.vencimentoOuPagamento,
    this.caixaId,
    this.vendedorId,
  });
}
