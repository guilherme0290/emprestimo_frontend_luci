import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/transacoes.dart';

import 'package:flutter/material.dart';

class TransacoesProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<TransacaoCaixaDTO> _transacoes = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TransacaoCaixaDTO> get transacoes => _transacoes;

  Future<void> buscarTransacoesCaixa({
    int? vendedorId,
    int? dias,
    String? tipo,
    String? dataInicio,
    String? dataFim,
    int? caixaId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};

      if (vendedorId != null) queryParams['vendedorId'] = vendedorId;
      if (dias != null) queryParams['dias'] = dias;
      if (tipo != null && tipo.isNotEmpty) queryParams['tipo'] = tipo;
      if (caixaId != null) queryParams['caixaId'] = caixaId;
      if (dataInicio != null && dataInicio.isNotEmpty) {
        queryParams['dataInicio'] = dataInicio;
      }
      if (dataFim != null && dataFim.isNotEmpty) {
        queryParams['dataFim'] = dataFim;
      }

      final response = await Api.dio
          .get('/parcelas/transacoes', queryParameters: queryParams);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.sucesso) {
        _transacoes = apiResponse.data!
            .map((e) => TransacaoCaixaDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = apiResponse.message;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar transações de caixa: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
