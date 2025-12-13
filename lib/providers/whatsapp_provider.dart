import 'package:dio/dio.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/whatsapp_conexao_response.dart';
import 'package:emprestimos_app/models/whatsapp_instance_connect.dart';
import 'package:emprestimos_app/models/whatsapp_instancia_status.dart';
import 'package:emprestimos_app/models/whatsapp_logout_response.dart';
import 'package:emprestimos_app/models/whatsapp_mensagem_enviada.dart';
import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/dio_error_handler.dart';

class WhatsappProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _messageSucess;
  String? _status; // Ex: "open", "closed", "disconnected"

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get messageSucess => _messageSucess;
  String? get status => _status;

  bool get statusConectado => _status == "open";

  void resetMessages() {
    _errorMessage = null;
    _messageSucess = null;
    notifyListeners();
  }

  Future<WhatsappInstanciaStatusDTO?> getStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.get("/whatsapp/status");

      final apiResponse = ApiResponse<WhatsappInstanciaStatusDTO>.fromJson(
        response.data,
        (json) => WhatsappInstanciaStatusDTO.fromJson(json),
      );

      if (apiResponse.sucesso) {
        _status = apiResponse.data!.instance.state;
        return apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
        _status = null;
        return null;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      _status = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WhatsappConexaoResponseDTO?> criarInstancia(String numero,
      {bool isBusiness = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/whatsapp/criar/$numero",
      );

      final apiResponse = ApiResponse<WhatsappConexaoResponseDTO>.fromJson(
        response.data,
        (json) => WhatsappConexaoResponseDTO.fromJson(json),
      );

      if (apiResponse.sucesso) {
        _status = apiResponse.data?.instance.status;
        return apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
        return null;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WhatsappInstanceConnect?> conectarInstancia(String numero) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.post("/whatsapp/conectar/$numero");

      final apiResponse = ApiResponse<WhatsappInstanceConnect>.fromJson(
        response.data,
        (json) => WhatsappInstanceConnect.fromJson(json),
      );

      if (apiResponse.sucesso) {
        return apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
        return null;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.delete("/whatsapp/logout");

      final apiResponse = ApiResponse<WhatsappLogoutResponseDTO>.fromJson(
        response.data,
        (json) => WhatsappLogoutResponseDTO.fromJson(json),
      );

      if (apiResponse.sucesso) {
        _messageSucess = apiResponse.message;
        _status = null;
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletarInstancia() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.delete("/whatsapp/deletar");

      final apiResponse = ApiResponse<WhatsappLogoutResponseDTO>.fromJson(
        response.data,
        (json) => WhatsappLogoutResponseDTO.fromJson(json),
      );

      if (apiResponse.sucesso) {
        _messageSucess = apiResponse.message;
        _status = null;
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WhatsappMensagemEnviadaDTO?> enviarMensagem(
      String numero, String texto) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/whatsapp/mensagem/$numero",
        queryParameters: {"texto": texto},
      );

      final apiResponse = ApiResponse<WhatsappMensagemEnviadaDTO>.fromJson(
        response.data,
        (json) => WhatsappMensagemEnviadaDTO.fromJson(json),
      );

      if (apiResponse.sucesso) {
        _messageSucess = apiResponse.message;
        return apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
        return null;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
