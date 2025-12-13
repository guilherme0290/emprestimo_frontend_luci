
import 'package:emprestimos_app/models/previsao_recebimento.dart';
import 'package:emprestimos_app/screens/parcelas/parcelas_previsao_screen.dart';

import 'package:emprestimos_app/widgets/card_resumo_parcelas.dart';
import 'package:emprestimos_app/widgets/scroll_bahavior.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrevisaoRecebimentosHorizontal extends StatelessWidget {
  final List<PrevisaoRecebimento> previsoes;

  const PrevisaoRecebimentosHorizontal({super.key, required this.previsoes});

  int? diasPorTitulo(String titulo) {
    switch (titulo.toLowerCase()) {
      case 'hoje':
        return 0;
      case '7 dias':
        return 7;
      case '15 dias':
        return 15;
      case '30 dias':
        return 30;
      default:
        return null; // para "Personalizado", você pode lidar de forma diferente
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ScrollConfiguration(
        behavior: WebHorizontalScrollBehavior(),
        // Usando ScrollConfiguration para aplicar o comportamento de rolagem personalizado
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: previsoes.length,
          itemBuilder: (context, index) {
            final previsao = previsoes[index];
            final isHoje = previsao.titulo.toLowerCase() == "hoje";
            final temAtrasado = isHoje && (previsao.valorAtrasado) > 0;

            return CardResumoParcelas(
              titulo: previsao.titulo,
              valor: previsao.titulo.toLowerCase() == "personalizado"
                  ? "Selecionar 📆"
                  : "R\$ ${previsao.valor.toStringAsFixed(2).replaceAll('.', ',')}",
              cor: previsao.cor,
              subtitulo: temAtrasado
                  ? "🔴 Em Atraso: R\$ ${previsao.valorAtrasado.toStringAsFixed(2).replaceAll('.', ',')}"
                  : null,
              onDetalhar: () {
                final dias = diasPorTitulo(previsao.titulo);
                if (dias != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ParcelasPrevisaoScreen(
                        dias: dias,
                      ),
                    ),
                  );
                } else {
                  // Lógica para caso "Personalizado"
                  _abrirPeriodoPersonalizado(context);
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _abrirPeriodoPersonalizado(BuildContext context) {
    DateTime? dataInicio;
    DateTime? dataFim;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SafeArea(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.date_range,
                                  size: 40,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(height: 8),
                              const Text(
                                "Selecionar Período",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDataTile(
                          context: context,
                          label: "Data Início",
                          data: dataInicio,
                          onTap: () async {
                            final picked = await showDatePicker(
                              locale: const Locale('pt', 'BR'),
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => dataInicio = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDataTile(
                          context: context,
                          label: "Data Fim",
                          data: dataFim,
                          onTap: () async {
                            final picked = await showDatePicker(
                              locale: const Locale('pt', 'BR'),
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => dataFim = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.search),
                            label: const Text("Buscar",
                                style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (dataInicio != null && dataFim != null) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ParcelasPrevisaoScreen(
                                      dias: 0,
                                      dataInicio: dataInicio.toString(),
                                      dataFim: dataFim.toString(),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _buildDataTile({
    required BuildContext context,
    required String label,
    required DateTime? data,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data == null ? label : DateFormat('dd/MM/yyyy').format(data),
              style: TextStyle(
                fontSize: 16,
                color: data == null ? Colors.grey.shade600 : Colors.black,
              ),
            ),
            Icon(Icons.calendar_today,
                size: 20, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
