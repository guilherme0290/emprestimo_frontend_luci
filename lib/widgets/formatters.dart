import 'package:flutter/services.dart';

class CpfCnpjFormatter extends TextInputFormatter {
  // 👉 helper para formatar fora do fluxo do teclado (initState, setText, etc)
  static String format(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    if (digits.length <= 11) {
      return _applyMask(digits, "###.###.###-##"); // CPF
    } else {
      return _applyMask(digits, "##.###.###/####-##"); // CNPJ
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = format(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static String _applyMask(String digits, String mask) {
    var out = StringBuffer();
    int i = 0;
    for (final ch in mask.split('')) {
      if (ch == '#') {
        if (i >= digits.length) break;
        out.write(digits[i++]);
      } else {
        if (i >= digits.length) break;
        out.write(ch);
      }
    }
    return out.toString();
  }
}

/// Telefone (suporta com e sem DDD)
class TelefoneFormatter extends TextInputFormatter {
  static String format(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    if (digits.length <= 10) {
      // (99) 9999-9999
      return CpfCnpjFormatter._applyMask(digits, "(##) ####-####");
    } else {
      // (99) 99999-9999
      return CpfCnpjFormatter._applyMask(digits, "(##) #####-####");
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = format(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// CEP (00000-000)
class CepFormatter extends TextInputFormatter {
  static String format(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    return CpfCnpjFormatter._applyMask(digits, "#####-###");
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = format(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
