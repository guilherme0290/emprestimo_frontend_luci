import 'package:flutter/material.dart';

class PlaceholderTag {
  final String tag;
  final String descricao;
  final IconData icon;

  const PlaceholderTag({
    required this.tag,
    required this.descricao,
    required this.icon,
  });
}

class PlaceholderTagsWidget extends StatelessWidget {
  final void Function(String tag) onTagInsert;

  const PlaceholderTagsWidget({super.key, required this.onTagInsert});

  static final List<_TagInfo> tags = [
    _TagInfo("{{nome}}", "Nome do cliente (Ex: João Silva)", Icons.person),
    _TagInfo("{{valor_parcela}}", "Valor da parcela (Ex: R\$ 150,00)",
        Icons.attach_money),
    _TagInfo(
        "{{vencimento}}", "Data de vencimento (Ex: 22/05/2024)", Icons.event),
    _TagInfo(
        "{{vencimento_extenso}}", "Vencimento por extenso", Icons.event_note),
    _TagInfo("{{progresso_parcela}}", "Ex: 2/12", Icons.show_chart),
    _TagInfo("{{valor_total}}", "Valor total do contrato", Icons.calculate),
    _TagInfo("{{empresa}}", "Nome da empresa", Icons.apartment),
    _TagInfo(
        "{{saldo_devedor}}", "Saldo devedor do contrato", Icons.request_quote),
    _TagInfo("{{saudacao}}", "Bom dia, Boa tarde...", Icons.wb_sunny_outlined),
    _TagInfo("{{saldo_em_atraso}}", "Total vencido e não pago",
        Icons.warning_amber_outlined),
    _TagInfo("{{total_pago}}", "Total já pago", Icons.payments_outlined),
  ];

  void _mostrarAjuda(BuildContext context, String descricao) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajuda da Tag"),
        content: Text(descricao),
        actions: [
          TextButton(
            child: const Text("Fechar"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final larguraMinimaChip = 150.0;
        final chipsPorLinha = (constraints.maxWidth / larguraMinimaChip)
            .floor()
            .clamp(2, tags.length);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Toque para inserir uma tag. Pressione e segure para ajuda.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return SizedBox(
                  width: (constraints.maxWidth - (chipsPorLinha - 1) * 8) /
                      chipsPorLinha,
                  child: GestureDetector(
                    onTap: () => onTagInsert(tag.placeholder),
                    onLongPress: () => _mostrarAjuda(context, tag.descricao),
                    child: Tooltip(
                      message: tag.descricao,
                      child: Chip(
                        label: Text(tag.placeholder,
                            overflow: TextOverflow.ellipsis),
                        avatar: Icon(tag.icon, size: 18),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _TagInfo {
  final String placeholder;
  final String descricao;
  final IconData icon;

  _TagInfo(this.placeholder, this.descricao, this.icon);
}
