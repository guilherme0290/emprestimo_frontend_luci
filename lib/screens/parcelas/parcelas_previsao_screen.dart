import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/parcela_resumo.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_detail_screen.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ParcelasPrevisaoScreen extends StatefulWidget {
  final int dias;
  final String? dataInicio;
  final String? dataFim;

  const ParcelasPrevisaoScreen({
    super.key,
    required this.dias,
    this.dataInicio,
    this.dataFim,
  });

  @override
  State<ParcelasPrevisaoScreen> createState() => _ParcelasPrevisaoScreenState();
}

class _ParcelasPrevisaoScreenState extends State<ParcelasPrevisaoScreen> {
  List<ParcelaResumoDTO> parcelas = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ContasReceberProvider>(context, listen: false)
          .buscarParcelasPrevisao(
        dias: widget.dias,
        dataInicio: widget.dataInicio,
        dataFim: widget.dataFim,
      );
    });
  }

  String formatCurrency(double valor) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);

  @override
  Widget build(BuildContext context) {
    final parcelaProvider = Provider.of<ContasReceberProvider>(context);
    final agrupadas =
        groupParcelasByContasReceber(parcelaProvider.parcelasPrevisao);

    final valorTotal = parcelaProvider.parcelasPrevisao
        .fold<double>(0.0, (sum, p) => sum + p.valorParcela);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.dataInicio != null && widget.dataFim != null)
              ? "${FormatData.formatarData(widget.dataInicio!)} a ${FormatData.formatarData(widget.dataFim!)}"
              : (widget.dias == 0
                  ? "Vencendo hoje ou em atraso"
                  : "Vencendo em ${widget.dias} dias"),
        ),
      ),
      body: parcelaProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : parcelaProvider.errorMessage != null
              ? Center(child: Text(parcelaProvider.errorMessage!))
              : agrupadas.isEmpty
                  ? Center(
                      child: Lottie.asset(
                        'assets/img/no-results.json',
                        height: 180,
                        repeat: true,
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Total a Receber",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatCurrency(valorTotal),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: agrupadas.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final grupo = agrupadas[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ContasReceberDetailScreen(
                                          contasreceberId:
                                              grupo['contasReceberId']),
                                    ),
                                  );
                                },
                                child: AppBackground(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: getCorFundoCardCliente(
                                          grupo['parcelas']),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            grupo['cliente'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Divider(height: 20),
                                          ...grupo['parcelas']
                                              .map<Widget>((parc) {
                                            final vencimento = DateTime.parse(
                                                parc['dataVencimento']);
                                            final diasRest = vencimento
                                                .difference(DateTime.now())
                                                .inDays;
                                            String textoDias;
                                            if (diasRest == 0) {
                                              textoDias = "Vencendo hoje";
                                            } else if (diasRest == 1) {
                                              textoDias = "Vence amanhã";
                                            } else if (diasRest < 0) {
                                              textoDias =
                                                  "Venceu há ${-diasRest} dias";
                                            } else {
                                              textoDias =
                                                  "Vence em $diasRest dias";
                                            }

                                            final valorFormatado =
                                                NumberFormat.currency(
                                                        locale: 'pt_BR',
                                                        symbol: 'R\$')
                                                    .format(
                                                        parc['valorParcela']);

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient:
                                                    Util.getGradientForStatus(
                                                        parc['statusParcela']),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        textoDias,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        "Status: ${parc['statusParcela']}",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white70),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    valorFormatado,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList()
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
    );
  }

  Color getCorFundoCardCliente(List parcelas) {
    if (parcelas.any((p) => p['statusParcela'] == 'ATRASADA')) {
      return const Color(0xFFFFEBEE); // vermelho claro
    } else if (parcelas.any((p) => p['statusParcela'] == 'PENDENTE')) {
      return const Color(0xFFFFF3E0); // laranja claro
    } else {
      return const Color(0xFFE8F5E9); // verde claro
    }
  }

  List<Map<String, dynamic>> groupParcelasByContasReceber(
      List<ParcelaResumoDTO> parcelas) {
    final Map<int, Map<String, dynamic>> agrupadas = {};

    for (final p in parcelas) {
      final id = p.contasreceberId;

      if (!agrupadas.containsKey(id)) {
        agrupadas[id] = {
          'contasReceberId': id,
          'cliente': p.clienteNome,
          'telefone': p.telefone,
          'parcelas': [],
        };
      }

      agrupadas[id]!['parcelas'].add({
        'id': p.id,
        'valorParcela': p.valorParcela,
        'dataVencimento': p.dataVencimento.toIso8601String(),
        'statusParcela': p.statusParcela,
      });
    }

    return agrupadas.values.toList();
  }
}

extension on String {
  String toIso8601String() {
    final date = DateTime.tryParse(this);
    return date?.toIso8601String() ?? '';
  }
}
