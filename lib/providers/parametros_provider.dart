import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/aprovacao_parametro.dart';
import 'package:emprestimos_app/models/autorizacao_parametro.dart';
import 'package:emprestimos_app/models/parametro.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class ParametroProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Parametro> _parametrosCliente = [];
  List<Parametro> _parametrosEmpresa = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Parametro> get parametrosCliente => _parametrosCliente;
  List<Parametro> get parametrosEmpresa => _parametrosEmpresa;

  AuthProvider _authProvider;

  ParametroProvider(this._authProvider);

  int getEmpresaId() {
    return _authProvider.loginResponse!.usuario.id;
  }

  Future<void> buscarParametrosCliente(int clienteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.get("/parametros/cliente/$clienteId");

      final apiResponse = ApiResponse<List<Parametro>>.fromJson(
        response.data,
        (jsonList) =>
            (jsonList as List).map((json) => Parametro.fromJson(json)).toList(),
      );

      if (apiResponse.sucesso) {
        _parametrosCliente = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar parâmetros.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarParametrosEmpresa() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    String empresaId;
    if ('EMPRESA' == _authProvider.loginResponse!.role) {
      empresaId = _authProvider.loginResponse!.usuario.id.toString();
    } else {
      empresaId = _authProvider.loginResponse!.usuario.empresaId.toString();
    }

    try {
      final response = await Api.dio.get("/parametros/empresa/$empresaId");

      final apiResponse = ApiResponse<List<Parametro>>.fromJson(
        response.data,
        (jsonList) =>
            (jsonList as List).map((json) => Parametro.fromJson(json)).toList(),
      );

      if (apiResponse.sucesso) {
        _parametrosEmpresa = apiResponse.data ?? [];
      } else {
        _errorMessage = apiResponse.message;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar parâmetros.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarParametro(Parametro parametro) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await Api.dio
          .put("/parametros/${parametro.id}", data: parametro.toJson());
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Erro ao atualizar parâmetro.";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getValorParametroPrioritario(
      String chaveCliente, String chaveEmpresa) {
    final clienteParam = parametrosCliente.firstWhere(
      (p) => p.chave == chaveCliente && p.valor.isNotEmpty && p.valor != '0',
      orElse: () => Parametro(
        valor: '',
        chave: '',
        id: 0,
        referenciaId: 0,
        tipoReferencia: '',
      ),
    );

    if (clienteParam.valor.isNotEmpty && clienteParam.valor != '0') {
      return clienteParam.valor;
    }

    final empresaParam = parametrosEmpresa.firstWhere(
      (p) => p.chave == chaveEmpresa && p.valor.isNotEmpty,
      orElse: () => Parametro(
        valor: '',
        chave: '',
        id: 0,
        referenciaId: 0,
        tipoReferencia: '',
      ),
    );

    return empresaParam.valor;
  }

  Future<bool> solicitarAprovacao(
      {required int parametroId,
      required String novoValor,
      required int usuarioId,
      required int clienteId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = AutorizacaoParametro(
        parametroId: parametroId,
        novoValor: novoValor,
        usuarioId: usuarioId,
        clienteId: clienteId,
      );

      final response = await Api.dio.post(
        "/aprovacoes-parametros/solicitar",
        data: request.toJson(),
      );

      return response.statusCode == 202;
    } catch (e) {
      _errorMessage = "Erro ao solicitar aprovação de parâmetro.";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> aprovarParametro({
    required int aprovacaoId,
    required int aprovadorId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.post(
        "/aprovacoes-parametros/aprovar",
        queryParameters: {
          "aprovacaoId": aprovacaoId,
          "aprovadorId": aprovadorId,
        },
      );

      return response.statusCode == 202;
    } catch (e) {
      _errorMessage = "Erro ao aprovar parâmetro.";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reprovarParametro({
    required int aprovacaoId,
    required int aprovadorId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.post(
        "/aprovacoes-parametros/reprovar",
        queryParameters: {
          "aprovacaoId": aprovacaoId,
          "aprovadorId": aprovadorId,
        },
      );

      return response.statusCode == 202;
    } catch (e) {
      _errorMessage = "Erro ao reprovar parâmetro.";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Parametro? buscarParametroPorChave(String chave) {
    try {
      return _parametrosCliente.firstWhere((p) => p.chave == chave);
    } catch (e) {
      return null;
    }
  }

  Parametro? buscarParametroEmpresaChave(String chave) {
    try {
      return _parametrosEmpresa.firstWhere((p) => p.chave == chave);
    } catch (e) {
      return null;
    }
  }

  bool podeCriarNovoContasReceber(int emprestimosEmAberto) {
    final clienteParam = buscarParametroPorChave("LIMITE_EMPRESTIMO_CLIENTE");
    final empresaParam =
        buscarParametroEmpresaChave("LIMITE_EMPRESTIMO_CLIENTE");

    final clienteValor = int.tryParse(clienteParam?.valor ?? "");
    final empresaValor = int.tryParse(empresaParam?.valor ?? "");

    final limite = (clienteValor != null && clienteValor > 0)
        ? clienteValor
        : (empresaValor ?? 0);

    if (limite == 0) return true; // sem limite configurado = pode criar

    return emprestimosEmAberto < limite;
  }

  Future<List<AprovacaoParametro>> buscarPendentes() async {
    try {
      final response = await Api.dio.get("/aprovacoes-parametros/pendentes");

      final apiResponse = ApiResponse<List<AprovacaoParametro>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((json) => AprovacaoParametro.fromJson(json))
            .toList(),
      );

      if (apiResponse.sucesso) {
        return apiResponse.data ?? [];
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      print("Erro ao buscar aprovações pendentes: $e");
      return [];
    }
  }

  Future<bool> aprovar({
    required int aprovacaoId,
  }) async {
    try {
      String empresaId = _authProvider.loginResponse!.usuario.id.toString();

      final response = await Api.dio.post(
        "/aprovacoes-parametros/aprovar",
        queryParameters: {
          "aprovacaoId": aprovacaoId,
          "aprovadorId": empresaId,
        },
      );

      return response.statusCode == 202;
    } catch (e) {
      print("Erro ao aprovar parâmetro: $e");
      return false;
    }
  }

  Future<bool> reprovar({
    required int aprovacaoId,
  }) async {
    try {
      String empresaId = _authProvider.loginResponse!.usuario.id.toString();

      final response = await Api.dio.post(
        "/aprovacoes-parametros/reprovar",
        queryParameters: {
          "aprovacaoId": aprovacaoId,
          "aprovadorId": empresaId,
          "motivo": "",
        },
      );

      return response.statusCode == 202;
    } catch (e) {
      print("Erro ao reprovar parâmetro: $e");
      return false;
    }
  }

  void atualizarAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
}
