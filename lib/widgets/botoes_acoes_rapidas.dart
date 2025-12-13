import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/screens/clientes/cliente_create_screen.dart';
import 'package:emprestimos_app/screens/clientes/cliente_list_screen.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_create_step1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BtnAcoesRapidas extends StatelessWidget {
  const BtnAcoesRapidas({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // 🔹 Ajustei a altura para melhor distribuição
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceEvenly, // 🔹 Distribui uniformemente os botões
        children: [
          _buildAcaoItem(
            "Novo",
            Icons.person_add,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ClienteFormScreen()),
            ),
            color: AppTheme.primaryColor,
          ),
          _buildAcaoItem(
            "Simular",
            Icons.attach_money,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContasReceberCreateStep1(cliente: null),
                ),
              ).then((_) async {
                final provider =
                    Provider.of<ContasReceberProvider>(context, listen: false);
                await provider.buscarParcelasRelevantes();
                await provider.buscarResumoVendedor(null);
              });
            },
            color: Colors.green,
          ),
          _buildAcaoItem(
            "Clientes",
            Icons.people,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClienteListScreen()),
              ).then((_) async {
                final provider =
                    Provider.of<ContasReceberProvider>(context, listen: false);
                await provider.buscarParcelasRelevantes();
                await provider.buscarResumoVendedor(null);
              });
            },
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

Widget _buildAcaoItem(String titulo, IconData icone, VoidCallback onTap,
    {Color color = Colors.blue}) {
  return Expanded(
    // 🔹 Agora os botões ocupam toda a altura do container
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // 🔹 Centraliza ícone e texto
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 26, color: color),
          ),
          const SizedBox(
              height: 8), // 🔹 Ajustei o espaçamento entre o ícone e o texto
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    ),
  );
}
