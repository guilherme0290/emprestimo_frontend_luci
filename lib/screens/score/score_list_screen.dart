import 'package:emprestimos_app/providers/score_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HistoricoScoreScreen extends StatefulWidget {
  final int clienteId;

  const HistoricoScoreScreen({super.key, required this.clienteId});

  @override
  State<HistoricoScoreScreen> createState() => _HistoricoScoreScreenState();
}

class _HistoricoScoreScreenState extends State<HistoricoScoreScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ClienteScoreProvider>(context, listen: false)
          .buscarHistoricoScore(widget.clienteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico de Score")),
      body: Consumer<ClienteScoreProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.historicoScore.isEmpty) {
            return Center(
              child: Lottie.asset(
                'assets/img/no-results.json',
                height: 180,
                repeat: true,
              ),
            );
          }

          return AppBackground(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.historicoScore.length,
              itemBuilder: (context, index) {
                final historico = provider.historicoScore[index];
                Color scoreColor =
                    historico.variacao >= 0 ? Colors.green : Colors.red;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      historico.variacao >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: scoreColor,
                    ),
                    title: Text(
                      historico.motivo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${historico.variacao} pontos",
                      style: TextStyle(color: scoreColor),
                    ),
                    trailing: Text(
                      "${historico.createdAt.day}/${historico.createdAt.month}/${historico.createdAt.year}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
