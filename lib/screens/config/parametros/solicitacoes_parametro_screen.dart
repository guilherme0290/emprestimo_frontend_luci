import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/screens/planos/escolher_planos.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:emprestimos_app/models/aprovacao_parametro.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SolicitacoesParametrosScreen extends StatefulWidget {
  const SolicitacoesParametrosScreen({super.key});

  @override
  State<SolicitacoesParametrosScreen> createState() =>
      _SolicitacoesParametrosScreenState();
}

class _SolicitacoesParametrosScreenState
    extends State<SolicitacoesParametrosScreen> {
  List<AprovacaoParametro> _pendentes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarPendentes();
  }

  Future<void> _carregarPendentes() async {
    final provider = Provider.of<ParametroProvider>(context, listen: false);
    final pendentes = await provider.buscarPendentes();
    setState(() {
      _pendentes = pendentes;
      _loading = false;
    });
  }

  Future<void> _responderAprovacao(int id, bool aprovado) async {
    final provider = Provider.of<ParametroProvider>(context, listen: false);

    final bool sucesso;
    if (aprovado) {
      sucesso = await provider.aprovar(aprovacaoId: id);
    } else {
      sucesso = await provider.reprovar(aprovacaoId: id);
    }

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Solicitação ${aprovado ? 'aprovada' : 'reprovada'}"),
          backgroundColor: Colors.green,
        ),
      );
      _carregarPendentes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao responder solicitação"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresa = Provider.of<EmpresaProvider>(context).empresa;
    final possuiModuloVendedor =
        empresa?.plano?.nome.toUpperCase().contains("PREMIUM") ?? false;

    if (!possuiModuloVendedor) {
      return Scaffold(
        appBar: AppBar(title: const Text("Solicitações Pendentes")),
        body: AppBackground(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.yellow[50],
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 48, color: Colors.orange),
                    const SizedBox(height: 12),
                    const Text(
                      "Funcionalidade exclusiva do módulo Premium",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Aqui você poderá aprovar ou reprovar solicitações feitas pelos seus vendedores.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Exemplos de solicitações:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• Aumento do limite de crédito do cliente"),
                          Text(
                              "• Alteração da porcentagem de juros para um cliente específico"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Para ativar esse recurso, assine o plano Premium",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    ElevatedButton(
                      child: const Text("Ver planos"),
                      onPressed: () {
                        Navigator.of(context).pop(); // fecha o diálogo
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EscolherPlanoScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Solicitações Pendentes")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pendentes.isEmpty
              ? Center(
                  child: Lottie.asset(
                    'assets/img/no-results.json',
                    height: 180,
                    repeat: true,
                  ),
                )
              : AppBackground(
                  child: ListView.builder(
                    itemCount: _pendentes.length,
                    itemBuilder: (context, index) {
                      final item = _pendentes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("🧾 Parâmetro: ${item.chave}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("👤 Cliente: ${item.nomeCliente}"),
                              Text("📩 Solicitante: ${item.nomeSolicitante}"),
                              Text("📅 Solicitado em: ${item.dataSolicitacao}"),
                              Text("🔁 Valor Anterior: ${item.valorAnterior}"),
                              Text(
                                  "📌 Valor Solicitado: ${item.valorSolicitado}"),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _responderAprovacao(
                                        item.aprovacaoId, false),
                                    icon: const Icon(Icons.close),
                                    label: const Text("Não Aprovar"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => _responderAprovacao(
                                        item.aprovacaoId, true),
                                    icon: const Icon(Icons.check),
                                    label: const Text("Aprovar"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
