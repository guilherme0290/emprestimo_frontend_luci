import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class SubTotalResumoTransacoesWidget extends StatelessWidget {
  final double entradaTotal;
  final double saidaTotal;

  const SubTotalResumoTransacoesWidget({
    super.key,
    required this.entradaTotal,
    required this.saidaTotal,
  });

  @override
  Widget build(BuildContext context) {
    final saldo = entradaTotal - saidaTotal;

    Widget buildItem({
      required String prefixo,
      required String valor,
      required Color corTexto,
      bool isValorNegrito = true,
    }) {
      return RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: prefixo,
              style: TextStyle(
                color: corTexto,
              ),
            ),
            TextSpan(
              text: valor,
              style: TextStyle(
                color: corTexto.withOpacity(0.7),
                fontWeight:
                    isValorNegrito ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    final children = [
      buildItem(
        prefixo: '🟢 Total Entrada: ',
        valor: 'R\$ ${entradaTotal.toStringAsFixed(2)}',
        corTexto: Colors.green,
      ),
      buildItem(
        prefixo: '🔴 Total Saída: ',
        valor: 'R\$ ${saidaTotal.toStringAsFixed(2)}',
        corTexto: Colors.red,
      ),
      buildItem(
        prefixo: '💲 Saldo: ',
        valor:
            '${saldo >= 0 ? '+' : '-'} R\$ ${saldo.abs().toStringAsFixed(2)}',
        corTexto: saldo >= 0 ? Colors.green : Colors.red,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: e,
              ))
          .toList(),
    );
  }
}
