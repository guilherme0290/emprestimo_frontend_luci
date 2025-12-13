import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/api.dart';
import 'package:emprestimos_app/core/auth_status.dart';
import 'package:emprestimos_app/core/storage_service.dart';
import 'package:emprestimos_app/models/api_response.dart';
import 'package:emprestimos_app/models/login_response.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../core/role.dart';

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.carregando;
  Role _role = Role.EMPRESA;

  Role get role => _role;
  AuthStatus get status => _status;
  LoginResponse? _loginResponse;
  get loginReturn => _loginResponse;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LoginResponse? get loginResponse => _loginResponse;

  Future<ApiResponse<LoginResponse>> login(String email, String senha) async {
    _isLoading = true;
    _errorMessage = null;
    String? token;
    notifyListeners();
    if (!kIsWeb) {
      token = await FirebaseMessaging.instance.getToken();
    }

    try {
      final response = await Api.dio.post("/auth/login", data: {
        "email": email.toLowerCase(),
        "senha": senha,
        "firebaseToken": token,
      });

      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.sucesso) {
        _errorMessage = apiResponse.message;
        _status = AuthStatus.naoAutenticado;
      } else {
        _status = AuthStatus.autenticado;
        _loginResponse = apiResponse.data!;
        await _salvarDadosNoStorage(_loginResponse!);
        await carregarRole();
      }
      notifyListeners();
      return apiResponse;
    } on DioException catch (dioErr) {
      _errorMessage = dioErr.response?.data["message"] ?? "Erro desconhecido.";
      return ApiResponse(sucesso: false, message: _errorMessage!, data: null);
    } catch (e) {
      _errorMessage = "Erro inesperado ao fazer login.";
      return ApiResponse(sucesso: false, message: _errorMessage!, data: null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _salvarDadosNoStorage(LoginResponse loginResponse) async {
    await StorageService.saveToken(loginResponse.token);
    await StorageService.saveLoginResponse(jsonEncode(loginResponse.toJson()));
    Api.setAuthToken(loginResponse.token);
    _loginResponse = loginResponse;
    _status = AuthStatus.autenticado;
    notifyListeners();
  }

  Future<void> carregarDadosSalvos() async {
    final dados = await StorageService.getLoginResponse();
    if (dados != null) {
      _loginResponse = LoginResponse.fromJson(jsonDecode(dados));
    }
    notifyListeners();
  }

  Future<bool> refreshToken() async {
    try {
      final response = await Api.dio.get("/auth/refresh");

      if (response.statusCode == 200) {
        _status = AuthStatus.autenticado;
        await carregarDadosSalvos();
      } else {
        _status = AuthStatus.naoAutenticado;
      }
      return _status == AuthStatus.autenticado;
    } on DioException catch (e) {
      if (kDebugMode) {
        print("❌ Erro no refreshToken: ${e.response?.statusCode} ${e.message}");
      }
      _status = AuthStatus.naoAutenticado;
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erro inesperado no refreshToken: $e");
      }
      _status = AuthStatus.naoAutenticado;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<ApiResponse<void>> alterarSenha(String email, String novaSenha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.post("/noauth/alterar-senha", data: {
        "email": email,
        "senha": novaSenha,
      });

      final apiResponse = ApiResponse<void>.fromJson(response.data, (_) {});

      if (!apiResponse.sucesso) {
        _errorMessage = apiResponse.message;
      }

      return apiResponse;
    } on DioException catch (dioErr) {
      _errorMessage = dioErr.response?.data["message"] ?? "Erro desconhecido.";
      return ApiResponse(sucesso: false, message: _errorMessage!, data: null);
    } catch (e) {
      _errorMessage = "Erro inesperado ao alterar a senha.";
      return ApiResponse(sucesso: false, message: _errorMessage!, data: null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) return null;

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     UserCredential userCredential =
  //         await _firebaseAuth.signInWithCredential(credential);
  //     return userCredential.user;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static Future<Role> obterRoleUsuario() async {
    final token = await StorageService.getToken();
    if (token == null) return Role.EMPRESA;

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return Role.fromString(decodedToken["role"]);
  }

  Future<void> carregarRole() async {
    _role = await obterRoleUsuario();
    notifyListeners();
  }

  bool podeAcessarClientes() => _role == Role.EMPRESA;
  bool podeAcessarContasReceber() =>
      _role == Role.EMPRESA || _role == Role.VENDEDOR;

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Api.dio.post("/auth/logout");
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao chamar API de logout: $e');
      }
    } finally {
      try {
        StorageService.clearAll();
        clearAuthToken();

        _loginResponse = null;
        _status = AuthStatus.naoAutenticado;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Erro ao limpar storage local: $e');
        }
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearAuthToken() {
    Api.dio.options.headers.remove("Authorization");
  }

  Future<ApiResponse<void>> solicitarRecuperacaoSenha(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api.dio.post("/noauth/recuperar-senha", data: {
        "email": email,
      });

      final apiResponse = ApiResponse<void>.fromJson(response.data, (_) {});

      if (!apiResponse.sucesso) {
        _errorMessage = apiResponse.message;
      }

      return apiResponse;
    } on DioException catch (dioErr) {
      final responseData = dioErr.response?.data;

      _errorMessage =
          responseData?["erro"] ?? "Erro desconhecido."; // CORREÇÃO AQUI

      return ApiResponse(sucesso: false, message: _errorMessage!, data: null);
    } catch (e) {
      _errorMessage = "Erro inesperado ao solicitar recuperação de senha.";
      return ApiResponse(sucesso: false, message: _errorMessage!, data: null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
