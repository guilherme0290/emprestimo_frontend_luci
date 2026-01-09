import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emprestimos_app/core/navigation_service.dart';
import 'package:emprestimos_app/core/storage_service.dart';

class Api {
  static String urlProducao = "https://app.souzacomerciobr.com.br/api";
  static String urlHomologacao = "http://192.168.100.118:8080/api";

  static bool _interceptorAdicionado = false;
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: urlProducao, // Alterar para o IP do servidor
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
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            final context = navigatorKey.currentContext;

            if (context != null) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //       content: Text("Sessão expirada.")),
              // );

              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
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

  static Dio get dio {
    if (!_interceptorAdicionado) {
      addInterceptor();
      _interceptorAdicionado = true;
    }
    return _dio;
  }
}
