import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/relatorio_recebimento_item.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/services/relatorio_recebimento_service.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/range_datas.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class RelatorioRecebimentosScreen extends StatefulWidget {
  const RelatorioRecebimentosScreen({super.key});

  @override
  State<RelatorioRecebimentosScreen> createState() =>
      _RelatorioRecebimentosScreenState();
}

class _RelatorioRecebimentosScreenState
    extends State<RelatorioRecebimentosScreen> {
  DateTime? pagamentoInicio;
  DateTime? pagamentoFim;
  int? caixaIdSelecionado;
  int? vendedorIdSelecionado;

  bool isLoading = false;
  String? errorMessage;
  List<RelatorioRecebimentoItem> resultados = [];

  bool get _isVendedor {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.loginResponse?.role == 'VENDEDOR';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final caixaProvider = Provider.of<CaixaProvider>(context, listen: false);
      final vendedorProvider =
          Provider.of<VendedorProvider>(context, listen: false);
      await caixaProvider.listarCaixas();
      await vendedorProvider.listarVendedores();

      if (_isVendedor) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        vendedorIdSelecionado = auth.loginResponse?.usuario.id;
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> _buscar() async {
    if (pagamentoInicio == null || pagamentoFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Informe o período de pagamento.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await RelatorioRecebimentoService.buscar(
        dataInicio: pagamentoInicio,
        dataFim: pagamentoFim,
        vendedorId: vendedorIdSelecionado,
        caixaId: caixaIdSelecionado,
      );
      setState(() => resultados = data);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _limpar() {
    setState(() {
      pagamentoInicio = null;
      pagamentoFim = null;
      caixaIdSelecionado = null;
      if (!_isVendedor) vendedorIdSelecionado = null;
      resultados = [];
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendedores = Provider.of<VendedorProvider>(context).vendedores;
    final caixas = Provider.of<CaixaProvider>(context).caixas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Recebimentos'),
        centerTitle: true,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateSelector(),
              const SizedBox(height: 12),
              if (caixas.isNotEmpty)
                DropdownButtonFormField<int>(
                  value: caixaIdSelecionado,
                  items: caixas
                      .map((caixa) => DropdownMenuItem<int>(
                            value: caixa.id,
                            child: Text(caixa.descricao),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => caixaIdSelecionado = val),
                  decoration: const InputDecoration(
                    labelText: 'Caixa',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              if (vendedores.isNotEmpty)
                DropdownButtonFormField<int>(
                  value: vendedorIdSelecionado,
                  items: vendedores
                      .map((v) => DropdownMenuItem<int>(
                            value: v.id,
                            child: Text(v.nome),
                          ))
                      .toList(),
                  onChanged: _isVendedor
                      ? null
                      : (val) => setState(() => vendedorIdSelecionado = val),
                  decoration: const InputDecoration(
                    labelText: 'Vendedor',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Confirmar',
                      onPressed: isLoading ? null : _buscar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey[200],
                        side: BorderSide.none,
                      ),
                      onPressed: _limpar,
                      child: const Icon(Icons.cleaning_services_outlined,
                          color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildResultado(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final texto = (pagamentoInicio != null && pagamentoFim != null)
        ? '${FormatData.formatarDataCompletaPadrao(pagamentoInicio)} - ${FormatData.formatarDataCompletaPadrao(pagamentoFim)}'
        : '';

    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Data pgto entre',
        hintText: 'Selecione o período',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.date_range),
      ),
      controller: TextEditingController(text: texto),
      onTap: () async {
        final resultado = await DateRangeSelector.show(
          context,
          descricaoButton: 'Aplicar Filtro',
        );
        if (resultado != null) {
          setState(() {
            pagamentoInicio = resultado['dataInicio'];
            pagamentoFim = resultado['dataFim'];
          });
        }
      },
    );
  }

  Widget _buildResultado() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (resultados.isEmpty) {
      return Center(
        child: Lottie.asset(
          'assets/img/no-results.json',
          height: 180,
          repeat: true,
        ),
      );
    }

    final total = resultados.fold<double>(
        0.0, (sum, item) => sum + item.valorPago);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          columnSpacing: 32,
          columns: const [
            DataColumn(label: Text('Vendedor')),
            DataColumn(label: Text('Valor Pago (Soma)')),
          ],
          rows: [
            ...resultados.map((e) => DataRow(cells: [
                  DataCell(Text(e.cobradorNome)),
                  DataCell(Text(Util.formatarMoeda(e.valorPago))),
                ])),
            DataRow(
              color: MaterialStateProperty.all(Colors.grey[200]),
              cells: [
                const DataCell(
                  Text('Total Geral',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataCell(
                  Text(
                    Util.formatarMoeda(total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
