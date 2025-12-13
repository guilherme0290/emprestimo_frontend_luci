import 'package:emprestimos_app/models/cobranca.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CobrancaCard extends StatelessWidget {
  final Cobranca cobranca;

  const CobrancaCard({super.key, required this.cobranca});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(cobranca.clienteNome,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "Vence em: ${DateFormat("dd/MM/yyyy").format(cobranca.dataVencimento)}"),
        trailing: Text(
          "R\$ ${cobranca.valor.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
