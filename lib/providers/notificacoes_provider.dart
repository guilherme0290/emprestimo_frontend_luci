import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/notificacao.dart';
import 'package:flutter/material.dart';
import '../core/api.dart';
import '../providers/auth_provider.dart';

class NotificacaoProvider with ChangeNotifier {
  AuthProvider _authProvider;

  NotificacaoProvider(this._authProvider);

  bool _isLoading = false;
  String? _errorMessage;
  List<Notificacao> _notificacoes = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Notificacao> get notificacoes => _notificacoes;

  int get notificacoesNaoVisualizadas =>
      _notificacoes.where((n) => !n.visualizado).length;

  Future<void> buscarNotificacoes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authProvider.loginResponse?.usuario.id;
      if (userId == null) {
        _errorMessage = "Usuário não autenticado.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final path = "/notificacoes/usuario/$userId";

      final response = await Api.dio.get(path);

      final apiResponse = ApiResponse<List<Notificacao>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => Notificacao.fromJson(json))
            .toList(),
      );

      if (apiResponse.sucesso) {
        _notificacoes = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar notificações.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void atualizarAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
}
