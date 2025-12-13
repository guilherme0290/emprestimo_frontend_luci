import 'package:emprestimos_app/core/string.dart';
import 'package:emprestimos_app/core/theme/theme.dart';

import 'package:flutter/material.dart';

class DialogSolicitarAlteracaoParametro extends StatelessWidget {
  final String chave;
  final String valorAtual;
  final void Function(String novoValor) onEnviar;

  const DialogSolicitarAlteracaoParametro({
    Key? key,
    required this.chave,
    required this.valorAtual,
    required this.onEnviar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController novoValorController = TextEditingController();
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppTheme.backgroundColor,
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text("Solicitar alteração", style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined,
                  size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  chave.replaceAll('_', ' ').toLowerCase().capitalize(),
                  style: AppTheme.titleStyle.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Valor atual: $valorAtual",
            style: AppTheme.subtitleStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: novoValorController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Novo valor",
              prefixIcon: Icon(Icons.edit, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Será enviado para aprovação.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final novoValor = novoValorController.text.trim();
            if (novoValor.isNotEmpty) {
              onEnviar(novoValor);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Solicitação enviada para aprovação."),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            }
          },
          child: const Text("Enviar"),
        ),
      ],
    );
  }
}
