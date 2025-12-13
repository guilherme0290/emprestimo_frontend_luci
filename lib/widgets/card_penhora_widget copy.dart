import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/penhora.dart';
import 'package:flutter/material.dart';

class CardInfoPenhoraWidget extends StatelessWidget {
  final PenhoraDTO penhora;

  const CardInfoPenhoraWidget({
    super.key,
    required this.penhora,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.red.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
        title: const Text(
          "Este contrato possui uma garantia registrada.",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: const Text(
          "Toque para ver mais detalhes",
          style: TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  penhora.descricao,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.monetization_on,
                  color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                "Valor estimado: ${Util.formatarMoeda(penhora.valorEstimado)}",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
