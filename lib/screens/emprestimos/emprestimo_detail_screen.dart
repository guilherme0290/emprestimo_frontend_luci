import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'dart:io';

import 'package:emprestimos_app/models/baixa_parcela_result.dart';
import 'package:emprestimos_app/models/mensagem_manual.dart';
import 'package:emprestimos_app/core/role.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/mensagens_manuais_provider.dart';
import 'package:emprestimos_app/services/relatorio_parcelas_pdf_service.dart';
import 'package:emprestimos_app/screens/clientes/cliente_detail_screen.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/card_penhora_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/dialog_widget.dart';
import 'package:emprestimos_app/widgets/edit_message_dialog.dart';
import 'package:emprestimos_app/widgets/scroll_hint.dart';
import 'package:emprestimos_app/core/mensagem_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/emprestimo.dart';
import '../../models/parcela.dart';
import '../../providers/emprestimo_provider.dart';
import 'package:emprestimos_app/widgets/dialog_parcela.dart';

class ContasReceberDetailScreen extends StatefulWidget {
  final ContasReceberDTO? emprestimo;
  final int? contasreceberId;

  const ContasReceberDetailScreen({
    Key? key,
    this.emprestimo,
    this.contasreceberId,
  }) : super(key: key);

  @override
  State<ContasReceberDetailScreen> createState() =>
      _ContasReceberDetailScreenState();
}

