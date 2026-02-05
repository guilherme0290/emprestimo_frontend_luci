import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/models/parcela_simulada.dart';
import 'package:emprestimos_app/models/penhora.dart';

class NovoContasReceberDTO {
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
  String? descricao;
  List<ParcelaSimulada>? parcelas;

  NovoContasReceberDTO(
      {required this.valor,
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
      this.descricao,
      this.parcelas});

  Map<String, dynamic> toJson() {
    return {
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
      'descricao': descricao,
      if (parcelas != null) 'parcelas': parcelas!.map((p) => p.toJson()).toList(),
    };
  }
}
