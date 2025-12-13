import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/caixa.dart';
import 'package:flutter/material.dart';

class CaixaProvider with ChangeNotifier {
  List<Caixa> _caixas = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<Caixa> get caixas => _caixas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> listarCaixas() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get("/caixa/empresa");
      final apiResponse = ApiResponse<List<Caixa>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List)
            .map((e) => Caixa.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (apiResponse.sucesso) {
        _caixas = apiResponse.data!;
      } else {
        _errorMessage = apiResponse.message;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar caixas: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editarCaixa(Caixa caixa) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Api.loadAuthToken();
      final response =
          await Api.dio.put("/caixa/${caixa.id}", data: caixa.toJson());
      final apiResponse = ApiResponse<Caixa>.fromJson(
          response.data, (json) => Caixa.fromJson(json));
      if (apiResponse.sucesso) {
        int index = _caixas.indexWhere((c) => c.id == caixa.id);
        if (index != -1) _caixas[index] = apiResponse.data!;
        _successMessage = apiResponse.message;
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } catch (e) {
      _errorMessage = "Erro ao editar caixa: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> abrirCaixa(Caixa caixa) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post("/caixa/abrir", data: caixa.toJson());
      final apiResponse = ApiResponse<Caixa>.fromJson(
          response.data, (json) => Caixa.fromJson(json));
      if (apiResponse.sucesso) {
        _caixas.add(apiResponse.data!);
        _successMessage = apiResponse.message;
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } catch (e) {
      _errorMessage = "Erro ao abrir caixa: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fecharCaixa(int caixaId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Api.loadAuthToken();
      final response = await Api.dio.post("/caixa/$caixaId/fechar");
      final apiResponse = ApiResponse<Caixa>.fromJson(
          response.data, (json) => Caixa.fromJson(json));
      if (apiResponse.sucesso) {
        int index = _caixas.indexWhere((c) => c.id == caixaId);
        if (index != -1) _caixas[index] = apiResponse.data!;
        _successMessage = apiResponse.message;
        return true;
      } else {
        _errorMessage = apiResponse.message;
        return false;
      }
    } catch (e) {
      _errorMessage = "Erro ao fechar caixa: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
