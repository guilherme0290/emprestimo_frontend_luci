import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

enum AvaliacaoPromptAction { avaliar, adiar, recusar }

Future<AvaliacaoPromptAction?> showAvaliacaoPrompt(BuildContext context) {
  return showDialog<AvaliacaoPromptAction>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          "Gostou do app?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Sua avaliação ajuda a melhorar o app. "
          "Quer avaliar agora?",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext)
                  .pop(AvaliacaoPromptAction.adiar);
            },
            child: const Text("Lembrar em 7 dias"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext)
                  .pop(AvaliacaoPromptAction.recusar);
            },
            child: const Text("Não quero avaliar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext)
                  .pop(AvaliacaoPromptAction.avaliar);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Avaliar"),
          ),
        ],
      );
    },
  );
}
