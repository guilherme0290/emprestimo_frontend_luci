import 'package:emprestimos_app/core/mensagem_tags.dart';
import 'package:flutter/material.dart';

class MensagemTagsQuickChips extends StatelessWidget {
  final Color accentColor;
  final ValueChanged<String> onTagTap;
  final VoidCallback onMoreTagsTap;
  final int maxTags;
  final String moreLabel;

  const MensagemTagsQuickChips({
    super.key,
    required this.accentColor,
    required this.onTagTap,
    required this.onMoreTagsTap,
    this.maxTags = 6,
    this.moreLabel = 'Mais tags',
  });

  @override
  Widget build(BuildContext context) {
    final tags = MensagemTags.todas.take(maxTags).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...tags.map(
          (t) => ActionChip(
            backgroundColor: accentColor.withValues(alpha: 0.08),
            side: BorderSide(color: accentColor.withValues(alpha: 0.15)),
            label: Text(t['tag']!),
            onPressed: () => onTagTap(t['tag']!),
          ),
        ),
        TextButton(
          onPressed: onMoreTagsTap,
          child: Text(moreLabel),
        ),
      ],
    );
  }
}
