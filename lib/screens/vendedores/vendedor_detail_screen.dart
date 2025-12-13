import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/resumo_vendedor.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/screens/vendedores/vendedor_create_screen.dart';
import 'package:emprestimos_app/widgets/indicador_resumo_widget.dart';
import 'package:emprestimos_app/widgets/list_emprestimo_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetalheVendedorScreen extends StatefulWidget {
  final Vendedor vendedor;

  const DetalheVendedorScreen({super.key, required this.vendedor});

  @override
  State<DetalheVendedorScreen> createState() => _DetalheVendedorScreenState();
}

class _DetalheVendedorScreenState extends State<DetalheVendedorScreen> {
  bool _isLoading = true;
  late Vendedor _vendedor = widget.vendedor;
  @override
  void initState() {
    super.initState();
    _vendedor = widget.vendedor; // copia inicial

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<ContasReceberProvider>(context, listen: false);

      await Future.wait([provider.buscarAllContasReceber(_vendedor)]);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContasReceberProvider>(context);
    final contasreceber = provider.contasreceber;

    return Scaffold(
      body: Column(
        children: [
          _buildVendedorResumoHeader(_vendedor),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contasreceber.isNotEmpty
                      ? ListaContasReceberWidget(
                          contasreceber: contasreceber,
                          exibirNomeCliente: true,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/img/cliente_sem_emprestimo.png',
                                width: 120,
                                height: 120,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Nenhum empréstimo encontrado para este vendedor!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9E9E9E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendedorResumoHeader(Vendedor vendedor) {
    final resumo = vendedor.resumoVendedorDTO;

    final capitalInvestido = resumo?.capitalInvestido ?? 0;
    final totalReceber = resumo?.totalReceber ?? 0;
    final adimplencia = resumo?.adimplentes.toInt() ?? 0;
    final inadimplencia = resumo?.inadimplentes.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Cabeçalho com botão voltar e nome
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Resumo do Vendedor",
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${vendedor.id}-${vendedor.nome}",
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_search,
                      color: Colors.white, size: 28),
                  onPressed: () async {
                    final vendedorAtualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VendedorFormScreen(vendedor: _vendedor),
                      ),
                    );

                    if (vendedorAtualizado != null &&
                        vendedorAtualizado is Vendedor) {
                      setState(() {
                        _vendedor = vendedorAtualizado;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Itens em Wrap com espaçamento
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoItem(Icons.attach_money, "Capital Investido",
                    Util.formatarMoeda(capitalInvestido), ""),
                _buildInfoItem(Icons.trending_up, "Total em Aberto",
                    Util.formatarMoeda(totalReceber), ""),
                IndicadorResumoWidget(
                  titulo: "Inadimplentes",
                  valor: "${inadimplencia.toStringAsFixed(1)}%",
                  cor: Colors.red,
                  icone: Icons.warning_amber_rounded,
                ),
                IndicadorResumoWidget(
                  titulo: "Adimplentes",
                  valor: "${adimplencia.toStringAsFixed(1)}%",
                  cor: Colors.green,
                  icone: Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    String descricao,
  ) {
    return Container(
      width: 130, // Largura mínima para evitar quebras indesejadas
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 26),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
