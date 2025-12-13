import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final String heroTag;
  final VoidCallback? onPressed; // <- permite null
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomFloatingActionButton({
    Key? key,
    required this.heroTag,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
