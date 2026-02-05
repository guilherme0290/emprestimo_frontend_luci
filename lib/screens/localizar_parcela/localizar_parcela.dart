// lib/screens/contasreceber/contas_receber_search_screen.dart
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_detail_screen.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';

class ContasReceberSearchScreen extends StatefulWidget {
  const ContasReceberSearchScreen({super.key});

  @override
  State<ContasReceberSearchScreen> createState() =>
      _ContasReceberSearchScreenState();
}

class _ContasReceberSearchScreenState extends State<ContasReceberSearchScreen> {
  final _searchCtrl = TextEditingController();
  bool _fezBusca = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _executarBusca() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite algo para pesquisar.')),
      );
      return;
    }
    setState(() => _fezBusca = true);
    await context.read<ContasReceberProvider>().buscarContasReceberPorQuery(q);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContasReceberProvider>(
      builder: (context, prov, _) {
        final lista = prov.contasreceber;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            title: const Text('Buscar Contas a Receber'),
          ),
          body: AppBackground(
            child: Column(
              children: [
                // Barra de busca
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _executarBusca(),
                          decoration: InputDecoration(
                            hintText:
                                'Descrição do contrato ou nome do cliente',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: prov.isLoading ? null : _executarBusca,
                        icon: const Icon(Icons.search),
                        label: const Text('Pesquisar'),
                      ),
                    ],
                  ),
                ),

                // Resultados / estados
                Expanded(
                  child: prov.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : !_fezBusca
                          ? Center(
                              child: Text(
                                'Pesquise pelo nome do cliente ou descrição \n do contrato !',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            )
                          : prov.errorMessage != null
                              ? _ErroState(
                                  mensagem: prov.errorMessage!,
                                  onRetry: _executarBusca,
                                )
                              : lista.isEmpty
                                  ? Center(
                                      child: Lottie.asset(
                                        'assets/img/no-results.json',
                                        height: 180,
                                        repeat: true,
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 6, 12, 16),
                                      itemCount: lista.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        final cr = lista[i];
                                        return _ContasReceberCard(
                                          cr: cr,
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ContasReceberDetailScreen(
                                                  emprestimo: cr,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContasReceberCard extends StatelessWidget {
  final ContasReceberDTO cr;
  final VoidCallback? onTap;

  const _ContasReceberCard({required this.cr, this.onTap});

  // Próxima parcela pendente/atrasada
  ParcelaDTO? _proximaEmAbertoOuAtraso() {
    final pendOuAtraso = cr.parcelas
        .where((p) => p.status == 'PENDENTE' || p.status == 'ATRASADA')
        .toList()
      ..sort((a, b) => (a.dataVencimento).compareTo(b.dataVencimento));
    return pendOuAtraso.isNotEmpty ? pendOuAtraso.first : null;
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ATRASO':
      case 'ATRASADA':
        return Colors.redAccent;
      case 'ATIVO':
        return AppTheme.accentColor; // ciano suave
      case 'QUITADO':
        return Colors.green;
      default:
        return AppTheme.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final valor = Util.formatarMoeda(cr.valor);
    final cliente = Util.getPrimeiroNome(cr.cliente.nome ?? 'Sem Nome');
    final desc = (cr.descricao ?? '').trim();
    final status = cr.statusContasReceber;
    final pagas = cr.parcelas.where((p) => p.status == "PAGA").length;
    final total = cr.parcelas.length;
    final pend = _proximaEmAbertoOuAtraso();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _statusColor(status).withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // faixa colorida à esquerda para status
              Positioned.fill(
                left: 0,
                right: null,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 14, right: 12, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho: contrato + valor + badge status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Contrato #${cr.id}  ',
                                  style: const TextStyle(
                                    color: AppTheme.textColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: '• $cliente',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              valor,
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _StatusPill(
                                text: status, color: _statusColor(status)),
                          ],
                        ),
                      ],
                    ),

                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.description,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Bloco da próxima parcela (se houver)
                    if (pend != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (pend.status == 'ATRASADA'
                              ? Colors.redAccent.withOpacity(0.08)
                              : AppTheme.accentColor.withOpacity(0.08)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (pend.status == 'ATRASADA'
                                    ? Colors.redAccent
                                    : AppTheme.accentColor)
                                .withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              pend.status == 'ATRASADA'
                                  ? Icons.warning_amber_rounded
                                  : Icons.schedule,
                              size: 18,
                              color: pend.status == 'ATRASADA'
                                  ? Colors.redAccent
                                  : AppTheme.accentColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pend.status == 'ATRASADA'
                                        ? 'Parcela ${pend.numeroParcela} • ATRASADA'
                                        : 'Próxima parcela • ${pend.numeroParcela}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: pend.status == 'ATRASADA'
                                          ? Colors.redAccent
                                          : AppTheme.secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Vencimento: ${FormatData.formatarDataCompleta(pend.dataVencimento)} · '
                                    'Valor: ${Util.formatarMoeda(pend.valor)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Chips: progresso, tipo, data contrato
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _ChipInfo(
                          icon: Icons.payments_outlined,
                          label: 'Pagas: $pagas/$total',
                        ),
                        _ChipInfo(
                          icon: Icons.calendar_month,
                          label: cr.tipoPagamento,
                        ),
                        _ChipInfo(
                          icon: Icons.event,
                          label: cr.dataContrato,
                        ),
                        if (cr.vendedorNome != null &&
                            (cr.vendedorNome ?? '').isNotEmpty)
                          _ChipInfo(
                            icon: Icons.person_outline,
                            label: Util.getPrimeiroNome(cr.vendedorNome!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ChipInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.neutralColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.secondaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textColor),
          ),
        ],
      ),
    );
  }
}

class _ErroState extends StatelessWidget {
  final String mensagem;
  final Future<void> Function() onRetry;
  const _ErroState({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(mensagem, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ),
      ],
    );
  }
}
