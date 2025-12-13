import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/screens/vendedores/vendedor_detail_screen.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';

import 'package:flutter/material.dart';

class ListaVendedoresWidget extends StatelessWidget {
  final List<Vendedor> vendedores;
  final String searchQuery;

  const ListaVendedoresWidget({
    super.key,
    required this.vendedores,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final filtrados = vendedores
        .where((vendedor) =>
            vendedor.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
            vendedor.cpf.contains(searchQuery))
        .toList();

    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/nenhum_cliente_encontrado.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "Nenhum vendedor encontrado !",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9E9E), // equivalente a Colors.grey[500]
              ),
            ),
          ],
        ),
      );
    }

    return AppBackground(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: filtrados.length,
        itemBuilder: (context, index) {
          final vendedor = filtrados[index];

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalheVendedorScreen(vendedor: vendedor),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Hero(
                    tag: 'vendedor_avatar_${vendedor.id}',
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person,
                          color: Colors.blue, size: 26),
                    ),
                  ),
                  title: Text(
                    vendedor.nome.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'R\$',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Util.formatarMoeda(
                                  vendedor.resumoVendedorDTO!.totalReceber,
                                  simbolo: false),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 16, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              "${vendedor.resumoVendedorDTO!.inadimplentes.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.grey, size: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
