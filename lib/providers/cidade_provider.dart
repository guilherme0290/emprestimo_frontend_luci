import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/core/dio_error_handler.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/cidade.dart';
import 'package:flutter/material.dart';

class CidadeProvider extends ChangeNotifier {
  List<Cidade> _cidades = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _messageSucess;

  List<Cidade> get cidades => _cidades;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get messageSucess => _messageSucess;

  Future<void> carregarCidades() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await Api.dio.get("/noauth/cidade");

      if (response.statusCode == 200) {
        _cidades = (response.data as List)
            .map((json) => Cidade.fromJson(json))
            .toList();
        _errorMessage = null;
      } else {
        _errorMessage = "Erro ao carregar cidades";
      }
    } catch (e) {
      print("Erro ao carregar cidades: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> buscarCidadesPorUf(String uf) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get('/noauth/cidade/uf/$uf');

      final apiResponse = ApiResponse<List<Cidade>>.fromJson(
        response.data,
        (jsonList) =>
            (jsonList as List).map((e) => Cidade.fromJson(e)).toList(),
      );

      if (apiResponse.sucesso) {
        _cidades = apiResponse.data!;
        _messageSucess = apiResponse.message;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar cidades: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cidade?> buscarCidadesById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Api.loadAuthToken();
      final response = await Api.dio.get('/noauth/cidade/id/$id');

      final apiResponse = ApiResponse<Cidade>.fromJson(
        response.data,
        (json) => Cidade.fromJson(json),
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
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar cidade: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
