import 'package:emprestimos_app/providers/compra_provider.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/notificacoes_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/widgets/banner_aviso_ativacao_widget.dart';
import 'package:emprestimos_app/widgets/botoes_acoes_rapidas.dart';
import 'package:emprestimos_app/widgets/bottomsheet_ativacao_plano.dart';
import 'package:emprestimos_app/widgets/label_titulo.dart';
import 'package:emprestimos_app/widgets/parcelas_relevantes.dart';
import 'package:emprestimos_app/widgets/previsao_recebimento_horizontal.dart';
import 'package:emprestimos_app/widgets/resumo_painel_widget.dart';
import 'package:emprestimos_app/widgets/resumo_trasacoes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeEmpresaScreen extends StatefulWidget {
  const HomeEmpresaScreen({super.key});

  @override
  State<HomeEmpresaScreen> createState() => _HomeEmpresaScreenState();
}

class _HomeEmpresaScreenState extends State<HomeEmpresaScreen> {
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

      // Toca o CompraProvider para garantir instância (caso mantenha lazy: true em algum momento)
      context.read<CompraProvider>();

      try {
        await Future.wait([
          provider.buscarParcelasRelevantes(),
          provider.buscarResumoEmpresa(),
          provider.buscarPrevisaoRecebimentos(),
          empresaProvider.buscarEmpresaById(null),
        ]);
        parametroProvider.buscarParametrosEmpresa();
        if (mounted) setState(() {});
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
                                  const SizedBox(height: 24),
                                  LabelTitulo(titulo: "📄 Transações"),
                                  const SizedBox(height: 12),
                                  const TransacoesResumoCard(), // criar esse widget!
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        LabelTitulo(
                                            titulo: "📌 Parcelas Relevantes"),
                                        const SizedBox(height: 12),
                                        ParcelasResumoCard(
                                          fetchData:
                                              provider.buscarParcelasRelevantes,
                                          parcelas: provider.parcelas,
                                          isLoading: provider.isLoading,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        LabelTitulo(titulo: "📄 Transações"),
                                        const SizedBox(height: 12),
                                        const TransacoesResumoCard(),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
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
}
