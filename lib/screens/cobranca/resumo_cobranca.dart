// Tela principal com filtro e resumo por caixa
import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/screens/cobranca/resumo_cobranca_detalhe_agrupamento.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/range_datas.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ResumoCobrancasScreen extends StatefulWidget {
  const ResumoCobrancasScreen({Key? key}) : super(key: key);

  @override
  State<ResumoCobrancasScreen> createState() => _ResumoCobrancasScreenState();
}

class _ResumoCobrancasScreenState extends State<ResumoCobrancasScreen> {
  String? situacaoSelecionada;
  DateTime? vencimentoInicio;
  DateTime? vencimentoFim;
  DateTime? pagamentoInicio;
  DateTime? pagamentoFim;
  String? caixaSelecionado;
  String? vendedorSelecionado;

  final List<String> situacoes = ['Parcelas em Aberto', 'Parcelas Pagas'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final caixaProvider = Provider.of<CaixaProvider>(context, listen: false);
      final vendedorProvider =
          Provider.of<VendedorProvider>(context, listen: false);
      await caixaProvider.listarCaixas();
      await vendedorProvider.listarVendedores();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final vendedores = Provider.of<VendedorProvider>(context).vendedores;
    final caixas = Provider.of<CaixaProvider>(context).caixas;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo de Cobranças'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: situacaoSelecionada,
              items: situacoes
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => situacaoSelecionada = val),
              decoration:
                  const InputDecoration(labelText: 'Situação das Parcelas'),
            ),
            const SizedBox(height: 12),
            _buildDateSelector(
              'Vencimento',
              vencimentoInicio,
              vencimentoFim,
              (inicio, fim) {
                setState(() {
                  vencimentoInicio = inicio;
                  vencimentoFim = fim;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildDateSelector(
              'Data de Pgto entre',
              pagamentoInicio,
              pagamentoFim,
              (inicio, fim) {
                setState(() {
                  pagamentoInicio = inicio;
                  pagamentoFim = fim;
                });
              },
            ),
            const SizedBox(height: 12),
            if (caixas.isNotEmpty)
              DropdownButtonFormField<String>(
                value: caixaSelecionado,
                items: caixas
                    .map((caixa) => DropdownMenuItem(
                          value: caixa.descricao,
                          child: Text(caixa.descricao),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => caixaSelecionado = val),
                decoration: const InputDecoration(
                  labelText: 'Responsável/caixa',
                ),
              ),
            if (vendedores.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: vendedorSelecionado,
                items: vendedores
                    .map((v) => DropdownMenuItem(
                          value: v.nome,
                          child: Text(v.nome),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => vendedorSelecionado = val),
                decoration: const InputDecoration(labelText: 'Vendedor'),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Buscar',
                    onPressed: () async {
                      if (situacaoSelecionada == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Informe a situação da parcela!',
                                style: TextStyle(backgroundColor: Colors.red)),
                          ),
                        );
                        return;
                      }

                      final provider = Provider.of<ContasReceberProvider>(
                          context,
                          listen: false);

                      String? status;
                      if (situacaoSelecionada == 'Parcelas Pagas') {
                        status = 'PAGA';
                      } else if (situacaoSelecionada == 'Parcelas em Aberto') {
                        status = 'PENDENTE';
                      }

                      String? vencOuPgto;
                      DateTime? dataInicio;
                      DateTime? dataFim;

                      if (pagamentoInicio != null && pagamentoFim != null) {
                        vencOuPgto = 'pagamento';
                        dataInicio = pagamentoInicio;
                        dataFim = pagamentoFim;
                      } else if (vencimentoInicio != null &&
                          vencimentoFim != null) {
                        vencOuPgto = 'vencimento';
                        dataInicio = vencimentoInicio;
                        dataFim = vencimentoFim;
                      }

                      await provider.buscarAgrupamentoParcelas(
                        status: status,
                        dataInicio: dataInicio?.toIso8601String(),
                        dataFim: dataFim?.toIso8601String(),
                        vencimentoOuPagamento: vencOuPgto,
                        caixaId: _buscarIdCaixaSelecionado(context),
                        vendedorId: _buscarIdVendedorSelecionado(context),
                      );
                    },
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
                    onPressed: _limparFiltros,
                    child: const Icon(Icons.cleaning_services_outlined,
                        color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _consultarResultado(),
          ],
        ),
      ),
    );
  }

  void _limparFiltros() {
    setState(() {
      situacaoSelecionada = null;
      vencimentoInicio = null;
      vencimentoFim = null;
      pagamentoInicio = null;
      pagamentoFim = null;
      caixaSelecionado = null;
      vendedorSelecionado = null;
    });
  }

  Widget _consultarResultado() {
    final provider = Provider.of<ContasReceberProvider>(context);
    final dados = provider.resumoCobranca;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dados.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/img/no-results.json',
              height: 180,
              repeat: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nenhum resultado encontrado para os filtros atuais.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Calcular totais
    final totalParcelas = dados.fold<int>(0, (sum, e) => sum + e.contagem);
    final totalValor = dados.fold<double>(0.0, (sum, e) => sum + e.total);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Column(
        children: [
          SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(label: Text('Responsavel')),
                    DataColumn(label: Text('Nº Parcelas')),
                    DataColumn(label: Text('Valor Total')),
                  ],
                  rows: [
                    ...dados.map((e) => DataRow(cells: [
                          DataCell(Text(e.responsavel)),
                          DataCell(Center(child: Text(e.contagem.toString()))),
                          DataCell(Text(Util.formatarMoeda(e.total))),
                        ])),
                    // ➕ Linha de Total Geral
                    DataRow(
                      color: MaterialStateProperty.all(Colors.grey[200]),
                      cells: [
                        const DataCell(
                          Text(
                            'Total Geral',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              totalParcelas.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            Util.formatarMoeda(totalValor),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          ),
          const SizedBox(height: 12),
          // Botão de Detalhamento
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text('Detalhar (todas as parcelas)'),
              onPressed: () async {
                final empresaId =
                    Provider.of<EmpresaProvider>(context, listen: false)
                        .empresa!
                        .id;
                await provider.buscarDetalhesGeralUsandoUltimoFiltro(
                    empresaId: empresaId!);

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DetalhamentoAgrupamentoScreen(),
                  ),
                );
              },
            ),
          ),
        ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text('Detalhar (todas as parcelas)'),
              onPressed: () async {
                final empresaId =
                    Provider.of<EmpresaProvider>(context, listen: false)
                        .empresa!
                        .id;
                await provider.buscarDetalhesGeralUsandoUltimoFiltro(
                    empresaId: empresaId!);

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DetalhamentoAgrupamentoScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int? _buscarIdCaixaSelecionado(BuildContext context) {
    if (caixaSelecionado == null) return null;
    final caixas = Provider.of<CaixaProvider>(context, listen: false).caixas;
    final caixa = caixas.firstWhere(
      (c) => c.descricao == caixaSelecionado,
    );
    return caixa.id;
  }

  int? _buscarIdVendedorSelecionado(BuildContext context) {
    if (vendedorSelecionado == null) return null;
    final vendedores =
        Provider.of<VendedorProvider>(context, listen: false).vendedores;
    final vendedor = vendedores.firstWhere(
      (v) => v.nome == vendedorSelecionado,
    );
    return vendedor.id;
  }

  Widget _buildDateSelector(String label, DateTime? dataInicio,
      DateTime? dataFim, void Function(DateTime, DateTime) onSelected) {
    final texto = (dataInicio != null && dataFim != null)
        ? '${FormatData.formatarDataCompletaPadrao(dataInicio)} - ${FormatData.formatarDataCompletaPadrao(dataFim)}'
        : '';

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Selecione o período',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.date_range),
      ),
      controller: TextEditingController(text: texto),
      onTap: () async {
        final resultado = await DateRangeSelector.show(
          context,
          descricaoButton: 'Aplicar Filtro',
        );
        if (resultado != null) {
          onSelected(resultado['dataInicio']!, resultado['dataFim']!);
        }
      },
    );
  }
}

class DetalhesResumoScreen extends StatelessWidget {
  final String caixa;

  const DetalhesResumoScreen({super.key, required this.caixa});

  @override
  Widget build(BuildContext context) {
    final parcelas = List.generate(
        5, (index) => 'Parcela ${index + 1} - R\$ ${(index + 1) * 100}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes - $caixa'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: parcelas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(parcelas[index]),
            leading: const Icon(Icons.monetization_on_outlined),
          );
        },
      ),
    );
  }
}
