import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class BannerAvisoAtivacao extends StatefulWidget {
  final VoidCallback onAtivarPlano;
  final DateTime createdAt;

  const BannerAvisoAtivacao({
    super.key,
    required this.onAtivarPlano,
    required this.createdAt,
  });

  @override
  State<BannerAvisoAtivacao> createState() => _BannerAvisoAtivacaoState();
}

class _BannerAvisoAtivacaoState extends State<BannerAvisoAtivacao> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final diasRestantes =
        7 - DateTime.now().difference(widget.createdAt).inDays;

    final mensagemExpandida = diasRestantes > 0
        ? "🎁 Você está aproveitando o período gratuito de 7 dias!\n"
            "⏳ Ainda restam $diasRestantes dia${diasRestantes == 1 ? '' : 's'} de testes.\n\n"
            "🔐 Para continuar usando todos os recursos sem interrupções, ative seu plano agora mesmo."
        : "⚠️ Seu período de testes gratuito terminou.\n\n"
            "Para evitar a perda de acesso, ative seu plano o quanto antes.";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Plano ainda não ativado",
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _expandido ? Icons.expand_less : Icons.expand_more,
                  color: Colors.red.shade800,
                ),
                onPressed: () {
                  setState(() {
                    _expandido = !_expandido;
                  });
                },
              )
            ],
          ),
          if (_expandido) ...[
            const SizedBox(height: 8),
            Text(
              mensagemExpandida,
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onAtivarPlano,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text("Ativar agora"),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
