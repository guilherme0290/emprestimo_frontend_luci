import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:flutter/material.dart';
import '../models/cliente_score_historico.dart';

class ClienteScoreProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<ClienteScoreHistorico> _historicoScore = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClienteScoreHistorico> get historicoScore => _historicoScore;

  Future<void> buscarHistoricoScore(int clienteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/score/cliente/$clienteId");

      final apiResponse = ApiResponse<List<ClienteScoreHistorico>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => ClienteScoreHistorico.fromJson(json))
            .toList(),
      );

      if (apiResponse.sucesso) {
        _historicoScore = apiResponse.data!;
      } else {
        _errorMessage = apiResponse.message;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar histórico de score: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
