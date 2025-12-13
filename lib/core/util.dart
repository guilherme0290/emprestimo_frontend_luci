import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:emprestimos_app/models/parametro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Util {
  static Gradient getGradientForStatus(String status) {
    switch (status.toUpperCase()) {
      case "PAGA":
      case "QUITADO":
        return const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF1B5E20)], // Verde forte
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "PENDENTE":
      case "ATIVO":
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFEF6C00)], // Laranja
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "ATRASADA":
      case "ATRASADO":
        return const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)], // Vermelho forte
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF757575), Color(0xFF424242)], // Cinza escuro
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // ATIVO, QUITADO, ATRASADO;

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "PAGA" || "QUITADO":
        return Colors.green; // Verde para parcelas pagas
      case "ATRASADA" || "ATRASADO":
        return Colors.red; // Vermelho para parcelas atrasadas
      default:
        return Colors.orange; // Laranja para parcelas pendentes
    }
  }

  static String formatarMoeda(double valor, {bool simbolo = true}) {
    final formatoMoeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: simbolo ? 'R\$ ' : '',
      decimalDigits: 2,
    );
    return formatoMoeda.format(valor);
  }

  static removerMascara(String valor) {
    return valor.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static double removerMascaraValor(String valorFormatado) {
    if (valorFormatado.isEmpty) return 0.0;

    // Remove "R$", espaços e pontos (mantém apenas números e vírgulas)
    String valorLimpo = valorFormatado.replaceAll(RegExp(r'[^\d,]'), '');

    // Substitui a vírgula decimal por ponto para conversão correta
    valorLimpo = valorLimpo.replaceAll(',', '.');

    return double.tryParse(valorLimpo) ?? 0.0;
  }

  static String getPrimeiroNome(String nomeCompleto) {
    if (nomeCompleto.trim().isEmpty) return "";
    String primeiroNome = nomeCompleto.trim().split(" ").first;

    return primeiroNome[0].toUpperCase() +
        primeiroNome.substring(1).toLowerCase();
  }

  static String? isCpfCnpjValid(String cpfCnpj, {bool obrigatorio = true}) {
    if (cpfCnpj.isEmpty && !obrigatorio) {
      return null;
    }

    if (cpfCnpj.isEmpty && obrigatorio) {
      return 'O CPF/CNPJ é obrigatório';
    }
    if (!CPFValidator.isValid(cpfCnpj) && !CNPJValidator.isValid(cpfCnpj)) {
      return 'CPF/CNPJ inválido';
    }

    return null;
  }

  static String? isEmailValid(String email) {
    if (email.isEmpty) {
      return "Email Invalido, Campo Obrigatório";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if ((!emailRegex.hasMatch(email)) && !email.contains(".com")) {
      return "E-mail inválido";
    }
    return null;
  }

  /// Retorna o valor de um parâmetro como `double`, ou `null` se não encontrado ou inválido.
  static double getParametroDouble(String chave, List<Parametro> parametros) {
    if (parametros.isEmpty) return 0.0;

    final param = parametros.firstWhere(
      (p) => p.chave == chave,
      orElse: () => Parametro(
        chave: '',
        valor: '',
        id: 0,
        referenciaId: 0,
        tipoReferencia: '',
      ),
    );

    if (param.valor.isEmpty) return 0.0;

    return double.tryParse(param.valor.replaceAll(',', '.')) ?? 0.0;
  }

  /// Retorna o valor de um parâmetro como `int`, ou `null` se não encontrado ou inválido.
  static int getParametroInt(String chave, List parametros) {
    if (parametros.isEmpty) return 0;
    final param = parametros.firstWhere(
      (p) => p.chave == chave,
      orElse: () => Parametro(
        chave: '',
        valor: '',
        id: 0,
        referenciaId: 0,
        tipoReferencia: '',
      ),
    );
    if (param.valor.isEmpty) return 0;

    return int.tryParse(param.valor) ?? 0;
  }
}
