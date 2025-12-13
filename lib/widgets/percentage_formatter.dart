import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PercentFormatter extends MaskTextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: "");
    }

    // Remove caracteres não numéricos
    String numericValue = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Converte para número e limita a duas casas decimais
    double parsedValue = double.tryParse(numericValue) ?? 0;
    parsedValue /= 100; // Ajusta para casas decimais (ex: 105 -> 1.05%)

    // Formata como porcentagem
    String formattedText = "${parsedValue.toStringAsFixed(-1)}%";

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
          offset: formattedText.length - 1), // Mantém o cursor antes do "%"
    );
  }
}
