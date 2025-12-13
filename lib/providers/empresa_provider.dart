import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/dio_error_handler.dart';
import 'package:emprestimos_app/core/storage_service.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/empresa_perfil.dart';
import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/models/resumo_vendedor.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';

import '../core/api.dart';
import '../models/cobranca.dart';

class EmpresaProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _sucessMessage;
  AuthProvider _authProvider;
  ResumoTotalizadoresContasReceber? _resumoCliente;
  Empresa? _empresa;
  EmpresaCompleto? _empresaCompleto;

  String _empresaNome = "Empresa";
  final double _totalEmprestado = 0.0;
  final double _lucroGerado = 0.0;
  final List<Cobranca> _cobrancasPendentes = [];
  final List<int> _lucratividadeMensal = [];

  ResumoTotalizadoresContasReceber? get resumoCliente => _resumoCliente;
  String? get errorMessage => _errorMessage;
  String? get sucessMessage => _sucessMessage;
  bool get isLoading => _isLoading;
  String get empresaNome => _empresaNome;
  double get totalEmprestado => _totalEmprestado;
  double get lucroGerado => _lucroGerado;
  List<Cobranca> get cobrancasPendentes => _cobrancasPendentes;
  List<int> get lucratividadeMensal => _lucratividadeMensal;
  Empresa? get empresa => _empresa;
  EmpresaCompleto? get empresaCompleto => _empresaCompleto;

  EmpresaProvider(this._authProvider);

  String getNomeEmpresa() {
    String nomeEmpresa;
    try {
      nomeEmpresa = _authProvider.loginResponse!.usuario.nome.split(' ')[0];
    } catch (e) {
      nomeEmpresa = "Usuário";
    }
    return nomeEmpresa;
  }

  Future<void> fetchPerfil() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await Api.loadAuthToken();
      final resp = await Api.dio.get('/empresas/me');

      final apiResponse = ApiResponse<EmpresaCompleto>.fromJson(
        resp.data,
        (json) => EmpresaCompleto.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _empresaCompleto = apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (e) {
      _errorMessage = DioErrorHandler.handleDioException(e);
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil da empresa.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> salvar(EmpresaCompleto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await Api.loadAuthToken();
      final resp = await Api.dio.put('/empresas/me', data: dto.toJson());

      final apiResponse = ApiResponse<EmpresaCompleto>.fromJson(
        resp.data,
        (json) => EmpresaCompleto.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _empresaCompleto = apiResponse.data;
        return true;
      }
      _errorMessage = apiResponse.message;
      return false;
    } on DioException catch (e) {
      _errorMessage = DioErrorHandler.handleDioException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao salvar perfil da empresa.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Api.loadAuthToken();
    } on DioException catch (dioErr) {
      debugPrint(
          "Erro ao carregar dashboard: ${dioErr.response?.data ?? dioErr.message}");
    } catch (e) {
      debugPrint("Erro inesperado ao carregar dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarResumoCliente(int cliented) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response =
          await Api.dio.get('/contasreceber/cliente/resumo/$cliented');

      final apiResponse =
          ApiResponse<ResumoTotalizadoresContasReceber>.fromJson(
        response.data,
        (json) => ResumoTotalizadoresContasReceber.fromJson(
            json as Map<String, dynamic>),
      );
      if (apiResponse.sucesso) {
        _resumoCliente = apiResponse.data;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao consutar resumo do vendedor: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrarEmpresa(Empresa empresaDTO) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Api.dio.post('/noauth/empresa', data: empresaDTO);

      final apiResponse = ApiResponse<Empresa>.fromJson(
        response.data,
        (json) => Empresa.fromJson(json as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        _sucessMessage = "Cadastro realizado com sucesso!";
        _empresa = apiResponse.data;
        StorageService.salvarEmpresaIdTemporario(_empresa!.id!);
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Erro ao cadastrar empresa.";
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      _errorMessage = dioErr.response?.data['message'] ?? 'Erro desconhecido';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> vincularAssinaturasGooglePlay({
    required int empresaId,
    required String planoToken,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payload = {
        "empresaId": empresaId,
        "google_play_tokens": {
          "planoToken": planoToken,
        }
      };

      final response = await Api.dio
          .post('/noauth/empresa/vincular-assinatura', data: payload);

      final apiResponse = ApiResponse<Empresa>.fromJson(
        response.data,
        (json) => Empresa.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _sucessMessage = "Assinatura vinculada com sucesso!";
        buscarEmpresaById(empresaId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Erro ao vincular assinatura.";
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      _errorMessage =
          dioErr.response?.data['message'] ?? 'Erro ao vincular assinatura';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> buscarEmpresaById(int? id) async {
    _isLoading = true;
    notifyListeners();

    id ??= _authProvider.loginResponse!.usuario.id;

    await Api.dio.get('/noauth/empresa/$id').then((response) {
      final apiResponse = ApiResponse<Empresa>.fromJson(
        response.data,
        (json) => Empresa.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _empresa = apiResponse.data;
        _empresaNome = _empresa!.responsavel.split(' ')[0];
        notifyListeners();
      } else {
        _errorMessage = apiResponse.message;
      }
    }).catchError((e) {
      _errorMessage = "Erro ao buscar empresa: $e";
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> alterarPlanoEmpresa(Plano plano) async {
    if (_empresa == null) {
      _errorMessage = "Empresa não carregada.";
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    await Api.dio.put('/noauth/empresa/plano', data: {
      "empresaId": _empresa!.id,
      "planoId": plano.id
    }).then((response) {
      final apiResponse = ApiResponse<Empresa>.fromJson(
        response.data,
        (json) => Empresa.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.sucesso) {
        _sucessMessage = "Plano alterado com sucesso!";
        _empresa = apiResponse.data;
        notifyListeners();
      } else {
        _errorMessage = apiResponse.message;
      }
    }).catchError((e) {
      _errorMessage = "Erro ao alterar plano: $e";
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  void atualizarAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
}
