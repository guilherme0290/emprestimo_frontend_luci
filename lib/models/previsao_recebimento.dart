import 'package:flutter/material.dart';

class PrevisaoRecebimento {
  final String titulo;
  final double valor;
  final double valorAtrasado;
  final Color cor;

  PrevisaoRecebimento({
    required this.titulo,
    required this.valor,
    required this.valorAtrasado,
    required this.cor,
  });

  factory PrevisaoRecebimento.fromJson(Map<String, dynamic> json) {
    return PrevisaoRecebimento(
      titulo: json['titulo'],
      valor: (json['valor'] as num).toDouble(),
      valorAtrasado: (json['valorAtrasado'] ?? 0).toDouble(),
      cor: _definirCor(json['titulo']),
    );
  }

  static Color _definirCor(String titulo) {
    switch (titulo.toLowerCase()) {
      case "hoje":
        return Colors.teal;
      case "7 dias":
        return Colors.orange;
      case "15 dias":
        return Colors.deepPurple;
      case "30 dias":
        return Colors.indigo;
      case "personalizado":
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}
