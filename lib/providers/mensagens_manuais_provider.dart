import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/core/dio_error_handler.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/mensagem_manual.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class MensagensManuaisProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<MensagemManual> _mensagens = [];

  MensagensManuaisProvider(this._authProvider);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<MensagemManual> get mensagens => _mensagens;

  Future<void> buscarMensagens() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/mensagens-manuais");

      final apiResponse = ApiResponse<List<MensagemManual>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => MensagemManual.fromJson(json))
            .toList(),
      );
      if (apiResponse.sucesso) {
        _mensagens = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }

      notifyListeners();
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro ao buscar mensagens: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> salvarMensagens(
      List<MensagemManual> mensagensAtualizadas) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.put(
        "/mensagens-manuais",
        data: mensagensAtualizadas.map((m) => m.toJson()).toList(),
      );

      final apiResponse = ApiResponse<List<MensagemManual>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => MensagemManual.fromJson(json))
            .toList(),
      );

      if (apiResponse.sucesso) {
        _mensagens = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }

      _successMessage = "Mensagens salvas com sucesso.";
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro ao salvar mensagens: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
