import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/penhora.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardInfoPenhoraWidget extends StatelessWidget {
  final PenhoraDTO penhora;

  const CardInfoPenhoraWidget({
    super.key,
    required this.penhora,
  });

  @override
  Widget build(BuildContext context) {
    final bool executada = penhora.status == "EXECUTADA";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: executada ? Colors.green.shade50 : Colors.red.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          executada ? Icons.check_circle : Icons.warning_amber_rounded,
          color: executada ? Colors.green : Colors.red,
        ),
        title: Text(
          executada
              ? "Este contrato foi quitado com uma garantia."
              : "Este contrato possui uma garantia registrada.",
          style: TextStyle(
            color: executada ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          executada
              ? "Toque para ver detalhes da penhora"
              : "Toque para ver mais detalhes",
          style: TextStyle(
              color: executada ? Colors.green.shade700 : Colors.redAccent,
              fontSize: 12),
        ),
        children:
            executada ? _buildDetalhesExecutada() : _buildDetalhesNormal(),
      ),
    );
  }

  List<Widget> _buildDetalhesNormal() {
    return [
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
          const Icon(Icons.monetization_on, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            "Valor estimado: ${Util.formatarMoeda(penhora.valorEstimado)}",
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDetalhesExecutada() {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description, color: Colors.green, size: 18),
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
          const Icon(Icons.monetization_on, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(
            "Valor executado: ${Util.formatarMoeda(penhora.valorEstimado)}",
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.date_range, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(
            "Data execução: ${penhora.dataExecucaoPenhora != null ? DateFormat('dd/MM/yyyy').format(penhora.dataExecucaoPenhora!) : '--'}",
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    ];
  }
}
