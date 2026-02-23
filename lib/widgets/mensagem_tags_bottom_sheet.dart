import 'package:emprestimos_app/core/mensagem_tags.dart';
import 'package:flutter/material.dart';

Future<void> showMensagemTagsBottomSheet({
  required BuildContext context,
  required Color accentColor,
  required ValueChanged<String> onTagSelected,
}) async {
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.14),
                        accentColor.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tags disponíveis',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toque em uma tag para inserir na mensagem. Veja abaixo exemplos de como elas aparecem para o cliente.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    itemCount: MensagemTags.todas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final t = MensagemTags.todas[index];
                      final tag = t['tag']!;
                      final desc = t['desc']!;
                      final exemplo = _exemploTag(tag);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(context);
                            onTagSelected(tag);
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.035),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              accentColor.withValues(alpha: 0.10),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            color: accentColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: accentColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    desc,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            Colors.black.withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Exemplo: ',
                                            style: TextStyle(
                                              color: accentColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(text: exemplo),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _exemploTag(String tag) {
  const exemplos = {
    '{{nome}}': 'Maria Oliveira',
    '{{primeiro_nome}}': 'Maria',
    '{{saudacao}}': 'Boa tarde',
    '{{numero_parcela}}': '4',
    '{{valor_parcela}}': 'R\$ 185,00',
    '{{vencimento}}': '25/02/2026',
    '{{vencimento_extenso}}': '25 de fevereiro de 2026',
    '{{data_pagamento}}': '22/02/2026 14:35',
    '{{valor_pago}}': 'R\$ 185,00',
    '{{saldo_parcela}}': 'R\$ 0,00',
    '{{valor_total}}': 'R\$ 1.480,00',
    '{{contrato_id}}': '17452',
    '{{progresso_parcela}}': '4/5',
    '{{empresa}}': 'Financeira Central',
    '{{cobrador}}': 'Ana',
    '{{saldo_devedor}}': 'R\$ 740,00',
    '{{saldo_em_atraso}}': 'R\$ 185,00',
    '{{total_pago}}': 'R\$ 740,00',
    '{{parcelas_em_atraso}}': '1',
  };
  return exemplos[tag] ?? 'Valor de exemplo';
}
