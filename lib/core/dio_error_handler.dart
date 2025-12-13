import 'package:dio/dio.dart';

class DioErrorHandler {
  /// 🔹 Método genérico para tratar erros do DioException
  static String handleDioException(DioException dioErr) {
    if (dioErr.response != null) {
      final statusCode = dioErr.response!.statusCode;
      final message = dioErr.response!.data["message"] ?? dioErr.message;

      switch (statusCode) {
        case 400:
          return "Erro de validação: $message";
        case 401:
          return "Sessão expirada. Faça login novamente.";
        case 403:
          return "Acesso negado: $message";
        case 404:
          return "Recurso não encontrado.";
        case 500:
          return "Erro interno no servidor. Tente novamente mais tarde.";
        default:
          return "Erro inesperado: $message";
      }
    } else {
      return "Falha na conexão com o servidor: ${dioErr.message}";
    }
  }
}
