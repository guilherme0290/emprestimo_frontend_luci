import 'package:dio/dio.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/whatsapp_conexao_response.dart';
import 'package:emprestimos_app/models/whatsapp_codigo_conexao.dart';
import 'package:emprestimos_app/models/whatsapp_status.dart';
import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/dio_error_handler.dart';

class WhatsappProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _status = false;
  String? _codigo;
  String? _qrBase64;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get status => _status;
  String? get codigoConexao => _codigo;
  String? get qrBase64 => _qrBase64;

  /// Consulta o status da instância Z-API (via backend)
  Future<bool> carregarStatusWhatsapp() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.get('/whatsapp/status');

      final apiResponse = ApiResponse<WhatsappStatusResponse>.fromJson(
        response.data,
        (json) => WhatsappStatusResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        final status = apiResponse.data;
        if (status == null) {
          _errorMessage = "Resposta inválida do servidor ao consultar status.";
          return false;
        }
        _status = status.connected;
        return true;
      }
      _errorMessage = apiResponse.message;
    } on DioException catch (dioErr) {
      if (dioErr.response?.statusCode == 400) {
        final apiResponse = ApiResponse<String>.fromJson(
          dioErr.response!.data,
          (json) => json.toString(),
        );

        _errorMessage = apiResponse.message;
      } else {
        _errorMessage = DioErrorHandler.handleDioException(dioErr);
      }
    } catch (e) {
      _errorMessage = "Erro inesperado ao consultar status: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  /// Gera o código de conexão da Z-API baseado no número informado
  Future<String?> gerarCodigoConexao(String numero) async {
    _isLoading = true;
    _errorMessage = null;
    _codigo = null;
    _qrBase64 = null;
    notifyListeners();

    try {
      final response = await Api.dio.post('/whatsapp/conectar/$numero');

      final apiResponse = ApiResponse<WhatsappCodigoConexao>.fromJson(
        response.data,
        (json) => WhatsappCodigoConexao.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _codigo = apiResponse.data?.code;
        _qrBase64 = apiResponse.data?.base64;
        return _codigo;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      final message = _extractApiMessage(dioErr);
      if (message != null &&
          (message.toLowerCase().contains('instancia nao encontrada') ||
              message.toLowerCase().contains('instância não encontrada'))) {
        final criado = await _criarInstancia(numero);
        if (criado != null) return criado;
      } else {
        _errorMessage = DioErrorHandler.handleDioException(dioErr);
      }
    } catch (e) {
      _errorMessage = "Erro inesperado ao gerar código: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  Future<bool> desconectarWhatsapp() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.delete('/whatsapp/logout');
      final apiResponse = ApiResponse<String>.fromJson(
        response.data,
        (json) => json.toString(),
      );
      if (apiResponse.sucesso) {
        _status = false;
        _codigo = null;
        _qrBase64 = null;
        return true;
      }
      _errorMessage = apiResponse.message;
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao desconectar: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<String?> _criarInstancia(String numero) async {
    try {
      final response = await Api.dio.post('/whatsapp/criar/$numero');

      final apiResponse = ApiResponse<WhatsappConexaoResponse>.fromJson(
        response.data,
        (json) =>
            WhatsappConexaoResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        final codigo = apiResponse.data?.qrcode?.code;
        _qrBase64 = apiResponse.data?.qrcode?.base64;
        if (codigo != null && codigo.isNotEmpty) {
          _codigo = codigo;
          return _codigo;
        }
        // fallback: tentar conectar novamente para obter o código
        final conectar = await Api.dio.post('/whatsapp/conectar/$numero');
        final connectResponse = ApiResponse<WhatsappCodigoConexao>.fromJson(
          conectar.data,
          (json) =>
              WhatsappCodigoConexao.fromJson(json as Map<String, dynamic>),
        );
        if (connectResponse.sucesso) {
          _codigo = connectResponse.data?.code;
          _qrBase64 = connectResponse.data?.base64;
          return _codigo;
        }
        _errorMessage = connectResponse.message;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao criar instância: $e";
    }

    return null;
  }

  String? _extractApiMessage(DioException dioErr) {
    if (dioErr.response?.data is Map<String, dynamic>) {
      final apiResponse = ApiResponse<String>.fromJson(
        dioErr.response!.data,
        (json) => json.toString(),
      );
      return apiResponse.message;
    }
    return null;
  }
}
