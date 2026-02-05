import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/navigation_service.dart';
import 'package:emprestimos_app/core/storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Api {
  static String urlProducao = "https://app.souzacomerciobr.com.br/api";
  static String urlHomologacao = "http://192.168.100.118:8080/api";

  static bool _interceptorAdicionado = false;
  static Future<bool>? _refreshingFuture;
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: urlHomologacao, // Alterar para o IP do servidor
      connectTimeout: const Duration(seconds: 1000),
      receiveTimeout: const Duration(seconds: 1000),
    ),
  );

  static Future<void> setAuthToken(String token) async {
    _dio.options.headers["Authorization"] = token;
    await StorageService.saveToken(token);
  }

  static Future<void> loadAuthToken() async {
    String? token = await StorageService.getToken();
    if (token != null) {
      _dio.options.headers["Authorization"] = token;
    }
  }

  static Future<bool> refreshAuthToken() async {
    if (_refreshingFuture != null) {
      return _refreshingFuture!;
    }
    _refreshingFuture = _doRefreshToken();
    final result = await _refreshingFuture!;
    _refreshingFuture = null;
    return result;
  }

  static Future<bool> _doRefreshToken() async {
    final refreshToken = await StorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post(
        "/auth/refresh",
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data["sucesso"] == true) {
        final data = response.data["data"] as Map<String, dynamic>;
        final token = data["token"]?.toString();
        final newRefresh = data["refreshToken"]?.toString();
        if (token == null || token.isEmpty) {
          return false;
        }
        await StorageService.saveToken(token);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await StorageService.saveRefreshToken(newRefresh);
        }
        await StorageService.saveLoginResponse(jsonEncode(data));
        _dio.options.headers["Authorization"] = token;
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Adicionando Interceptor para garantir que o token esteja sempre presente
  static void addInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await StorageService.getToken();

          if (token != null &&
              !options.path.contains('/login') &&
              !options.path.contains('/recuperar-senha') &&
              !options.path.contains('/planos') &&
              !options.path.contains('/noauth')) {
            options.headers["Authorization"] = token;
          }

          if (options.method != 'GET' && options.data != null) {
            options.headers["Content-Type"] = "application/json";
          }

          print(
              "🔹 Requisição para: ${options.method} ${options.baseUrl}${options.path}");
          print("📌 Headers: ${options.headers}");
          print("📨 Body: ${jsonEncode(options.data)}");
          if (options.queryParameters.isNotEmpty) {
            print("❓ QueryParams: ${options.queryParameters}");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("✅ Resposta recebida [${response.statusCode}]");

          if (response.data is Map || response.data is List) {
            print("📦 Conteúdo: ${response.data}");
          } else {
            print(
                "⚠️ Tipo de resposta inesperado: ${response.data.runtimeType}");
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final alreadyRetried = e.requestOptions.extra["__retry"] == true;
            if (!alreadyRetried) {
              final refreshed = await refreshAuthToken();
              if (refreshed) {
                final opts = e.requestOptions;
                opts.extra["__retry"] = true;
                opts.headers["Authorization"] =
                    _dio.options.headers["Authorization"];
                try {
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                } catch (_) {}
              }
            }
            await _handleUnauthorized();
          }

          try {
            print("❌ Erro na requisição: ${e.message}");
          } catch (err) {
            print("❌ Erro na requisição (não pôde acessar e.message): $err");
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<void> _handleUnauthorized() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return;
    final rawToken = token.replaceFirst('Bearer ', '');
    if (!JwtDecoder.isExpired(rawToken)) {
      // Token ainda é válido localmente: evita forçar logout
      return;
    }

    final context = navigatorKey.currentContext;
    if (context != null) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  static Dio get dio {
    if (!_interceptorAdicionado) {
      addInterceptor();
      _interceptorAdicionado = true;
    }
    return _dio;
  }
}
