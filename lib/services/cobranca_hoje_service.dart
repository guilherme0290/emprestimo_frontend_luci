import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/detalhamento_parcela.dart';
import 'package:intl/intl.dart';

class CobrancaHojeService {
  static String _formatDate(DateTime data) {
    return DateFormat('yyyy-MM-dd').format(data);
  }

  static Future<List<DetalheParcelaDTO>> buscar({
    required DateTime vencimento,
    int? vendedorId,
    int? caixaId,
  }) async {
    try {
      final params = <String, dynamic>{
        'status': 'PENDENTE',
        'dataInicio': _formatDate(vencimento),
        'dataFim': _formatDate(vencimento),
        'vencimentoOuPagamento': 'vencimento',
      };

      if (vendedorId != null) params['vendedorId'] = vendedorId;
      if (caixaId != null) params['caixaId'] = caixaId;
      final response = await Api.dio.get(
        '/parcelas/detalhes',
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
          .map((e) => DetalheParcelaDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Erro ao buscar cobranças");
    }
  }
}
