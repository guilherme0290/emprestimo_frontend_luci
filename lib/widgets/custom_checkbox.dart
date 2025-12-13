import 'package:flutter/material.dart';
import 'package:emprestimos_app/core/theme/theme.dart'; // ajuste se o caminho for diferente

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final EdgeInsetsGeometry? padding;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              decoration: BoxDecoration(
                color: value ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppTheme.primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              width: 22,
              height: 22,
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
