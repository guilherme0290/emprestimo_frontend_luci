import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/detalhamento_parcela.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';

enum GroupByOption { none, caixa, vendedor }

enum _SortBy { vencimentoAsc, vencimentoDesc, valorAsc, valorDesc, status }

class DetalhamentoAgrupamentoScreen extends StatefulWidget {
  const DetalhamentoAgrupamentoScreen({super.key});

  @override
  State<DetalhamentoAgrupamentoScreen> createState() =>
      _DetalhamentoAgrupamentoScreenState();
}

class _DetalhamentoAgrupamentoScreenState
    extends State<DetalhamentoAgrupamentoScreen> {
  GroupByOption _groupBy = GroupByOption.none;
  String _searchText = '';
  _SortBy _sortBy = _SortBy.vencimentoAsc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _recarregarDetalhes() async {
    final empresaId =
        Provider.of<EmpresaProvider>(context, listen: false).empresa!.id!;
    await Provider.of<ContasReceberProvider>(context, listen: false)
        .buscarDetalhesGeralUsandoUltimoFiltro(empresaId: empresaId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContasReceberProvider>(context);
    final itens = provider.detalhesGeral;
    final isLoading = provider.isLoading && itens.isEmpty;

    final hasCaixa =
        itens.any((d) => (d.caixaDescricao ?? '').trim().isNotEmpty);
    final hasVendedor =
        itens.any((d) => (d.vendedorNome ?? '').trim().isNotEmpty);
    final isWide = MediaQuery.of(context).size.width > 980;

    final query = _searchText.trim().toLowerCase();

    final itensFiltrados = itens.where((d) {
      if (query.isEmpty) return true;
      return d.clienteNome.toLowerCase().contains(query) ||
          (d.contratoNumero ?? '').toLowerCase().contains(query) ||
          (d.caixaDescricao ?? '').toLowerCase().contains(query) ||
          (d.vendedorNome ?? '').toLowerCase().contains(query);
    }).toList();

    itensFiltrados.sort((a, b) {
      switch (_sortBy) {
        case _SortBy.vencimentoAsc:
          return a.vencimento.compareTo(b.vencimento);
        case _SortBy.vencimentoDesc:
          return b.vencimento.compareTo(a.vencimento);
        case _SortBy.valorAsc:
          return a.valorParcela.compareTo(b.valorParcela);
        case _SortBy.valorDesc:
          return b.valorParcela.compareTo(a.valorParcela);
        case _SortBy.status:
          return a.status.compareTo(b.status);
      }
    });

    final totalGeral =
        itensFiltrados.fold<double>(0.0, (s, e) => s + e.valorParcela);
    final qtdGeral = itensFiltrados.length;

    final agrupado = _groupBy == GroupByOption.none
        ? <String, List<DetalheParcelaDTO>>{'Todos': itensFiltrados}
        : _group(
            itensFiltrados,
            _groupBy == GroupByOption.caixa
                ? (d) => d.caixaDescricao ?? 'Sem caixa'
                : (d) => d.vendedorNome ?? 'Sem vendedor',
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhamento de Parcelas'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _recarregarDetalhes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _recarregarDetalhes,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _KpiGradientCard(
                        title: 'Itens',
                        value: qtdGeral.toString(),
                        icon: Icons.receipt_long_outlined,
                      ),
                      _KpiGradientCard(
                        title: 'Total',
                        value: Util.formatarMoeda(totalGeral),
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tune, size: 18),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Filtros e busca',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (_searchText.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchText = '';
                                      _searchController.clear();
                                    });
                                  },
                                  child: const Text('Limpar'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (hasCaixa || hasVendedor)
                            _GroupSelectorBar(
                              initial: _groupBy,
                              enableCaixa: hasCaixa,
                              enableVendedor: hasVendedor,
                              onChanged: (v) => setState(() => _groupBy = v),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.search),
                                    hintText:
                                        'Buscar por cliente, contrato, caixa ou vendedor',
                                    suffixIcon: _searchText.isNotEmpty
                                        ? IconButton(
                                            tooltip: 'Limpar busca',
                                            onPressed: () {
                                              setState(() {
                                                _searchText = '';
                                                _searchController.clear();
                                              });
                                            },
                                            icon: const Icon(Icons.close),
                                          )
                                        : null,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _searchText = v),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _SortButton(
                                value: _sortBy,
                                onSelected: (v) => setState(() => _sortBy = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (itensFiltrados.isEmpty)
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: Text(
                          'Nenhuma parcela encontrada para os filtros atuais.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...agrupado.entries.map((entry) {
                      final nomeGrupo = entry.key;
                      final list = entry.value;
                      final subtotal =
                          list.fold<double>(0.0, (s, e) => s + e.valorParcela);

                      return _GroupCard(
                        title: nomeGrupo,
                        subtitle:
                            'Qtd: ${list.length} - Total: ${Util.formatarMoeda(subtotal)}',
                        initiallyExpanded: _groupBy == GroupByOption.none,
                        wide: isWide,
                        children: list,
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Map<String, List<DetalheParcelaDTO>> _group(
    List<DetalheParcelaDTO> list,
    String Function(DetalheParcelaDTO) keyFn,
  ) {
    final map = <String, List<DetalheParcelaDTO>>{};
    for (final item in list) {
      final k = keyFn(item);
      map.putIfAbsent(k, () => []);
      map[k]!.add(item);
    }
    return map;
  }
}

class _GroupSelectorBar extends StatelessWidget {
  final GroupByOption initial;
  final bool enableCaixa;
  final bool enableVendedor;
  final ValueChanged<GroupByOption> onChanged;

  const _GroupSelectorBar({
    required this.initial,
    required this.enableCaixa,
    required this.enableVendedor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final opts = <GroupByOption>[
      GroupByOption.none,
      if (enableCaixa) GroupByOption.caixa,
      if (enableVendedor) GroupByOption.vendedor,
    ];

    return Wrap(
      spacing: 8,
      children: opts.map((opt) {
        final selected = opt == initial;
        return ChoiceChip(
          label: Text(_label(opt)),
          selected: selected,
          onSelected: (_) => onChanged(opt),
        );
      }).toList(),
    );
  }

  String _label(GroupByOption opt) {
    switch (opt) {
      case GroupByOption.none:
        return 'Sem agrupamento';
      case GroupByOption.caixa:
        return 'Responsavel';
      case GroupByOption.vendedor:
        return 'Vendedor';
    }
  }
}

class _ParcelaTile extends StatelessWidget {
  final DetalheParcelaDTO d;
  const _ParcelaTile(this.d);

  Color _statusColor() {
    final s = d.status.toUpperCase();
    if (s.contains('PAG')) return Colors.green.shade600;
    if (s.contains('ATRAS')) return Colors.red.shade600;
    return Colors.orange.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(.1),
        foregroundColor: AppTheme.primaryColor,
        child: Text(d.numeroParcela.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      title: Text(
        '${d.clienteNome} - ${Util.formatarMoeda(d.valorParcela)}',
        style: const TextStyle(
            fontWeight: FontWeight.w700, color: AppTheme.textColor),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Wrap(
            spacing: 8,
            runSpacing: -8,
            children: [
              _ChipInfo(
                  icon: Icons.event,
                  text:
                      'Venc: ${FormatData.formatarDataCompletaPadrao(d.vencimento)}'),
              if (d.dataPagamento != null)
                _ChipInfo(
                    icon: Icons.payments,
                    text:
                        'Pgto: ${FormatData.formatarDataCompletaPadrao(d.dataPagamento!)}'),
              if ((d.caixaDescricao ?? '').isNotEmpty)
                _ChipInfo(
                    icon: Icons.account_balance_wallet_outlined,
                    text: d.caixaDescricao!),
              if ((d.vendedorNome ?? '').isNotEmpty)
                _ChipInfo(icon: Icons.person_outline, text: d.vendedorNome!),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.12),
              border: Border.all(color: statusColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(d.status,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContasReceberDetailScreen(
              emprestimo: null,
              contasreceberId: d.contasReceberId,
            ),
          ),
        );
      },
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ChipInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.primaryColor),
      label: Text(text, style: const TextStyle(color: AppTheme.textColor)),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
          side: BorderSide(color: AppTheme.primaryColor.withOpacity(.3))),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _GridTwoColumns extends StatelessWidget {
  final List<DetalheParcelaDTO> list;
  const _GridTwoColumns(this.list);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 3.2,
        ),
        itemBuilder: (_, i) => Card(
          elevation: 1.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _ParcelaTile(list[i]),
          ),
        ),
      ),
    );
  }
}

class _KpiGradientCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiGradientCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final _SortBy value;
  final ValueChanged<_SortBy> onSelected;

  const _SortButton({required this.value, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SortBy>(
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (ctx) => const [
        PopupMenuItem(
            value: _SortBy.vencimentoAsc, child: Text('Vencimento asc')),
        PopupMenuItem(
            value: _SortBy.vencimentoDesc, child: Text('Vencimento desc')),
        PopupMenuItem(value: _SortBy.valorAsc, child: Text('Valor asc')),
        PopupMenuItem(value: _SortBy.valorDesc, child: Text('Valor desc')),
        PopupMenuItem(value: _SortBy.status, child: Text('Status (A-Z)')),
      ],
      child: OutlinedButton.icon(
        icon: const Icon(Icons.sort, color: AppTheme.primaryColor),
        label: const Text('Ordenar',
            style: TextStyle(
                color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
        onPressed: null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.primaryColor),
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool initiallyExpanded;
  final bool wide;
  final List<DetalheParcelaDTO> children;

  const _GroupCard({
    required this.title,
    required this.subtitle,
    required this.initiallyExpanded,
    required this.wide,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.neutralColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textColor)),
                ),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            title: const SizedBox.shrink(),
            subtitle: const SizedBox.shrink(),
            trailing:
                const Icon(Icons.expand_more, color: AppTheme.primaryColor),
            children: [
              if (wide)
                _GridTwoColumns(children)
              else
                Column(children: children.map(_ParcelaTile.new).toList()),
            ],
          ),
        ],
      ),
    );
  }
}
