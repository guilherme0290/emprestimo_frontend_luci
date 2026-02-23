import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/relatorio_recebimento_item.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_detail_screen.dart';
import 'package:emprestimos_app/services/relatorio_recebimento_service.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/range_datas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late final TextEditingController _periodoController;

  bool isLoading = false;
  bool _mostrarDetalhes = false;
  String? errorMessage;
  List<RelatorioRecebimentoItem> resultados = [];

  bool get _isVendedor {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.loginResponse?.role == 'VENDEDOR';
  }

  @override
  void initState() {
    super.initState();
    _periodoController = TextEditingController();
    _atualizarTextoPeriodo();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isVendedor = auth.loginResponse?.role == 'VENDEDOR';
        final caixaProvider =
            Provider.of<CaixaProvider>(context, listen: false);
        final vendedorProvider =
            Provider.of<VendedorProvider>(context, listen: false);
        await caixaProvider.listarCaixas();
        await vendedorProvider.listarVendedores();

        if (isVendedor) {
          vendedorIdSelecionado = auth.loginResponse?.usuario.id;
        }

        if (mounted) setState(() {});
      } catch (e) {
        if (!mounted) return;
        setState(() => errorMessage = "Erro ao carregar filtros: $e");
      }
    });
  }

  @override
  void dispose() {
    _periodoController.dispose();
    super.dispose();
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
      setState(() {
        resultados = data;
        _mostrarDetalhes = false;
      });
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
      _atualizarTextoPeriodo();
      caixaIdSelecionado = null;
      if (!_isVendedor) vendedorIdSelecionado = null;
      resultados = [];
      _mostrarDetalhes = false;
      errorMessage = null;
    });
  }

  void _atualizarTextoPeriodo() {
    _periodoController.text = (pagamentoInicio != null && pagamentoFim != null)
        ? '${FormatData.formatarDataCompletaPadrao(pagamentoInicio)} - ${FormatData.formatarDataCompletaPadrao(pagamentoFim)}'
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final vendedores = Provider.of<VendedorProvider>(context).vendedores;
    final caixas = Provider.of<CaixaProvider>(context).caixas;
    final vendedorValue = vendedores.any((v) => v.id == vendedorIdSelecionado)
        ? vendedorIdSelecionado
        : null;
    final caixaValue = caixas.any((c) => c.id == caixaIdSelecionado)
        ? caixaIdSelecionado
        : null;

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
                  initialValue: caixaValue,
                  items: caixas
                      .map((caixa) => DropdownMenuItem<int>(
                            value: caixa.id,
                            child: Text(caixa.descricao),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => caixaIdSelecionado = val),
                  decoration: const InputDecoration(
                    labelText: 'Responsavel',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              if (vendedores.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: vendedorValue,
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
                    labelText: 'Cobrador',
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
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Data pgto entre',
        hintText: 'Selecione o período',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.date_range),
      ),
      controller: _periodoController,
      onTap: () async {
        final resultado = await DateRangeSelector.show(
          context,
          descricaoButton: 'Aplicar Filtro',
        );
        if (resultado != null) {
          setState(() {
            pagamentoInicio = resultado['dataInicio'];
            pagamentoFim = resultado['dataFim'];
            _atualizarTextoPeriodo();
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
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Nenhum resultado encontrado.'),
          ],
        ),
      );
    }

    final total =
        resultados.fold<double>(0.0, (sum, item) => sum + item.valorPago);
    final quantidade = resultados.length;
    final ticketMedio = quantidade > 0 ? total / quantidade : 0.0;
    final agrupadoPorRecebedor = <String, double>{};
    for (final item in resultados) {
      final chave =
          item.recebidoPor.trim().isEmpty ? 'Empresa' : item.recebidoPor.trim();
      agrupadoPorRecebedor[chave] =
          (agrupadoPorRecebedor[chave] ?? 0.0) + item.valorPago;
    }
    final entradasAgrupadas = agrupadoPorRecebedor.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResumoRecebimentos(
          total,
          quantidade,
          ticketMedio,
          entradasAgrupadas,
        ),
        if (_mostrarDetalhes) ...[
          const SizedBox(height: 12),
          _buildTabelaDetalhes(total),
        ],
      ],
    );
  }

  Widget _buildResumoRecebimentos(double total, int quantidade,
      double ticketMedio, List<MapEntry<String, double>> entradasAgrupadas) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildResumoTile(
                      'Total recebido', Util.formatarMoeda(total)),
                ),
                Expanded(
                  child: _buildResumoTile(
                      'Qtd. recebimentos', quantidade.toString()),
                ),
                Expanded(
                  child: _buildResumoTile(
                      'Ticket médio', Util.formatarMoeda(ticketMedio)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Recebido por',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
                columns: const [
                  DataColumn(label: Text('Recebedor')),
                  DataColumn(label: Text('Valor Pago (Soma)')),
                ],
                rows: [
                  ...entradasAgrupadas.map(
                    (e) => DataRow(
                      cells: [
                        DataCell(Text(e.key)),
                        DataCell(Text(Util.formatarMoeda(e.value))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _mostrarDetalhes = !_mostrarDetalhes),
                icon: Icon(_mostrarDetalhes
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                label: Text(
                  _mostrarDetalhes ? 'Ocultar Detalhes' : 'Detalhar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoTile(String titulo, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTabelaDetalhes(double total) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ),
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Data/Hora')),
            DataColumn(label: Text('Cliente')),
            DataColumn(label: Text('Contrato')),
            DataColumn(label: Text('Parcela')),
            DataColumn(label: Text('Valor Recebido')),
            DataColumn(label: Text('Criado por')),
            DataColumn(label: Text('Recebido por')),
            DataColumn(label: Text('Responsavel')),
            DataColumn(label: Text('Detalhar')),
          ],
          rows: [
            ...resultados.map((e) => DataRow(cells: [
                  DataCell(Text(
                    e.dataPagamento != null
                        ? DateFormat('dd/MM HH:mm').format(e.dataPagamento!)
                        : '--/-- --:--',
                  )),
                  DataCell(Text(e.clienteNome)),
                  DataCell(Text('#${e.contasReceberId}')),
                  DataCell(Text(e.numeroParcela.toString())),
                  DataCell(Text(Util.formatarMoeda(e.valorPago))),
                  DataCell(Text(e.criadoPor.isEmpty ? '-' : e.criadoPor)),
                  DataCell(Text(e.recebidoPor.isEmpty ? '-' : e.recebidoPor)),
                  DataCell(
                      Text(e.caixaDescricao.isEmpty ? '-' : e.caixaDescricao)),
                  DataCell(
                    IconButton(
                      tooltip: 'Abrir contrato',
                      icon: const Icon(Icons.open_in_new, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContasReceberDetailScreen(
                              contasreceberId: e.contasReceberId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ])),
            DataRow(
              color: WidgetStateProperty.all(Colors.grey[200]),
              cells: [
                const DataCell(
                  Text(
                    'Total Geral',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                DataCell(
                  Text(
                    Util.formatarMoeda(total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
