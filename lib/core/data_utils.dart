import 'package:intl/intl.dart';

class FormatData {
  /// Formata uma data recebida em formato ISO 8601 para "dd/MM/yy"
  static String formatarData(String? data) {
    if (data == null || data.isEmpty) return "--/--/--";

    try {
      DateTime parsedDate = DateTime.parse(data);
      return DateFormat("dd/MM/yy").format(parsedDate);
    } catch (e) {
      print("Erro ao formatar data: $e");
      return "--/--/--";
    }
  }

  static String formatarDataYYYYAADD(String? data) {
    if (data == null || data.isEmpty) return "--/--/--";

    try {
      DateTime parsedDate = DateTime.parse(data);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      print("Erro ao formatar data: $e");
      return "--/--/--";
    }
  }

  static String formatarDataHora(String? data) {
    if (data == null || data.isEmpty) return "--/--/---- --:--";

    try {
      DateTime parsedDate = DateTime.parse(data);
      return DateFormat("dd/MM HH:mm", "pt_BR").format(parsedDate);
    } catch (e) {
      print("Erro ao formatar data e hora: $e");
      return "--/--/---- --:--";
    }
  }

  /// Formata uma data para "dd/MMM/yy" (ex: 06/Mar/25)
  static String formatarDataComMesExtenso(String? data) {
    if (data == null || data.isEmpty) return "--/---/--";

    try {
      DateTime parsedDate = DateTime.parse(data);
      return DateFormat("dd/MMM/yy HH:ss", "pt_BR").format(parsedDate);
    } catch (e) {
      print("Erro ao formatar data: $e");
      return "--/---/--";
    }
  }

  /// Formata a data no formato `13 de Março de 2025`
  static String formatarDataCompleta(String? data) {
    if (data == null || data.isEmpty) return "--";

    try {
      DateTime parsedDate = DateTime.parse(data);
      return DateFormat("dd 'de' MMMM 'de' yyyy", "pt_BR").format(parsedDate);
    } catch (e) {
      print("Erro ao formatar data: $e");
      return "--";
    }
  }

  /// Formata uma data para "dd/MMM" (ex: 06/Fev)
  static String formatarDataCurta(String? data) {
    if (data == null || data.isEmpty) return "--/---";

    try {
      DateTime parsedDate = DateTime.parse(data);
      return DateFormat("dd/MMM", "pt_BR").format(parsedDate);
    } catch (e) {
      print("Erro ao formatar data: $e");
      return "--/---";
    }
  }

  static String formatarDataCompletaPadrao(DateTime? data) {
    if (data == null) return "--/--/----";

    try {
      return DateFormat("dd/MM/yyyy").format(data);
    } catch (e) {
      print("Erro ao formatar data completa padrão: $e");
      return "--/--/----";
    }
  }
}
