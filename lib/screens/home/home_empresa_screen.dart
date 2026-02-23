import 'package:emprestimos_app/providers/compra_provider.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/mensagens_manuais_provider.dart';
import 'package:emprestimos_app/providers/notificacoes_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/models/mensagem_manual.dart';
import 'package:emprestimos_app/screens/config/mensagensAutomaticas/mensagens_manuais.dart';
import 'package:emprestimos_app/widgets/banner_aviso_ativacao_widget.dart';
import 'package:emprestimos_app/widgets/botoes_acoes_rapidas.dart';
import 'package:emprestimos_app/widgets/bottomsheet_ativacao_plano.dart';
import 'package:emprestimos_app/widgets/label_titulo.dart';
import 'package:emprestimos_app/widgets/parcelas_relevantes.dart';
import 'package:emprestimos_app/widgets/previsao_recebimento_horizontal.dart';
import 'package:emprestimos_app/widgets/resumo_painel_widget.dart';
import 'package:emprestimos_app/widgets/scroll_hint.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeEmpresaScreen extends StatefulWidget {
  const HomeEmpresaScreen({super.key});

  @override
  State<HomeEmpresaScreen> createState() => _HomeEmpresaScreenState();
}

class _HomeEmpresaScreenState extends State<HomeEmpresaScreen> {
  bool _mostrarBannerModelosMensagens = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<ContasReceberProvider>(context, listen: false);
      final parametroProvider =
          Provider.of<ParametroProvider>(context, listen: false);
      final empresaProvider =
          Provider.of<EmpresaProvider>(context, listen: false);
      final notificacaoProvider =
          Provider.of<NotificacaoProvider>(context, listen: false);
      final mensagensManuaisProvider =
          Provider.of<MensagensManuaisProvider>(context, listen: false);

