import 'dart:convert';

class Parametro {
  final int? id;
  final String chave;
  final String valor;
  final String tipoReferencia;
  final int referenciaId;
  final Object? valorConvertido;
  bool isPendente = false;

  Parametro({
    this.id,
    required this.chave,
    required this.valor,
    required this.tipoReferencia,
    required this.referenciaId,
    this.valorConvertido,
    this.isPendente = false,
  });

  factory Parametro.fromJson(Map<String, dynamic> json) {
    return Parametro(
      id: json['id'],
      chave: (json['chave'] ?? '').toString(),
      valor: json['valor'] == null ? '' : json['valor'].toString(),
      tipoReferencia: (json['tipoReferencia'] ?? '').toString(),
      referenciaId: json['referenciaId'] == null
          ? 0
          : (json['referenciaId'] as num).toInt(),
      valorConvertido: json['valorConvertido'],
      isPendente: json['pendente'] ?? false,
    );
  }

  static List<Parametro> fromJsonList(String responseBody) {
    final List<dynamic> parsed = jsonDecode(responseBody);
    return parsed.map((json) => Parametro.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chave': chave,
      'valor': valor,
      'tipoReferencia': tipoReferencia,
      'referenciaId': referenciaId,
    };
  }
}
