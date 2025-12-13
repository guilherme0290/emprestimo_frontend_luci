import 'package:emprestimos_app/core/dio_error_handler.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/cliente_resumo.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api.dart';
import '../models/cliente.dart';

class ClienteProvider extends ChangeNotifier {
  List<Cliente> _clientes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _messageSucess;
  AuthProvider _authProvider;

  List<Cliente> get clientes => _clientes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get messageSucess => _messageSucess;

  List<ClienteResumo> _clientesResumidos = [];
  List<ClienteResumo> get clientesResumidos => _clientesResumidos;

  ClienteProvider(this._authProvider);

  Future<Map<String, String>?> buscarCep(String cep) async {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: "https://viacep.com.br",
        connectTimeout: const Duration(seconds: 5000),
        receiveTimeout: const Duration(seconds: 5000),
      ),
    );

    try {
      final response = await dio.get("/ws/$cep/json/");

      if (response.statusCode == 200 && response.data["erro"] == null) {
        return {
          "logradouro": response.data["logradouro"] ?? "",
          "bairro": response.data["bairro"] ?? "",
          "cidade": response.data["localidade"] ?? "",
          "uf": response.data["uf"] ?? "",
        };
      }
    } catch (e) {
      debugPrint("Erro ao buscar CEP: $e");
    }
    return null;
  }

  Future<void> carregarClientes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      String path = "/clientes";
      if (_authProvider.loginResponse!.role == "VENDEDOR") {
        path = "/clientes/vendedor/${_authProvider.loginResponse!.usuario.id}";
      }

      final response = await Api.dio.get(path);

      // Convertendo a resposta em lista de Clientes
      _clientes =
          (response.data as List).map((e) => Cliente.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = "Erro ao carregar clientes: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> listarClientesResumido() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/clientes/resumo");

      final apiResponse = ApiResponse<List<ClienteResumo>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((e) => ClienteResumo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.sucesso) {
        _messageSucess = apiResponse.message;
        _clientesResumidos = apiResponse.data!;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao listar clientes: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarCliente(Cliente cliente) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/clientes",
        data: cliente.toJson(),
      );

      final apiResponse = ApiResponse<Cliente>.fromJson(
        response.data,
        (json) => Cliente.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        await carregarClientes();
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      return false;
    } catch (e) {
      _errorMessage = "Erro inesperado ao criar cliente: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cliente?> atualizarCliente(Cliente cliente) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.put(
        "/clientes/${cliente.id}",
        data: cliente.toJson(),
      );

      final apiResponse = ApiResponse<Cliente>.fromJson(
        response.data,
        (json) => Cliente.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        return apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
        return null;
      }
    } catch (e) {
      _errorMessage = "Erro ao atualizar cliente: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> excluirCliente(int clienteId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Api.loadAuthToken();
      final response = await Api.dio.delete("/clientes/$clienteId");

      if (response.statusCode == 204) {
        _clientes.removeWhere((c) => c.id == clienteId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Erro ao excluir cliente: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void atualizarAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
}
