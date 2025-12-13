import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/core/dio_error_handler.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/planos.dart';
import 'package:flutter/material.dart';

class PlanoProvider with ChangeNotifier {
  List<Plano> _planos = [];
  bool _isLoading = false;
  String? _errorMessage;
  Plano? _planoSelecionado;

  List<Plano> get planos => _planos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Plano? get planoSelecionado => _planoSelecionado;

  Future<bool> fetchPlanos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.get('/planos');

      final apiResponse = ApiResponse<List<Plano>>.fromJson(
        response.data,
        (jsonList) => (jsonList as List<dynamic>)
            .map((e) => Plano.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (apiResponse.sucesso) {
        _planos = apiResponse.data ?? [];
        return true;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar planos: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<void> getPlanoByEmpresaId(int i)async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Api.dio.get('/noauth/plano/empresa/$i');

      final apiResponse = ApiResponse<Plano>.fromJson(
        response.data,
        (json) => Plano.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.sucesso) {
        _planoSelecionado = apiResponse.data!;
      } else {
        _errorMessage = apiResponse.message;
      }
    } on DioException catch (dioErr) {
      _errorMessage = DioErrorHandler.handleDioException(dioErr);
    } catch (e) {
      _errorMessage = "Erro inesperado ao buscar planos: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }


  }
}
