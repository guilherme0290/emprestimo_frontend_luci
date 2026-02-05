import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/relatorio_recebimento_item.dart';
import 'package:intl/intl.dart';

class RelatorioRecebimentoService {
  static String _formatDate(DateTime data) {
    return DateFormat('yyyy-MM-dd').format(data);
  }

  static Future<List<RelatorioRecebimentoItem>> buscar({
    DateTime? dataInicio,
    DateTime? dataFim,
    int? vendedorId,
    int? caixaId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (dataInicio != null) params['dataInicio'] = _formatDate(dataInicio);
      if (dataFim != null) params['dataFim'] = _formatDate(dataFim);
      if (vendedorId != null) params['vendedorId'] = vendedorId;
      if (caixaId != null) params['caixaId'] = caixaId;

      final response = await Api.dio.get(
        '/relatorio/recebimentos',
        queryParameters: params,
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (!apiResponse.sucesso) {
        throw Exception(apiResponse.message);
      }

      final data = apiResponse.data ?? [];
      return data
          .map((e) => RelatorioRecebimentoItem.fromJson(
              e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Erro ao buscar relatório");
    }
  }
}
