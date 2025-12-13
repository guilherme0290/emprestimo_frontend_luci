import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final IconData? icon;

  const CustomSwitchTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor, // Cor do switch ativado
      inactiveTrackColor: AppTheme.neutralColor, // Cor do fundo desativado
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
