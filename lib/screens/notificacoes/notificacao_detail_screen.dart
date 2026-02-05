import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/notificacao.dart';
import 'package:emprestimos_app/providers/notificacoes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificacaoDetailScreen extends StatefulWidget {
  final Notificacao notificacao;

  const NotificacaoDetailScreen({super.key, required this.notificacao});

  @override
  State<NotificacaoDetailScreen> createState() =>
      _NotificacaoDetailScreenState();
}

class _NotificacaoDetailScreenState extends State<NotificacaoDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!widget.notificacao.visualizado) {
        await Provider.of<NotificacaoProvider>(context, listen: false)
            .marcarComoVisualizada(widget.notificacao.id);
      }
    });
  }

  String _imagemParaTipo(String? tipo) {
    switch (tipo) {
      case "BAIXA_PARCELA":
      case "NOVO_EMPRESTIMO":
      case "PARCELAS_VENCEM_HOJE":
      case "PARCELAS_EM_ATRASO":
        return "assets/img/money_background.png";
      case "SEM_CLIENTES":
      case "SEM_CONTAS_RECEBER":
        return "assets/img/cliente_sem_emprestimo.png";
      default:
        return "assets/img/background.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagem = _imagemParaTipo(widget.notificacao.tipo);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhe da notificacao"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.asset(
                  imagem,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryColor.withOpacity(0.75),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Text(
                    widget.notificacao.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.notificacao.mensagem,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
