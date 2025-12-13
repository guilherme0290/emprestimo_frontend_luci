import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/models/penhora.dart';

class ContasReceberDTO {
  final int id;
  final double valor;
  final double juros;
  final String tipoPagamento;
  final String dataPrimeiroVencimento;
  final String dataUltimoVencimento;
  final String statusContasReceber;
  final int? empresaId;
  final String? vendedorNome;
  final Cliente cliente;
  final PenhoraDTO? penhora;
  final List<ParcelaDTO> parcelas;
  final String dataContrato;
  final String? descricao;

  ContasReceberDTO(
      {required this.id,
      required this.valor,
      required this.juros,
      required this.tipoPagamento,
      required this.dataPrimeiroVencimento,
      required this.dataUltimoVencimento,
      required this.statusContasReceber,
      this.empresaId,
      required this.cliente,
      this.vendedorNome,
      required this.parcelas,
      this.penhora,
      required this.dataContrato,
      this.descricao});

  factory ContasReceberDTO.fromJson(Map<String, dynamic> json) {
    return ContasReceberDTO(
      id: json['id'] as int,
      valor: (json['valor'] as num).toDouble(),
      juros: (json['juros'] as num).toDouble(),
      tipoPagamento: json['tipoPagamento'] as String,
      dataPrimeiroVencimento: json['dataPrimeiroVencimento'] ?? '',
      dataUltimoVencimento: json['dataUltimoVencimento'] ?? '',
      statusContasReceber: json['statusContasReceber'] ?? '',
      empresaId: json['empresaId'] as int,
      cliente: Cliente.fromJson(json['cliente']),
      vendedorNome: json['vendedorNome'] ?? '',
      parcelas: (json['parcelas'] as List<dynamic>)
          .map((p) => ParcelaDTO.fromJson(p as Map<String, dynamic>))
          .toList(),
      penhora: json['penhora'] is Map<String, dynamic>
          ? PenhoraDTO.fromJson(json['penhora'])
          : null,
      dataContrato: FormatData.formatarData(json['dataContrato']),
      descricao: json['descricao'] as String?,
    );
  }

  // Método copyWith para atualizar um único campo sem modificar os demais
  ContasReceberDTO copyWith({List<ParcelaDTO>? parcelas}) {
    return ContasReceberDTO(
        id: id,
        valor: valor,
        juros: juros,
        tipoPagamento: tipoPagamento,
        dataPrimeiroVencimento: dataPrimeiroVencimento,
        dataUltimoVencimento: dataUltimoVencimento,
        statusContasReceber: statusContasReceber,
        empresaId: empresaId,
        cliente: cliente,
        parcelas: parcelas ?? this.parcelas,
        dataContrato: dataContrato,
        descricao: descricao);
  }
}
