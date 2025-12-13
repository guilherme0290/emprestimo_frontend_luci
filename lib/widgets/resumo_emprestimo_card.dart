import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import 'package:provider/provider.dart';
import '../../providers/emprestimo_provider.dart';

class ResumoContasReceberCard extends StatelessWidget {
  final Cliente cliente;

  const ResumoContasReceberCard({Key? key, required this.cliente})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContasReceberProvider>(context);
    final soma = provider.somaContasReceber;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient, // 🔹 Gradiente do tema
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              "Resumo das Vendas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow([
              _buildInfoItem(Icons.monetization_on, "Total Emprestado",
                  Util.formatarMoeda(soma)),
              _buildInfoItem(
                  Icons.trending_up, "Lucro Gerado", Util.formatarMoeda(2000)),
            ]),
          ],
        ),
      ),
    );
  }

  /// 🔹 Função auxiliar para montar as informações com layout ajustado
  Widget _buildInfoRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }

  /// 🔹 Função auxiliar para criar um item de informação no card
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
