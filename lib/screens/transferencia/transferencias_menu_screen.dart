import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/screens/transferencia/transferencia_caixa_screen.dart';
import 'package:emprestimos_app/screens/transferencia/transferencia_vendedores_screen.dart';
import 'package:flutter/material.dart';

class TransferenciasMenuScreen extends StatelessWidget {
  const TransferenciasMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferências'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOption(
            context,
            icon: Icons.swap_horiz,
            title: 'Entre vendedores',
            subtitle: 'Mova contas entre vendedores.',
            screen: const TransferenciaVendedoresScreen(),
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.swap_vert,
            title: 'Entre caixas',
            subtitle: 'Mova contas entre caixas.',
            screen: const TransferenciaCaixaScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Card(
      elevation: 0,
      color: AppTheme.neutralColor,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}