class _ContasReceberDetailScreenState extends State<ContasReceberDetailScreen>
    with SingleTickerProviderStateMixin {
  late List<bool> _selectedParcelas;
  ContasReceberDTO? _emprestimo;
  Map<TipoMensagemManual, MensagemManual> _mensagensManuais = {};
  late final AnimationController _swipeHintController;
  late final Animation<double> _swipeHintOffset;
  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();
    _swipeHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _swipeHintOffset = Tween<double>(begin: 24, end: -24).animate(
      CurvedAnimation(parent: _swipeHintController, curve: Curves.easeInOut),
    );
    _swipeHintController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showSwipeHint = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showSwipeHint) {
        _swipeHintController.forward();
      }
    });
    if (widget.emprestimo != null) {
      _emprestimo = widget.emprestimo;
      _initializeParcelas();
    } else {
      _fetchContasReceber();
    }
    _carregarMensagensManuais();
  }

  @override
  void dispose() {
    _swipeHintController.dispose();
    super.dispose();
  }

  Future<void> _carregarMensagensManuais() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<MensagensManuaisProvider>(context, listen: false);
      await provider.buscarMensagens();
      if (!mounted) return;
      setState(() {
        _mensagensManuais = {
          for (final msg in provider.mensagens) msg.tipo: msg
        };
      });
    });
  }

  String _mensagemManualOuPadrao(
      TipoMensagemManual tipo, String mensagemPadrao) {
    final msg = _mensagensManuais[tipo];
    if (msg == null || !msg.ativo || msg.conteudo.trim().isEmpty) {
      return mensagemPadrao;
    }
    return msg.conteudo;
  }

  String _aplicarTagsMensagem(String template, Map<String, String> variaveis) {
    return MensagemUtils.aplicarTags(template, variaveis);
  }

  Future<void> _fetchContasReceber() async {
    if (widget.contasreceberId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final emprestimoProvider =
          Provider.of<ContasReceberProvider>(context, listen: false);
      final emprestimo = await emprestimoProvider
          .buscarContasReceberPorId(widget.contasreceberId!);
      if (emprestimo != null) {
        setState(() {
          _emprestimo = emprestimo;
          _initializeParcelas();
        });
      }
    });
  }

  void _initializeParcelas() {
    if (_emprestimo != null) {
      _selectedParcelas =
          List.generate(_emprestimo!.parcelas.length, (index) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContasReceberProvider>(
      builder: (context, emprestimoProvider, child) {
        Widget bodyContent;

        if (_emprestimo == null || emprestimoProvider.isLoading) {
          bodyContent = const Center(child: CircularProgressIndicator());
        } else {
          bodyContent = _buildConteudoCompleto();
        }

        final podeAcoes = (_emprestimo?.statusContasReceber != 'QUITADO');

        return Scaffold(
          appBar: _emprestimo != null ? _buildAppBar() : null,
          body: bodyContent,
          floatingActionButton: podeAcoes
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'fab_baixar_parcela',
                      onPressed: _abrirDialogBaixa,
                      backgroundColor: Colors.blueAccent,
                      tooltip: 'Baixar parcela',
                      child: const Icon(Icons.price_check, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'fab_whatsapp',
                      onPressed: _abrirWhatsapp,
                      backgroundColor: Colors.green,
                      tooltip: 'Cobrar no WhatsApp',
                      child: const Icon(FontAwesomeIcons.whatsapp),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  void _abrirWhatsapp() async {
    final parcelasSelecionadas = <ParcelaDTO>[];
    for (int i = 0; i < _selectedParcelas.length; i++) {
      if (_selectedParcelas[i]) {
        parcelasSelecionadas.add(_emprestimo!.parcelas[i]);
      }
    }

    if (parcelasSelecionadas.isEmpty) {
      MyAwesomeDialog(
          context: context,
          message:
              'Selecione ao menos uma parcela para enviar mensagem no WhatsApp.',
          title: 'Atenção',
          dialogType: DialogType.info,
          btnOkText: 'Ok',
          onOkPressed: () => {}).show();

      return;
    }

    final ParcelaDTO parcela = parcelasSelecionadas.first;
    final String nomeCliente =
        _emprestimo!.cliente.nome ?? "Cliente Desconhecido";
    final String telefoneCliente = _emprestimo!.cliente.telefone ?? "";
    final String numeroParcela = parcela.numeroParcela.toString();
    final String valorParcela = Util.formatarMoeda(parcela.valor);
    final String dataVencimento =
        FormatData.formatarDataCompleta(parcela.dataVencimento);
    final String dataVencimentoCurta =
        FormatData.formatarData(parcela.dataVencimento);

    final String mensagemPadraoFallback = """
Olá $nomeCliente,

Estamos entrando em contato para lembrar que sua parcela nº $numeroParcela no valor de $valorParcela venceu em $dataVencimento.

Por favor, nos informe sobre o pagamento ou entre em contato para mais informações.

Aguardamos seu retorno!
""";
    final String totalContasReceber = Util.formatarMoeda(_emprestimo!.valor);
    final String mensagemBase = _mensagemManualOuPadrao(
        TipoMensagemManual.cobrancaAtraso, mensagemPadraoFallback);
    final String mensagemPadrao = _aplicarTagsMensagem(mensagemBase, {
      "nome": nomeCliente,
      "numero_parcela": numeroParcela,
      "valor_parcela": valorParcela,
      "valor_total": totalContasReceber,
      "vencimento": dataVencimentoCurta,
      "vencimento_extenso": dataVencimento,
      "saudacao": MensagemUtils.obterSaudacao(),
    });

    if (telefoneCliente.isEmpty) {
      MyAwesomeDialog(
          context: context,
          message: 'Este cliente não possui um telefone cadastrado.',
          title: 'Atenção',
          dialogType: DialogType.error,
          btnOkText: 'Ok',
          onOkPressed: () => {}).show();
      return;
    }

    TextEditingController mensagemController =
        TextEditingController(text: mensagemPadrao);

    showEditMessageDialog(
        context: context,
        mensagemController: mensagemController,
        telefoneCliente: telefoneCliente);
  }

  String _formatarDataPagamentoParcelas(List<ParcelaDTO> parcelas) {
    final datas =
        parcelas.map((p) => p.dataPagamento).whereType<String>().toSet();
    if (datas.length == 1) {
      return FormatData.formatarDataHora(datas.first);
    }
    return "hoje";
  }

  String _formatarNumerosParcelas(List<ParcelaDTO> parcelas) {
    final numeros =
        parcelas.map((p) => p.numeroParcela).whereType<int>().toList()..sort();
    if (numeros.isEmpty) return "";
    return numeros.join(", ");
  }

  void _abrirWhatsappParcelasPagas(List<ParcelaDTO> parcelas) {
    if (parcelas.isEmpty) return;
    final String nomeCliente =
        _emprestimo?.cliente.nome ?? "Cliente Desconhecido";
    final String telefoneCliente = _emprestimo?.cliente.telefone ?? "";
    final String numeroParcela = _formatarNumerosParcelas(parcelas);
    final double valorTotal = parcelas.fold(0, (total, p) => total + p.valor);
    final String valorParcela = Util.formatarMoeda(valorTotal);
    final String dataPagamentoFormatada =
        _formatarDataPagamentoParcelas(parcelas);

    if (telefoneCliente.isEmpty) {
      MyAwesomeDialog(
          context: context,
          message: 'Este cliente não possui um telefone cadastrado.',
          title: 'Atenção',
          dialogType: DialogType.error,
          btnOkText: 'Ok',
          onOkPressed: () => {}).show();
      return;
    }

    final bool variasParcelas = parcelas.length > 1;
    final String mensagemPadraoFallback = variasParcelas
        ? """
Olá $nomeCliente,

Recebemos o pagamento das parcelas nº $numeroParcela no valor total de $valorParcela em $dataPagamentoFormatada.

Obrigado!
"""
        : """
Olá $nomeCliente,

Recebemos o pagamento da parcela nº $numeroParcela no valor de $valorParcela em $dataPagamentoFormatada.

Obrigado!
""";
    final String totalContasReceber =
        Util.formatarMoeda(_emprestimo?.valor ?? 0);
    final String mensagemBase = _mensagemManualOuPadrao(
        TipoMensagemManual.baixaParcela, mensagemPadraoFallback);
    final String mensagemPadrao = _aplicarTagsMensagem(mensagemBase, {
      "nome": nomeCliente,
      "numero_parcela": numeroParcela,
      "valor_parcela": valorParcela,
      "valor_total": totalContasReceber,
      "data_pagamento": dataPagamentoFormatada,
      "saudacao": MensagemUtils.obterSaudacao(),
    });

    final mensagemController = TextEditingController(text: mensagemPadrao);

    showEditMessageDialog(
        context: context,
        mensagemController: mensagemController,
        telefoneCliente: telefoneCliente);
  }

  List<ParcelaDTO> _buscarParcelasAtualizadas(
    ContasReceberDTO emprestimoAtualizado,
    List<ParcelaDTO> parcelasSelecionadas,
  ) {
    if (parcelasSelecionadas.isEmpty) return [];
    final parcelasAtualizadas = <ParcelaDTO>[];
    final parcelasPorId = {
      for (final parcela in emprestimoAtualizado.parcelas) parcela.id: parcela
    };
    for (final parcela in parcelasSelecionadas) {
      final atualizada = parcelasPorId[parcela.id];
      if (atualizada != null) {
        parcelasAtualizadas.add(atualizada);
      }
    }
    return parcelasAtualizadas;
  }

  PreferredSizeWidget _buildAppBar() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isEmpresa = authProvider.role == Role.EMPRESA;
    final bool podeExcluir =
        isEmpresa || _emprestimo!.statusContasReceber != 'QUITADO';
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contrato: #${_emprestimo!.id}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // >>> Regra adicionada: tocar no nome do cliente navega para a tela de clientes
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesContasReceber(
                        cliente: _emprestimo!.cliente,
                      ),
                    ),
                  ).then((_) {
                    // Caso você precise recarregar algo ao voltar, adicione aqui.
                    // Ex.: provider.carregarClientes();
                  });
                },
                child: Text(
                  "Cliente: ${Util.getPrimeiroNome(_emprestimo!.cliente.nome ?? 'Sem Nome')}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  _emprestimo!.dataContrato,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 8),
                podeExcluir
                    ? GestureDetector(
                        onTap: _confirmarExclusaoContrato,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.delete_outline,
                              size: 16, color: Colors.redAccent),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirRelatorioParcelas() async {
    if (_emprestimo == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdfFile = await RelatorioParcelasPdfService.salvarPdf(_emprestimo!);
      if (!mounted) return;
      Navigator.of(context).pop();
      _mostrarAcoesRelatorio(pdfFile);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao gerar relatório em PDF.")),
      );
    }
  }

  void _mostrarAcoesRelatorio(File pdfFile) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text("Imprimir / visualizar PDF"),
                onTap: () async {
                  Navigator.of(context).pop();
                  final bytes = await pdfFile.readAsBytes();
                  await Printing.layoutPdf(onLayout: (_) async => bytes);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.whatsapp),
                title: const Text("Enviar no WhatsApp"),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Share.shareXFiles(
                    [XFile(pdfFile.path)],
                    text:
                        "Relatório de parcelas do contrato #${_emprestimo!.id}",
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarExclusaoContrato() {
    MyAwesomeDialog(
      dialogType: DialogType.warning,
      context: context,
      btnOkText: 'Sim, Excluir',
      btnCancelText: 'Cancelar',
      title: "Excluir Contrato",
      message:
          'Tem certeza que deseja excluir este contrato? Esta ação é irreversível.',
      onOkPressed: _deletarContrato,
    ).show();
  }

  void _deletarContrato() async {
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);
    final sucesso = await provider.deletarContrato(_emprestimo!.id);

    if (sucesso) {
      // Mostrar feedback ANTES de sair
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contrato excluído com sucesso!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Aguarda para a Snackbar ser visível antes de fechar
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context); // volta só se sucesso
      }
    } else {
      // ❌ Erro: exibe diálogo, mas SEM dar pop
      MyAwesomeDialog(
        context: context,
        title: 'Erro ao excluir',
        message:
            provider.errorMessage ?? "Erro desconhecido ao excluir contrato.",
        dialogType: DialogType.error,
        btnOkText: 'Ok',
        onOkPressed: () {}, // não fecha a tela aqui!
      ).show();
    }
  }

  Widget _buildListaParcelas(ContasReceberDTO emp) {
    final parcelas = emp.parcelas;
    final firstSwipeIndex =
        parcelas.indexWhere((parcela) => parcela.status != "PAGA");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parcelas.length,
      itemBuilder: (context, index) {
        final parc = parcelas[index];
        final isSelected = _selectedParcelas[index];

        final card = Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: Util.getGradientForStatus(
                  parc.status), // Define o fundo com base no status
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho da parcela
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Parcela ${parc.numeroParcela}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Valor: ",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white70),
                              ),
                              TextSpan(
                                text: Util.formatarMoeda(parc.valor),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 1.4,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            side: BorderSide(
                              color: Util.getStatusColor(parc.status),
                              width: 2,
                            ),
                            checkColor: Colors.white,
                            activeColor: Util.getStatusColor(parc.status),
                            value: isSelected,
                            onChanged: parc.status == "PAGA"
                                ? null
                                : (bool? checked) {
                                    setState(() {
                                      _selectedParcelas[index] =
                                          checked ?? false;
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(color: Colors.white38),

                // Datas de vencimento e pagamento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(Icons.event, "Vencimento",
                        FormatData.formatarDataCompleta(parc.dataVencimento)),
                    _buildInfoItem(
                        Icons.history,
                        "Pagamento",
                        parc.dataPagamento != null
                            ? FormatData.formatarDataHora(parc.dataPagamento)
                            : "--"),
                  ],
                ),

                // Se houver baixas, mostrar abaixo com ExpansionTile
                if (parc.baixas != null && parc.baixas!.isNotEmpty) ...[
                  const Divider(color: Colors.white38),
                  ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Cantos arredondados
                      side: const BorderSide(
                          color: Colors.white24, width: 1), // Borda sutil
                    ),
                    collapsedBackgroundColor: Colors.white.withOpacity(0.1),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    iconColor: Colors.white, // Cor do ícone expandido
                    collapsedIconColor: Colors.white70, // Cor do ícone fechado

                    title: const Text(
                      "Baixas Registradas",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),

                    trailing: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 28, color: Colors.white),

                    children: parc.baixas!
                        .map((b) => ListTile(
                              leading: const Icon(Icons.attach_money,
                                  size: 20, color: Colors.greenAccent),
                              title: Text(
                                "${Util.formatarMoeda(b.valor)} - ${b.tipoBaixa}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                "Pago em ${FormatData.formatarDataComMesExtenso(b.dataPagamento)}  ${b.vendedorNome != null ? "por ${Util.getPrimeiroNome(b.vendedorNome!)}" : ""}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );

        if (parc.status == "PAGA") {
          return card;
        }

        final dismissible = Dismissible(
          key: ValueKey('parcela_${parc.id}'),
          direction: DismissDirection.horizontal,
          background: _buildSwipeBaixaBackground(Alignment.centerLeft),
          secondaryBackground:
              _buildSwipeBaixaBackground(Alignment.centerRight),
          confirmDismiss: (_) async {
            await _abrirDialogBaixaParaParcela(index);
            return false;
          },
          child: card,
        );

        if (_showSwipeHint && index == firstSwipeIndex) {
          return Stack(
            children: [
              dismissible,
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _swipeHintOffset,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_swipeHintOffset.value, 0),
                        child: child,
                      );
                    },
                    child: _buildSwipeHintOverlay(),
                  ),
                ),
              ),
            ],
          );
        }

        return dismissible;
      },
    );
  }

  Widget _buildSwipeBaixaBackground(Alignment alignment) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              "Baixar parcela",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ] else ...[
            const Text(
              "Baixar parcela",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _buildSwipeHintOverlay() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.swipe, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              "Deslize",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogConfirmacaoQuitarContasReceberPenhora() {
    MyAwesomeDialog(
            dialogType: DialogType.question,
            context: context,
            btnOkText: 'Sim',
            onCancelPressed: () {
              return;
            },
            onOkPressed: () => _quitarContasReceberPenhora(),
            btnCancelText: 'Não',
            title: "Atenção",
            message:
                'Você tem certeza que deseja executar esta penhora ? este processo é irreversivel')
        .show();
  }

  Future<void> _quitarContasReceberPenhora() async {
    final provider = Provider.of<ContasReceberProvider>(listen: false, context);
    await provider.quitarContasReceberComPenhora(_emprestimo!.id).then((value) {
      if (provider.errorMessage != null) {
        MyAwesomeDialog(
                dialogType: DialogType.error,
                context: context,
                btnCancelText: 'Ok',
                title: "Ops, algo deu errado!",
                message: provider.errorMessage!)
            .show();
      } else {
        setState(() {
          _emprestimo = value;
        });
      }
    });
  }

  Widget _buildConteudoCompleto() {
    return AppBackground(
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCabecalho(emp: _emprestimo!),
              if (_emprestimo?.penhora != null)
                CardInfoPenhoraWidget(penhora: _emprestimo!.penhora!),
              const SizedBox(height: 8),
              _buildListaParcelas(_emprestimo!),
              if (_emprestimo?.penhora != null &&
                  _emprestimo?.penhora!.status != 'EXECUTADA')
                CustomButton(
                  text: 'Executar Penhora',
                  onPressed: _dialogConfirmacaoQuitarContasReceberPenhora,
                ),
              const SizedBox(height: 8),
              if (_emprestimo?.statusContasReceber != 'QUITADO')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomButton(
                    text: 'Baixar parcela',
                    onPressed: _abrirDialogBaixa,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirDialogBaixa() async {
    final parcelasSelecionadas = <ParcelaDTO>[];
    for (int i = 0; i < _selectedParcelas.length; i++) {
      if (_selectedParcelas[i]) {
        parcelasSelecionadas.add(_emprestimo!.parcelas[i]);
      }
    }

    if (parcelasSelecionadas.isEmpty) {
      MyAwesomeDialog(
          context: context,
          message: 'Selecione ao menos uma parcela para dar baixa.',
          title: 'Atenção',
          dialogType: DialogType.info,
          btnOkText: 'Ok',
          onOkPressed: () => {}).show();
      return;
    }
    final resultado = await showDialog<BaixaParcelaResult>(
      context: context,
      builder: (_) => DialogBaixaParcelas(
          parcelasSelecionadas: parcelasSelecionadas,
          contasReceber: _emprestimo!),
    );

    tratarRetornoBaixa(resultado, parcelasSelecionadas);
  }

  Future<void> _abrirDialogBaixaParaParcela(int index) async {
    if (_emprestimo == null) return;
    setState(() {
      for (int i = 0; i < _selectedParcelas.length; i++) {
        _selectedParcelas[i] = i == index;
      }
    });
    _abrirDialogBaixa();
  }

  void tratarRetornoBaixa(BaixaParcelaResult? resultado,
      List<ParcelaDTO> parcelasSelecionadas) async {
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);

    if (resultado == null) return;
    if (resultado.sucesso == true) {
      final parcelasSelecionadasSnapshot =
          List<ParcelaDTO>.from(parcelasSelecionadas);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Baixa registrada com sucesso!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

      final emprestimoAtualizado =
          await provider.buscarContasReceberPorId(_emprestimo!.id);
      parcelasSelecionadas.clear();
      if (emprestimoAtualizado != null) {
        setState(() {
          _emprestimo = emprestimoAtualizado;
          _selectedParcelas =
              List.generate(_emprestimo!.parcelas.length, (index) => false);
        });
        final parcelasAtualizadas = _buscarParcelasAtualizadas(
          emprestimoAtualizado,
          parcelasSelecionadasSnapshot,
        );
        _abrirWhatsappParcelasPagas(parcelasAtualizadas);
      }
    } else {
      MyAwesomeDialog(
        context: context,
        message: resultado.mensagemErro ?? "Erro ao registrar baixa",
        title: 'Atenção',
        dialogType: DialogType.error,
        btnOkText: 'Ok',
        onOkPressed: () => {},
      ).show();
    }
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return SizedBox(
      width: 130, // aumente conforme o espaço disponível
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoAction(
      IconData icon, String label, String value, VoidCallback onTap) {
    return SizedBox(
      width: 130,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho({required ContasReceberDTO emp}) {
    final desc = emp.descricao?.trim();
    final totalParcelas = emp.parcelas.length;
    final parcelasPagas = emp.parcelas.where((p) => p.status == "PAGA").length;

    final valorContasReceber = emp.valor;
    final totalJuros =
        emp.parcelas.fold(0.0, (sum, p) => sum + (p.jurosParcela ?? 0.0));
    final valorTotalComJuros = valorContasReceber + totalJuros;
    final jurosPagos = emp.parcelas
        .expand((p) => p.baixas ?? [])
        .fold(0.0, (sum, b) => sum + (b.tipoBaixa == "JUROS" ? b.valor : 0.0));
    final totalPago = emp.parcelas
        .expand((p) => p.baixas ?? [])
        .fold(0.0, (sum, b) => sum + b.valor);

    return SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (desc != null && desc.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.description,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itens = [
                    _buildInfoItem(Icons.monetization_on, "Vl. venda",
                        Util.formatarMoeda(valorContasReceber)),
                    _buildInfoItem(Icons.attach_money, "Total com Lucro",
                        Util.formatarMoeda(valorTotalComJuros)),
                    _buildInfoItem(Icons.percent, "Margem Lucro",
                        "${emp.juros.toStringAsFixed(1)}%"),
                    _buildInfoItem(Icons.paid, "Total Pago",
                        Util.formatarMoeda(totalPago)),
                    _buildInfoItem(Icons.check_circle, "Parcelas Pagas",
                        "$parcelasPagas/$totalParcelas"),
                    _buildInfoItem(Icons.trending_up, "Juros Pago",
                        Util.formatarMoeda(jurosPagos)),
                    _buildInfoItem(
                        Icons.info, "Status", emp.statusContasReceber),
                    _buildInfoItem(
                        Icons.calendar_today, "Tipo", emp.tipoPagamento),
                    _buildInfoAction(
                      Icons.picture_as_pdf,
                      "Extrato",
                      "PDF",
                      _abrirRelatorioParcelas,
                    ),
                    if (emp.vendedorNome!.isNotEmpty)
                      _buildInfoItem(Icons.person, "Vendedor",
                          Util.getPrimeiroNome(emp.vendedorNome!)),
                  ];

                  const rows = 3;
                  final columns = (itens.length / rows).ceil();
                  final colunas = List.generate(columns, (_) => <Widget>[]);
                  for (int col = 0; col < columns; col++) {
                    final coluna = <Widget>[];
                    for (int row = 0; row < rows; row++) {
                      final index = col * rows + row;
                      if (index < itens.length) {
                        coluna.add(itens[index]);
                      }
                    }
                    colunas[col] = coluna;
                  }

                  final hasScrollHint = colunas.length > 3;

                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: colunas
                              .map(
                                (coluna) => Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Column(
                                    children: coluna
                                        .map((item) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: item,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      if (hasScrollHint) ...[
                        const SizedBox(height: 6),
                        const ScrollHint(
                          label: "Arraste para o lado",
                          axis: Axis.horizontal,
                          color: Colors.white70,
                          icon: Icons.swipe,
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ));
  }

  Widget _buildDescricaoContratoReadOnly() {
    final desc = _emprestimo?.descricao?.trim();
    final hasDesc = desc != null && desc.isNotEmpty;

    if (!hasDesc)
      return const SizedBox.shrink(); // não mostra nada se vier vazio

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              desc!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
