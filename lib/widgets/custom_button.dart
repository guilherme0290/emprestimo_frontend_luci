import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final Curve animationCurve;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius = 16.0,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  LinearGradient _buildGradient(Color baseColor) {
    return LinearGradient(
      colors: [
        baseColor,
        baseColor.withOpacity(0.85),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? AppTheme.primaryColor;
    final effectiveTextColor = textColor ?? Colors.white;

    final isEnabled = enabled && onPressed != null;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedContainer(
        duration: animationDuration,
        curve: animationCurve,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? _buildGradient(effectiveBackgroundColor)
              : null,
          color: isEnabled ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: effectiveBackgroundColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            child: Text(
              text,
              style: textStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
