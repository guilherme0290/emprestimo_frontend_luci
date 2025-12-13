import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter extends TextInputFormatter {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: "R\$ ");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: "");
    }

    // Remove todos os caracteres não numéricos
    String numericValue = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Converte para número
    double parsedValue = double.tryParse(numericValue) ?? 0;

    // Formata para moeda
    String formattedText = currencyFormat.format(parsedValue / 100);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
