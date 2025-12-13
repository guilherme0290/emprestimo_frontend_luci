import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/role.dart';
import 'package:emprestimos_app/models/transacoes.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/transacoes_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/widgets/range_datas.dart';
import 'package:emprestimos_app/widgets/subtotal_transacoes_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransacoesResumoCard extends StatefulWidget {
  const TransacoesResumoCard({super.key});

  @override
  State<TransacoesResumoCard> createState() => _TransacoesResumoCardState();
}

class _TransacoesResumoCardState extends State<TransacoesResumoCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String filtroPeriodo = "7 dias";
  String? cobradorSelecionado;
  DateTime? dataInicio;
  DateTime? dataFim;
  String? caixaSelecionado;
  bool _isEmpresa = false;
  int? _vendedorLogadoId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transacoesProvider =
          Provider.of<TransacoesProvider>(context, listen: false);
      final vendedorProvider =
          Provider.of<VendedorProvider>(context, listen: false);
      final caixaProvider = Provider.of<CaixaProvider>(context, listen: false);

      // Descobre o role
      final roleStr = authProvider.loginResponse?.role ?? '';
      final roleEnum = Role.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => Role.EMPRESA,
      );

      // Id do usuário logado (nesse caso, vendedor)
      final vendedorIdLogado = authProvider.loginResponse?.usuario.id;

      setState(() {
        _isEmpresa = roleEnum == Role.EMPRESA;
        _vendedorLogadoId = vendedorIdLogado;
      });

      // Busca inicial de transações
      await transacoesProvider.buscarTransacoesCaixa(
        dias: 7,
        tipo: 'TODOS',
        vendedorId: _isEmpresa ? null : _vendedorLogadoId,
      );

      // Empresa enxerga caixas e lista de vendedores para filtro
      if (_isEmpresa) {
        await caixaProvider.listarCaixas();
        await vendedorProvider.listarVendedores();
      }

      if (mounted) setState(() {});
    });
  }

  int _periodoEmDias(String periodo) {
    switch (periodo) {
      case 'Hoje':
        return 0;
      case 'Ontem':
        return 1;
      case '7 dias':
        return 7;
      case '15 dias':
        return 15;
      case '30 dias':
        return 30;
      default:
        return 7;
    }
  }

  Future<void> _buscarTransacoes() async {
    final provider = Provider.of<TransacoesProvider>(context, listen: false);

    // Se for EMPRESA → usa o filtro selecionado
    // Se for VENDEDOR → força sempre o vendedor logado
    final vendedorId = _isEmpresa
        ? (cobradorSelecionado != null
            ? int.tryParse(cobradorSelecionado!)
            : null)
        : _vendedorLogadoId;

    await provider.buscarTransacoesCaixa(
      vendedorId: vendedorId,
      dias: dataInicio == null ? _periodoEmDias(filtroPeriodo) : 0,
      tipo: 'TODOS',
      dataInicio: dataInicio != null
          ? DateFormat('yyyy-MM-dd').format(dataInicio!)
          : null,
      dataFim:
          dataFim != null ? DateFormat('yyyy-MM-dd').format(dataFim!) : null,
      caixaId: _isEmpresa && caixaSelecionado != null
          ? int.tryParse(caixaSelecionado!)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transacoes = Provider.of<TransacoesProvider>(context).transacoes;
    final vendedores = _isEmpresa
        ? Provider.of<VendedorProvider>(context).vendedores
        : <Vendedor>[]; // se quiser, importe o model
    final caixas = _isEmpresa ? Provider.of<CaixaProvider>(context).caixas : [];

    final entradaTotal = transacoes
        .where((t) => t.tipo == "ENTRADA")
        .fold<double>(0.0, (soma, t) => soma + t.valor);

    final saidaTotal = transacoes
        .where((t) => t.tipo == "SAIDA")
        .fold<double>(0.0, (soma, t) => soma + t.valor);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filtros"),
            Row(
              children: [
                DropdownButton<String>(
                  value: ['Hoje', 'Ontem', '7 dias', '15 dias', '30 dias']
                          .contains(filtroPeriodo)
                      ? filtroPeriodo
                      : null,
                  items: ['Hoje', 'Ontem', '7 dias', '15 dias', '30 dias']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  hint: const Text("Período"),
                  onChanged: (val) async {
                    setState(() {
                      filtroPeriodo = val!;
                      dataInicio = null;
                      dataFim = null;
                    });
                    await _buscarTransacoes();
                  },
                ),
                const SizedBox(width: 16),

                // 🔹 Só EMPRESA pode escolher vendedor
                if (_isEmpresa && vendedores.isNotEmpty)
                  Expanded(
                    child: DropdownButton<String>(
                      hint: const Text("Vendedor"),
                      value: cobradorSelecionado,
                      isExpanded: true,
                      items: vendedores
                          .map((e) => DropdownMenuItem(
                                value: e.id.toString(),
                                child: Text(e.nome),
                              ))
                          .toList(),
                      onChanged: (val) async {
                        setState(() => cobradorSelecionado = val);
                        await _buscarTransacoes();
                      },
                    ),
                  ),

                IconButton(
                  onPressed: () async {
                    final resultado = await DateRangeSelector.show(context);
                    if (resultado != null) {
                      setState(() {
                        dataInicio = resultado['dataInicio']!;
                        dataFim = resultado['dataFim']!;
                        filtroPeriodo = 'Personalizado';
                      });
                      await _buscarTransacoes();
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  tooltip: 'Selecionar Período Personalizado',
                ),

                // 🔹 Botão de limpar só faz sentido para EMPRESA
                if (_isEmpresa) ...[
                  IconButton(
                    onPressed: () {
                      _resetarFiltros();
                    },
                    icon: const Icon(Icons.clear),
                  )
                ],
              ],
            ),
            const SizedBox(height: 16),
            // 🔹 Caixa só aparece para EMPRESA
            if (_isEmpresa && caixas.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: const Text("Responsavel"),
                      value: caixaSelecionado,
                      isExpanded: true,
                      items: caixas
                          .map((e) => DropdownMenuItem(
                                value: e.id.toString(),
                                child: Text(e.descricao),
                              ))
                          .toList(),
                      onChanged: (val) async {
                        setState(() => caixaSelecionado = val);
                        await _buscarTransacoes();
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _resetarFiltros();
                    },
                    icon: const Icon(Icons.clear),
                  )
                ],
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 16),
            SubTotalResumoTransacoesWidget(
              entradaTotal: entradaTotal,
              saidaTotal: saidaTotal,
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: 'Todas'),
                Tab(text: 'Entrada'),
                Tab(text: 'Saída'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLista(transacoes, "TODOS"),
                  _buildLista(transacoes, "ENTRADA"),
                  _buildLista(transacoes, "SAIDA"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLista(List<TransacaoCaixaDTO> transacoes, String tipoFiltro) {
    final transacoesFiltradas = tipoFiltro == "TODOS"
        ? transacoes
        : transacoes.where((t) => t.tipo == tipoFiltro).toList();

    if (transacoesFiltradas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Nenhuma transação"),
        ),
      );
    }

    return ListView.builder(
      itemCount: transacoesFiltradas.length,
      itemBuilder: (context, index) {
        final t = transacoesFiltradas[index];
        final isEntrada = t.tipo == "ENTRADA";
        final cor = isEntrada ? Colors.green : Colors.red;
        final icone = isEntrada ? Icons.arrow_downward : Icons.arrow_upward;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Card(
            elevation: 0, // já temos sombra no Container, não precisa mais aqui
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: cor.withOpacity(0.1),
                child: Icon(icone, color: cor),
              ),
              title: Text(
                FormatData.formatarDataCurta(t.data),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              subtitle: Text(t.descricao),
              trailing: Text(
                "${isEntrada ? '+' : '-'} R\$ ${t.valor.toStringAsFixed(2)}",
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _resetarFiltros() async {
    setState(() {
      filtroPeriodo = "7 dias";
      cobradorSelecionado = null;
      caixaSelecionado = null;
      dataInicio = null;
      dataFim = null;
    });
    await _buscarTransacoes();
  }
}
