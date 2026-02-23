import 'package:flutter/material.dart';

class MensagemModeloPronto {
  final String id;
  final String titulo;
  final String conteudo;

  const MensagemModeloPronto({
    required this.id,
    required this.titulo,
    required this.conteudo,
  });
}

class MensagemModelosProntosSelector extends StatelessWidget {
  final Color accentColor;
  final List<MensagemModeloPronto> modelos;
  final String? modeloSelecionadoId;
  final ValueChanged<MensagemModeloPronto> onAplicarModelo;
  final ValueChanged<MensagemModeloPronto>? onPreviewModelo;

  const MensagemModelosProntosSelector({
    super.key,
    required this.accentColor,
    required this.modelos,
    required this.modeloSelecionadoId,
    required this.onAplicarModelo,
    this.onPreviewModelo,
  });

  @override
  Widget build(BuildContext context) {
    if (modelos.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: accentColor, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Modelos',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${modelos.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ExpansionPanelList.radio(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            materialGapSize: 8,
            dividerColor: Colors.transparent,
            children: modelos.map((modelo) {
              final selecionado = modelo.id == modeloSelecionadoId;
              return ExpansionPanelRadio(
                value: modelo.id,
                canTapOnHeader: true,
                backgroundColor: selecionado
                    ? accentColor.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.4),
                headerBuilder: (context, isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selecionado
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: selecionado ? accentColor : Colors.black38,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            modelo.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (selecionado)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Atual',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Text(
                          modelo.conteudo,
                          style: const TextStyle(height: 1.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (onPreviewModelo != null) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => onPreviewModelo!(modelo),
                                icon: const Icon(Icons.preview_outlined),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: accentColor,
                                  side: BorderSide(
                                    color: accentColor.withValues(alpha: 0.22),
                                  ),
                                ),
                                label: const Text('Exemplo'),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => onAplicarModelo(modelo),
                              icon: const Icon(Icons.task_alt),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accentColor,
                                backgroundColor:
                                    accentColor.withValues(alpha: 0.06),
                                side: BorderSide(
                                  color: accentColor.withValues(alpha: 0.24),
                                ),
                              ),
                              label: const Text(
                                'Escolher',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
