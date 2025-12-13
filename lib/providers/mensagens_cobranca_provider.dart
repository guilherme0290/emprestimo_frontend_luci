import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/mensagem_cobranca.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api.dart';
import '../core/dio_error_handler.dart';

class MensagemCobrancaProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<MensagemCobranca> _mensagens = [];

  MensagemCobrancaProvider(this._authProvider);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<MensagemCobranca> get mensagens => _mensagens;

  Future<void> buscarMensagens() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/mensagens-cobranca");

      final apiResponse = ApiResponse<List<MensagemCobranca>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => MensagemCobranca.fromJson(json))
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
      List<MensagemCobranca> mensagensAtualizadas) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.put(
        "/mensagens-cobranca",
        data: mensagensAtualizadas.map((m) => m.toJson()).toList(),
      );

      final apiResponse = ApiResponse<List<MensagemCobranca>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => MensagemCobranca.fromJson(json))
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

  Future<void> restaurarPadroes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      await Api.dio.put("/mensagens-cobranca/restaurar-padroes");
      await buscarMensagens();
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro ao restaurar padrões: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
