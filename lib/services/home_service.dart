import 'package:dio/dio.dart';
import '../models/resumo_financeiro.dart';
import '../core/api.dart';

class HomeService {
  static Future<ResumoFinanceiro> buscarResumoFinanceiro() async {
    try {
      Response response = await Api.dio.get("/api/home/resumo");
      return ResumoFinanceiro.fromJson(response.data);
    } catch (e) {
      throw Exception("Erro ao carregar resumo financeiro");
    }
  }
}
