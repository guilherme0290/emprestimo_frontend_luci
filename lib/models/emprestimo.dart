import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/models/penhora.dart';

class ContasReceberDTO {
  final int id;
  final double valor;
  final double juros;
  final String tipoContrato;
  final String tipoPagamento;
  final String dataPrimeiroVencimento;
  final String dataUltimoVencimento;
  final String statusContasReceber;
  final int? empresaId;
  final int? vendedorId;
  final String? vendedorNome;
  final Cliente cliente;
  final PenhoraDTO? penhora;
  final List<ParcelaDTO> parcelas;
  final String dataContrato;
  final String? descricao;
  final CobrancaRecorrenteInfo? cobrancaRecorrente;

  ContasReceberDTO(
      {required this.id,
      required this.valor,
      required this.juros,
      required this.tipoContrato,
      required this.tipoPagamento,
      required this.dataPrimeiroVencimento,
      required this.dataUltimoVencimento,
      required this.statusContasReceber,
      this.empresaId,
      this.vendedorId,
      required this.cliente,
      this.vendedorNome,
      required this.parcelas,
      this.penhora,
      required this.dataContrato,
      this.descricao,
      this.cobrancaRecorrente});

  factory ContasReceberDTO.fromJson(Map<String, dynamic> json) {
    final clienteJson = json['cliente'] as Map<String, dynamic>;
    return ContasReceberDTO(
      id: json['id'] as int,
      valor: (json['valor'] as num).toDouble(),
      juros: (json['juros'] as num).toDouble(),
      tipoContrato: (json['tipoContrato'] ?? 'PARCELADO').toString(),
      tipoPagamento: json['tipoPagamento'] as String,
      dataPrimeiroVencimento: json['dataPrimeiroVencimento'] ?? '',
      dataUltimoVencimento: json['dataUltimoVencimento'] ?? '',
      statusContasReceber: json['statusContasReceber'] ?? '',
      empresaId: json['empresaId'] as int,
      vendedorId:
          (json['vendedorId'] as int?) ?? (clienteJson['vendedorId'] as int?),
      cliente: Cliente.fromJson(clienteJson),
      vendedorNome: json['vendedorNome'] ?? '',
      parcelas: (json['parcelas'] as List<dynamic>)
          .map((p) => ParcelaDTO.fromJson(p as Map<String, dynamic>))
          .toList(),
      penhora: json['penhora'] is Map<String, dynamic>
          ? PenhoraDTO.fromJson(json['penhora'])
          : null,
      dataContrato: FormatData.formatarData(json['dataContrato']),
      descricao: json['descricao'] as String?,
      cobrancaRecorrente: json['cobrancaRecorrente'] is Map<String, dynamic>
          ? CobrancaRecorrenteInfo.fromJson(
              json['cobrancaRecorrente'] as Map<String, dynamic>)
          : null,
    );
  }

  // Método copyWith para atualizar um único campo sem modificar os demais
  ContasReceberDTO copyWith({List<ParcelaDTO>? parcelas}) {
    return ContasReceberDTO(
        id: id,
        valor: valor,
        juros: juros,
        tipoContrato: tipoContrato,
        tipoPagamento: tipoPagamento,
        dataPrimeiroVencimento: dataPrimeiroVencimento,
        dataUltimoVencimento: dataUltimoVencimento,
        statusContasReceber: statusContasReceber,
        empresaId: empresaId,
        vendedorId: vendedorId,
        cliente: cliente,
        vendedorNome: vendedorNome,
        parcelas: parcelas ?? this.parcelas,
        penhora: penhora,
        dataContrato: dataContrato,
        descricao: descricao,
        cobrancaRecorrente: cobrancaRecorrente);
  }
}

class CobrancaRecorrenteInfo {
  final String periodicidade;
  final int? intervalo;
  final double? valorBase;
  final String? dataInicio;
  final int? diaVencimento;
  final String? tipoTermino;
  final String? dataFim;
  final int? quantidadeCiclos;
  final String? politicaVencimento;
  final String? politicaDiaNaoUtil;

  CobrancaRecorrenteInfo({
    required this.periodicidade,
    this.intervalo,
    this.valorBase,
    this.dataInicio,
    this.diaVencimento,
    this.tipoTermino,
    this.dataFim,
    this.quantidadeCiclos,
    this.politicaVencimento,
    this.politicaDiaNaoUtil,
  });

  factory CobrancaRecorrenteInfo.fromJson(Map<String, dynamic> json) {
    return CobrancaRecorrenteInfo(
      periodicidade: (json['periodicidade'] ?? 'MENSAL').toString(),
      intervalo: json['intervalo'] as int?,
      valorBase: (json['valorBase'] as num?)?.toDouble(),
      dataInicio: json['dataInicio']?.toString(),
      diaVencimento: json['diaVencimento'] as int?,
      tipoTermino: json['tipoTermino']?.toString(),
      dataFim: json['dataFim']?.toString(),
      quantidadeCiclos: json['quantidadeCiclos'] as int?,
      politicaVencimento: json['politicaVencimento']?.toString(),
      politicaDiaNaoUtil: json['politicaDiaNaoUtil']?.toString(),
    );
  }
}
