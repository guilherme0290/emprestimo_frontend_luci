import 'package:dio/dio.dart';
import '../models/relatorio.dart';
import '../core/api.dart';

class RelatorioService {
  static Future<Relatorio> buscarRelatorio() async {
    try {
      Response response = await Api.dio.get("/relatorio");
      return Relatorio.fromJson(response.data);
    } catch (e) {
      throw Exception("Erro ao carregar relatório");
    }
  }
}
