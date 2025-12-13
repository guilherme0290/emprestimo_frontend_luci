import 'package:emprestimos_app/providers/notificacoes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotificacaoProvider>(context, listen: false)
        .buscarNotificacoes();
  }

  @override
  Widget build(BuildContext context) {
    final notificacaoProvider = Provider.of<NotificacaoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificações"),
      ),
      body: notificacaoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificacaoProvider.errorMessage != null
              ? Center(child: Text(notificacaoProvider.errorMessage!))
              : ListView.builder(
                  itemCount: notificacaoProvider.notificacoes.length,
                  itemBuilder: (context, index) {
                    final notificacao = notificacaoProvider.notificacoes[index];
                    return ListTile(
                      title: Text(
                        notificacao.titulo,
                        style: TextStyle(
                          fontWeight: notificacao.visualizado
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notificacao.mensagem),
                      leading: notificacao.visualizado
                          ? const Icon(Icons.notifications_none)
                          : const Icon(Icons.notifications_active,
                              color: Colors.blue),
                    );
                  },
                ),
    );
  }
}
