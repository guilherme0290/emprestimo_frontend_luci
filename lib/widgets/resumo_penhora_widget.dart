import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/request_emprestimo.dart';
import 'package:flutter/material.dart';

class ResumoPenhoraWidget extends StatelessWidget {
  final NovoContasReceberDTO emprestimo;

  const ResumoPenhoraWidget({
    super.key,
    required this.emprestimo,
  });

  @override
  Widget build(BuildContext context) {
    if (emprestimo.penhora == null) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: const Icon(Icons.security, color: AppTheme.primaryColor),
          title: const Text(
            "Penhora",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          children: [
            ListTile(
              leading: const Icon(Icons.description, color: Colors.black54),
              title: Text(
                emprestimo.penhora!.descricao,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.black54),
              title: Text(
                "Valor estimado: ${Util.formatarMoeda(emprestimo.penhora!.valorEstimado)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
