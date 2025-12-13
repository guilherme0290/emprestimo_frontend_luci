import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/screens/config/caixas/caixa_form_screen.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/caixa_provider.dart';

class CaixaListScreen extends StatefulWidget {
  const CaixaListScreen({super.key});

  @override
  State<CaixaListScreen> createState() => _CaixaListScreenState();
}

class _CaixaListScreenState extends State<CaixaListScreen> {
  bool _isLoading = true;
  final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CaixaProvider>(context, listen: false)
          .listarCaixas()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar caixas: $error')),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaixaProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Responsaveis')),
      floatingActionButton: CustomFloatingActionButton(
        heroTag: "novo_caixa_fab",
        onPressed: () {
          final result = Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CaixaFormScreen()),
          );

          result.then((value) {
            if (value != null && value is bool && value) {
              setState(() => _isLoading = true);
              Provider.of<CaixaProvider>(context, listen: false).listarCaixas();
              setState(() => _isLoading = false);
            }
          });
        },
        icon: Icons.add,
        label: "Novo Responsavel",
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : AppBackground(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.caixas.length,
                itemBuilder: (context, index) {
                  final caixa = provider.caixas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.account_balance_wallet,
                            color: AppTheme.primaryColor),
                      ),
                      title: Text(
                        caixa.descricao,
                        style: AppTheme.titleStyle
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                caixa.status == 'ATIVO'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: caixa.status == 'ATIVO'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Status: ${caixa.status ?? 'Indefinido'}',
                                style: TextStyle(
                                  color: caixa.status == 'ATIVO'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Inicial: ${formatador.format(caixa.valorInicial)}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing:
                          const Icon(Icons.edit, color: AppTheme.primaryColor),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaixaFormScreen(caixa: caixa),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
