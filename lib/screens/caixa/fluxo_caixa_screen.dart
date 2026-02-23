import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/label_titulo.dart';
import 'package:emprestimos_app/widgets/resumo_trasacoes.dart';
import 'package:flutter/material.dart';

class FluxoCaixaScreen extends StatelessWidget {
  const FluxoCaixaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluxo de Caixa'),
      ),
      body: AppBackground(
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelTitulo(titulo: '📄 Transações'),
                    SizedBox(height: 12),
                    TransacoesResumoCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