      try {
        await Future.wait([
          provider.buscarParcelasRelevantes(),
          provider.buscarResumoEmpresa(),
          provider.buscarPrevisaoRecebimentos(),
          empresaProvider.buscarEmpresaById(null),
          notificacaoProvider.buscarNotificacoes(reset: true),
          mensagensManuaisProvider.buscarMensagens(),
        ]);
        parametroProvider.buscarParametrosEmpresa();
        if (mounted) {
          setState(() {
            _mostrarBannerModelosMensagens = _deveMostrarBannerModelosMensagens(
              mensagensManuaisProvider.mensagens,
            );
          });
        }
      } catch (e) {
        debugPrint('Erro ao buscar dados: $e');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final compra = context.read<CompraProvider>();
    compra.addListener(() async {
      if (compra.assinaturaVinculadaComSucesso) {
        await context.read<EmpresaProvider>().buscarEmpresaById(null);
        compra.limparStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assinatura ativada com sucesso!')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContasReceberProvider>(context);
    final empresaProvider =
        Provider.of<EmpresaProvider>(context, listen: false);
    final nomeUsuario = empresaProvider.getNomeEmpresa();
    final notificacaoProvider = Provider.of<NotificacaoProvider>(context);

    return Column(
      children: [
        ResumoPainelWidget(
          isEmpresa: true,
          capitalInvestido: provider.resumoEmpresa?.capitalInvestido ?? 0.0,
          totalReceber: provider.resumoEmpresa?.totalReceber ?? 0.0,
          inadimplentes: provider.resumoEmpresa?.inadimplentes ?? 0,
          adimplentes: provider.resumoEmpresa?.adimplentes ?? 0,
          esconderValores: provider.esconderValores,
          onToggleEsconderValores: provider.toggleEsconderValores,
          nomeUsuario: nomeUsuario,
          notificacoesNaoVisualizadas:
              notificacaoProvider.notificacoesNaoVisualizadas,
          onOpenDrawer: () => Scaffold.of(context).openDrawer(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BtnAcoesRapidas(),
                    const SizedBox(height: 16),
                    if (empresaProvider.empresa != null &&
                        !empresaProvider.empresa!.planoAtivo)
                      BannerAvisoAtivacao(
                        createdAt: empresaProvider.empresa!.createdAt!,
                        onAtivarPlano: () {
                          showBottomSheetAtivacao(
                            context: context,
                            plano: empresaProvider.empresa!.plano,
                            buscarPlanoSelecionado: null,
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;

                        return isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LabelTitulo(titulo: "📌 Parcelas Relevantes"),
                                  const SizedBox(height: 12),
                                  ParcelasResumoCard(
                                    fetchData:
                                        provider.buscarParcelasRelevantes,
                                    parcelas: provider.parcelas,
                                    isLoading: provider.isLoading,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LabelTitulo(titulo: "📌 Parcelas Relevantes"),
                                  const SizedBox(height: 12),
                                  ParcelasResumoCard(
                                    fetchData: provider.buscarParcelasRelevantes,
                                    parcelas: provider.parcelas,
                                    isLoading: provider.isLoading,
                                  ),
                                ],
                              );
                      },
                    ),
                    if (_mostrarBannerModelosMensagens) ...[
                      const SizedBox(height: 16),
                      _ModelosMensagensCtaBanner(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MensagensManuaisScreen(),
                            ),
                          );
                          if (!mounted) return;
                          final mensagensProvider =
                              Provider.of<MensagensManuaisProvider>(
                            context,
                            listen: false,
                          );
                          await mensagensProvider.buscarMensagens();
                          if (!mounted) return;
                          setState(() {
                            _mostrarBannerModelosMensagens =
                                _deveMostrarBannerModelosMensagens(
                              mensagensProvider.mensagens,
                            );
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    const ScrollHint(label: "Mais recursos abaixo"),
                    const SizedBox(height: 12),
                    LabelTitulo(titulo: "📊 Previsão de Recebimentos"),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PrevisaoRecebimentosHorizontal(
                              previsoes: provider.previsoes,
                            ),
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _deveMostrarBannerModelosMensagens(List<MensagemManual> mensagens) {
    if (mensagens.isEmpty) return true;

    final cobranca = mensagens.where((m) => m.tipo == TipoMensagemManual.cobrancaAtraso).firstOrNull;
    final baixa = mensagens.where((m) => m.tipo == TipoMensagemManual.baixaParcela).firstOrNull;

    if (cobranca == null || baixa == null) return true;

    return _textoNormalizado(cobranca.conteudo) == _textoNormalizado(_cobrancaPadraoLegada) &&
        _textoNormalizado(baixa.conteudo) == _textoNormalizado(_baixaPadraoLegada);
  }

  String _textoNormalizado(String texto) =>
      texto.replaceAll(RegExp(r'\s+'), ' ').trim();

  static const String _cobrancaPadraoLegada =
      "Olá {{nome}},\n\n"
      "Sua parcela nº {{numero_parcela}} no valor de {{valor_parcela}} do contrato de {{valor_total}} venceu em {{vencimento}}.\n"
      "Por favor, nos informe sobre o pagamento ou entre em contato para mais informações.\n\n"
      "Aguardamos seu retorno!";

  static const String _baixaPadraoLegada =
      "Olá {{nome}},\n\n"
      "Recebemos o pagamento da parcela nº {{numero_parcela}}.\n"
      "Valor pago: {{valor_pago}}\n"
      "Data/hora do pagamento: {{data_pagamento}}\n"
      "Saldo da parcela (baixa parcial): {{saldo_parcela}}\n\n"
      "Obrigado!";
}

class _ModelosMensagensCtaBanner extends StatefulWidget {
  final VoidCallback onTap;

  const _ModelosMensagensCtaBanner({required this.onTap});

  @override
  State<_ModelosMensagensCtaBanner> createState() =>
      _ModelosMensagensCtaBannerState();
}

class _ModelosMensagensCtaBannerState extends State<_ModelosMensagensCtaBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hintController;
  late final Animation<double> _hintAnim;
  double _dragPx = 0;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _hintAnim = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeInOut,
    );
    _hintController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  void _triggerOpen() {
    if (_opening) return;
    _opening = true;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth =
            (constraints.maxWidth * 0.62).clamp(210.0, constraints.maxWidth);
        final knobSize = 34.0;
        final maxDrag = (trackWidth - knobSize - 8).clamp(0.0, 999.0);
        final threshold = maxDrag * 0.72;
        final hintedPx = (_hintAnim.value * 18).clamp(0.0, maxDrag);
        final effectiveKnobLeft = _dragPx > 0 ? _dragPx : hintedPx;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personalize suas mensagens',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Escolha mensagens prontas para cobrança e baixa.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.black.withValues(alpha: 0.62),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) {
                      if (_opening) return;
                      _hintController.stop();
                    },
                    onHorizontalDragUpdate: (details) {
                      if (_opening) return;
                      setState(() {
                        _dragPx =
                            (_dragPx + details.delta.dx).clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (_opening) return;
                      if (_dragPx >= threshold) {
                        _triggerOpen();
                        return;
                      }
                      setState(() => _dragPx = 0);
                      _hintController.repeat(reverse: true);
                    },
                    onHorizontalDragCancel: () {
                      if (_opening) return;
                      setState(() => _dragPx = 0);
                      _hintController.repeat(reverse: true);
                    },
                    child: Container(
                      height: 42,
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          width: trackWidth,
                          height: 42,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              scheme.primary.withValues(alpha: 0.45),
                              Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Center(
                                child: Text(
                                  'Arraste para abrir',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.90),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              AnimatedPositioned(
                                duration: _dragPx > 0
                                    ? Duration.zero
                                    : const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                left: effectiveKnobLeft,
                                child: Container(
                                  width: knobSize,
                                  height: knobSize,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: scheme.primary
                                            .withValues(alpha: 0.28),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
