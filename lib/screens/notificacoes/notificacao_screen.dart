import 'package:emprestimos_app/providers/notificacoes_provider.dart';
import 'package:flutter/material.dart';
import 'package:emprestimos_app/screens/notificacoes/notificacao_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<NotificacaoProvider>(context, listen: false)
        .buscarNotificacoes(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<NotificacaoProvider>(context, listen: false);
    if (!provider.hasMore || provider.isLoadingMore) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.buscarNotificacoes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificacaoProvider = Provider.of<NotificacaoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificações"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Marcar todas como lidas",
            onPressed: () {
              notificacaoProvider.marcarTodasComoVisualizadas();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notificacaoProvider.buscarNotificacoes(reset: true),
        child: notificacaoProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notificacaoProvider.errorMessage != null
                ? Center(child: Text(notificacaoProvider.errorMessage!))
                : notificacaoProvider.notificacoes.isEmpty
                    ? Center(
                        child: Lottie.asset(
                          'assets/img/no-results.json',
                          height: 180,
                          repeat: true,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: notificacaoProvider.notificacoes.length +
                            (notificacaoProvider.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >=
                              notificacaoProvider.notificacoes.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final notificacao =
                              notificacaoProvider.notificacoes[index];
                      final dataEnvio = notificacao.dataEnvio != null
                          ? DateFormat("dd/MM/yyyy HH:mm")
                              .format(notificacao.dataEnvio!)
                          : "";
                      return ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificacaoDetailScreen(
                                notificacao: notificacao,
                              ),
                            ),
                          );
                        },
                        title: Text(
                          notificacao.titulo,
                          style: TextStyle(
                            fontWeight: notificacao.visualizado
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notificacao.mensagem),
                            if (dataEnvio.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  dataEnvio,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        leading: notificacao.visualizado
                            ? const Icon(Icons.notifications_none)
                            : const Icon(Icons.notifications_active,
                                color: Colors.blue),
                          );
                        },
                      ),
      ),
    );
  }
}
