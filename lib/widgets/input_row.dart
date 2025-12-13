// lib/widgets/input_row2.dart
import 'package:flutter/material.dart';

class InputRow2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double breakpoint; // largura mínima para virar 2 colunas
  final double gap; // espaço entre campos
  final int leftFlex;
  final int rightFlex;

  const InputRow2({
    super.key,
    required this.left,
    required this.right,
    this.breakpoint = 720,
    this.gap = 12,
    this.leftFlex = 1,
    this.rightFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > breakpoint;
    if (!isWide) {
      return Column(
        children: [
          left,
          SizedBox(height: gap),
          right,
          SizedBox(height: gap),
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: leftFlex, child: left),
        SizedBox(width: gap),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }
}
