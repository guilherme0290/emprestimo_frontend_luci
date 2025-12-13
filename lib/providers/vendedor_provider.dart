import 'package:emprestimos_app/models/cliente_emprestimo_ativos.dart';
import 'package:emprestimos_app/models/resumo_vendedor.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api.dart';
import '../core/dio_error_handler.dart';
import '../models/vendedor.dart';
import '../models/api_response.dart';

class VendedorProvider with ChangeNotifier {
  List<Vendedor> _vendedores = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _sucessMessage;
  AuthProvider _authProvider;
  ResumoTotalizadoresContasReceber? _resumoVendedor;
  bool esconderValores = true;

  String? get errorMessage => _errorMessage;
  String? get sucessMessage => _sucessMessage;
  List<Vendedor> get vendedores => _vendedores;
  bool get isLoading => _isLoading;
  ResumoTotalizadoresContasReceber? get resumoVendedor => _resumoVendedor;

  VendedorProvider(this._authProvider);

  String getNomeVendedor() {
    String nomeVendedor;
    try {
      nomeVendedor = _authProvider.loginResponse!.usuario.nome.split(' ')[0];
    } catch (e) {
      nomeVendedor = "Usuário";
    }
    return nomeVendedor;
  }

  Future<void> listarVendedores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/vendedores");

      final apiResponse = ApiResponse<List<Vendedor>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((e) => Vendedor.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.sucesso) {
        _vendedores = apiResponse.data!;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao listar vendedores: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> transferirContasReceber({
    required int vendedorDesligadoId,
    required int novoVendedorId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _sucessMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/vendedores/$vendedorDesligadoId/inativar",
        data: {"novoVendedorId": novoVendedorId},
      );

      final apiResponse = ApiResponse<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (apiResponse.sucesso) {
        _sucessMessage = apiResponse.message;
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
      return false;
    } catch (e) {
      _errorMessage = "Erro inesperado ao transferir empréstimos: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buscar um vendedor pelo ID
  Future<Vendedor?> buscarVendedor(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/vendedores/$id");

      final apiResponse = ApiResponse<Vendedor>.fromJson(
        response.data,
        (json) => Vendedor.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        return apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar vendedor: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  /// Criar um novo vendedor
  Future<Vendedor?> criarVendedor(Vendedor vendedor) async {
    _isLoading = true;
    _errorMessage = null;
    _sucessMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post(
        "/vendedores",
        data: vendedor.toJson(),
      );

      final apiResponse = ApiResponse<Vendedor>.fromJson(
        response.data,
        (json) => Vendedor.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _sucessMessage = apiResponse.message;
        await listarVendedores(); // mantém lista atualizada
        return apiResponse.data; // 👈 retorna o vendedor vindo da API
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao criar vendedor: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  /// Atualizar um vendedor existente
  Future<Vendedor?> atualizarVendedor(Vendedor vendedor) async {
    _isLoading = true;
    _errorMessage = null;
    _sucessMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.put(
        "/vendedores/${vendedor.id}",
        data: vendedor.toJson(),
      );

      final apiResponse = ApiResponse<Vendedor>.fromJson(
        response.data,
        (json) => Vendedor.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _sucessMessage = apiResponse.message;
        await listarVendedores();
        return apiResponse.data; // 👈 vendedor atualizado vindo da API
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao atualizar vendedor: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  /// Excluir um vendedor
  Future<bool> excluirVendedor(int vendedorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.delete("/vendedores/$vendedorId");

      final apiResponse = ApiResponse<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (apiResponse.sucesso) {
        await listarVendedores();
        return true;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao excluir vendedor: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<ClientesContasReceberAtivos?> consultarVinculosVendedor(
      int vendedorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await Api.dio.get("/vendedores/$vendedorId/vinculos-ativos");

      final apiResponse = ApiResponse<ClientesContasReceberAtivos>.fromJson(
        response.data,
        (json) =>
            ClientesContasReceberAtivos.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso == false) {
        _errorMessage = apiResponse.message;
        return null;
      }

      return apiResponse.data;
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao consultar vínculos: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  void atualizarAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
}
