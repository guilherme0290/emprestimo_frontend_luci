import 'package:flutter/material.dart';

class CardResumoParcelas extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? subtitulo; // Novo campo opcional
  final Color cor;
  final VoidCallback onDetalhar;

  const CardResumoParcelas({
    super.key,
    required this.titulo,
    required this.valor,
    this.subtitulo,
    required this.cor,
    required this.onDetalhar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitulo!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white, // tom vermelho claro
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          OutlinedButton(
            onPressed: onDetalhar,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
            ),
            child: const Text(
              "Detalhar Parcelas",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
