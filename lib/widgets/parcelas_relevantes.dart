import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/parcela_resumo.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_detail_screen.dart';
import 'package:flutter/material.dart';

class ParcelasResumoCard extends StatelessWidget {
  final Future<void> Function() fetchData;
  final List<ParcelaResumoDTO> parcelas;
  final bool isLoading;

  const ParcelasResumoCard({
    Key? key,
    required this.fetchData,
    required this.parcelas,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final showScrollHint = parcelas.length > 3;
    return SizedBox(
      height: isMobile ? 250 : 390, // 🔹 Define um tamanho fixo para o card
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchData,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : parcelas.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Nenhuma parcela pendente 🎉",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: parcelas.length > 10
                                ? 10
                                : parcelas.length, // 🔹 Paginação de 10 em 10
                            itemBuilder: (context, index) {
                              final parcela = parcelas[index];
                              return _buildCobrancaItem(context, parcela);
                            },
                          ),
              ),
            ),
            if (showScrollHint)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.swap_vert, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Arraste dentro do card para ver mais parcelas",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Widget para exibir uma única cobrança
  Widget _buildCobrancaItem(BuildContext context, ParcelaResumoDTO parcela) {
    Color statusColor =
        parcela.statusParcela == "ATRASADA" ? Colors.red : Colors.orange;
    IconData statusIcon =
        parcela.statusParcela == "ATRASADA" ? Icons.error : Icons.schedule;

    final dataHoje = DateTime.now();
    final hojeSemHora = DateTime(dataHoje.year, dataHoje.month, dataHoje.day);

    final vencimento = DateTime.parse(parcela.dataVencimento);
    final vencimentoSemHora =
        DateTime(vencimento.year, vencimento.month, vencimento.day);

    final diasParaVencer = vencimentoSemHora.difference(hojeSemHora).inDays;

    String status;
    if (diasParaVencer == 0) {
      status = "Vencendo hoje";
    } else if (diasParaVencer == 1) {
      status = "Vence amanhã";
    } else if (diasParaVencer < 0) {
      status = "Venceu há ${diasParaVencer.abs()} dias";
    } else {
      status = "Vence em $diasParaVencer dias";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(statusIcon, color: statusColor),
          ),
          title: Text(
            parcela.clienteNome,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF4A4A4A), // Cinza escuro
            ),
          ),
          subtitle: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Util.formatarMoeda(parcela.valorParcela),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A), // Cinza escuro
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContasReceberDetailScreen(
                    contasreceberId: parcela.contasreceberId),
              ),
            );
          },
        ),
      ),
    );
  }
}
