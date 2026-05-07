import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/models/parcela_simulada.dart';
import 'package:emprestimos_app/models/penhora.dart';

class NovoContasReceberDTO {
  String tipoContrato;
  double valor;
  double juros;
  int numeroParcelas;
  String tipoPagamento;
  Cliente? cliente;
  int? vendedorId;
  PenhoraDTO? penhora;
  int? caixaId;
  DateTime? dataPrimeiroVencimento;
  DateTime? dataContrato;
  bool vencimentoFixo;
  String politicaDiaNaoUtil;
  String? descricao;
  List<ParcelaSimulada>? parcelas;
  CobrancaRecorrenteDTO? cobrancaRecorrente;

  NovoContasReceberDTO(
      {this.tipoContrato = "PARCELADO",
      required this.valor,
      required this.juros,
      required this.numeroParcelas,
      required this.tipoPagamento,
      this.cliente,
      this.vendedorId,
      this.penhora,
      this.caixaId,
      required this.dataContrato,
      this.dataPrimeiroVencimento,
      this.vencimentoFixo = false,
      this.politicaDiaNaoUtil = "POSTERGAR",
      this.descricao,
      this.parcelas,
      this.cobrancaRecorrente});

  Map<String, dynamic> toJson() {
    return {
      'tipoContrato': tipoContrato,
      'valor': valor,
      'juros': juros,
      'numeroParcelas': numeroParcelas,
      'tipoPagamento': tipoPagamento,
      'clienteId': cliente?.id,
      'vendedorId': vendedorId,
      'penhoraDTO': penhora,
      'caixaId': caixaId,
      'dataPrimeiroVencimento': dataPrimeiroVencimento?.toIso8601String(),
      'dataContrato': dataContrato?.toIso8601String(),
      'vencimentoFixo': vencimentoFixo,
      'politicaDiaNaoUtil': politicaDiaNaoUtil,
      'descricao': descricao,
      if (cobrancaRecorrente != null)
        'cobrancaRecorrente': cobrancaRecorrente!.toJson(),
      if (parcelas != null) 'parcelas': parcelas!.map((p) => p.toJson()).toList(),
    };
  }
}

class CobrancaRecorrenteDTO {
  String periodicidade;
  int intervalo;
  double valorBase;
  DateTime dataInicio;
  int? diaVencimento;
  String tipoTermino;
  DateTime? dataFim;
  int? quantidadeCiclos;
  String politicaVencimento;
  String politicaDiaNaoUtil;

  CobrancaRecorrenteDTO({
    required this.periodicidade,
    this.intervalo = 1,
    required this.valorBase,
    required this.dataInicio,
    this.diaVencimento,
    this.tipoTermino = "SEM_FIM",
    this.dataFim,
    this.quantidadeCiclos,
    this.politicaVencimento = "MANTER_DIA",
    this.politicaDiaNaoUtil = "POSTERGAR",
  });

  Map<String, dynamic> toJson() {
    return {
      'periodicidade': periodicidade,
      'intervalo': intervalo,
      'valorBase': valorBase,
      'dataInicio': dataInicio.toIso8601String().split('T').first,
      'diaVencimento': diaVencimento,
      'tipoTermino': tipoTermino,
      'dataFim': dataFim?.toIso8601String().split('T').first,
      'quantidadeCiclos': quantidadeCiclos,
      'politicaVencimento': politicaVencimento,
      'politicaDiaNaoUtil': politicaDiaNaoUtil,
    };
  }
}
