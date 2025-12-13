import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_detail_screen.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';

class ListaContasReceberWidget extends StatelessWidget {
  final List<ContasReceberDTO> contasreceber;
  final Future<void> Function()? onRefresh;
  final bool exibirNomeCliente;
  final bool isLoading;

  const ListaContasReceberWidget({
    super.key,
    required this.contasreceber,
    this.onRefresh,
    this.exibirNomeCliente = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (contasreceber.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/cliente_sem_emprestimo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "Este cliente não possui contratos ainda !",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9E9E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AppBackground(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contasreceber.length,
        itemBuilder: (context, index) {
          final emp = contasreceber[index];
          final int totalParcelas = emp.parcelas.length;
          final int parcelasPagas =
              emp.parcelas.where((p) => p.status == "PAGA").length;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: Util.getGradientForStatus(
                    emp.statusContasReceber.toUpperCase(),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    "${emp.tipoPagamento} - $parcelasPagas/$totalParcelas",
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading:
                      const Icon(Icons.circle, color: Colors.white70, size: 14),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: ${emp.statusContasReceber}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (exibirNomeCliente) ...[
                        const SizedBox(height: 4),
                        Text(
                          Util.getPrimeiroNome(emp.cliente.nome!),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ]
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ContasReceberDetailScreen(emprestimo: emp),
                      ),
                    ).then((_) {
                      if (onRefresh != null) {
                        onRefresh!();
                      }
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
