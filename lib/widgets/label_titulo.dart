import 'package:flutter/material.dart';

class LabelTitulo extends StatelessWidget {
  final String titulo;

  LabelTitulo({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black54, // Cor cinza suave
        ),
      ),
    );
  }
}
