import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/mensagem_manual.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/mensagens_manuais_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/mensagem_tags.dart';
import 'package:emprestimos_app/core/mensagem_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/widgets/mensagem_teste_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:android_intent_plus/android_intent.dart';

class MensagensManuaisScreen extends StatefulWidget {
  const MensagensManuaisScreen({super.key});

  @override
  State<MensagensManuaisScreen> createState() => _MensagensManuaisScreenState();
}

class _MensagensManuaisScreenState extends State<MensagensManuaisScreen> {
  final Map<TipoMensagemManual, TextEditingController> _controllers = {};
  final Map<TipoMensagemManual, bool> _habilitado = {};
  final Map<TipoMensagemManual, FocusNode> _focusNodes = {};
  Empresa? _empresa;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _carregarEmpresa();
      final provider =
          Provider.of<MensagensManuaisProvider>(context, listen: false);
      provider.buscarMensagens().then((_) {
        for (var msg in provider.mensagens) {
          _controllers[msg.tipo] = TextEditingController(text: msg.conteudo);
          _habilitado[msg.tipo] = msg.ativo;
        }
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarEmpresa() {
    return Provider.of<EmpresaProvider>(context, listen: false)
        .buscarEmpresaById(null)
        .then((_) {
      setState(() {
        _empresa = Provider.of<EmpresaProvider>(context, listen: false).empresa;
      });
    });
  }

  bool empresaPodeUsarWhatsapp() {
    return _empresa?.plano?.incluiWhatsapp ?? false;
  }

  ParcelaDTO _selecionarParcelaParaPreview(
      TipoMensagemManual tipo, ContasReceberDTO conta) {
    if (conta.parcelas.isEmpty) {
      return ParcelaDTO(
        id: 0,
        valor: 0,
        dataVencimento: "",
        numeroParcela: 0,
        status: "",
        dataPagamento: null,
        baixas: const [],
      );
    }

    if (tipo == TipoMensagemManual.baixaParcela) {
      final paga = conta.parcelas.firstWhere(
        (p) => p.status == "PAGA",
        orElse: () => conta.parcelas.first,
      );
      return paga;
    }

    final pendente = conta.parcelas.firstWhere(
      (p) => p.status != "PAGA",
      orElse: () => conta.parcelas.first,
    );
    return pendente;
  }

  Map<String, String> _montarTagsManuais(
      ContasReceberDTO conta, ParcelaDTO parcela) {
    final nomeCliente = conta.cliente.nome ?? "Cliente";
    final primeiroNome = Util.getPrimeiroNome(nomeCliente);
    final valorParcela = Util.formatarMoeda(parcela.valor);
    final totalContrato = Util.formatarMoeda(conta.valor);
    final dataVencimento =
        FormatData.formatarDataCompleta(parcela.dataVencimento);
    final dataVencimentoCurta =
        FormatData.formatarData(parcela.dataVencimento);
    final dataPagamento = parcela.dataPagamento != null
        ? FormatData.formatarDataHora(parcela.dataPagamento)
        : "hoje";
    final cobrador = conta.vendedorNome ?? "";
    final nomeEmpresa = _empresa?.responsavel ?? "";

    final totalPago = conta.parcelas
        .expand((p) => p.baixas ?? const [])
        .fold(0.0, (total, b) => total + b.valor);
    final saldoDevedor = Util.formatarMoeda(conta.valor - totalPago);
    final parcelasEmAtraso =
        conta.parcelas.where((p) => p.status == "ATRASADA").length.toString();
    final totalParcelas = conta.parcelas.length;
    final progressoParcela =
        "${parcela.numeroParcela}/${totalParcelas == 0 ? 1 : totalParcelas}";
    final totalPagoFormatado = Util.formatarMoeda(totalPago);
    final saldoEmAtraso = Util.formatarMoeda(
      conta.parcelas
          .where((p) => p.status == "ATRASADA")
          .fold(0.0, (total, p) => total + p.valor),
    );

    return {
      "nome": nomeCliente,
      "primeiro_nome": primeiroNome,
      "numero_parcela": parcela.numeroParcela.toString(),
      "valor_parcela": valorParcela,
      "valor_total": totalContrato,
      "vencimento": dataVencimentoCurta,
      "vencimento_extenso": dataVencimento,
      "data_pagamento": dataPagamento,
      "contrato_id": conta.id.toString(),
      "cobrador": cobrador,
      "saldo_devedor": saldoDevedor,
      "saldo_em_atraso": saldoEmAtraso,
      "total_pago": totalPagoFormatado,
      "parcelas_em_atraso": parcelasEmAtraso,
      "progresso_parcela": progressoParcela,
      "empresa": nomeEmpresa,
      "saudacao": MensagemUtils.obterSaudacao(),
    };
  }

  Future<List<ContasReceberDTO>> _buscarContasReceberParaTeste() async {
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);
    await provider.buscarAllContasReceber(null);
    return provider.contasreceber;
  }

  Future<void> _abrirModalTesteMensagem(TipoMensagemManual tipo) async {
    if (!empresaPodeUsarWhatsapp()) return;
    final controller = _controllers[tipo];
    if (controller == null || controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha a mensagem antes de testar.")),
      );
      return;
    }

    final contas = await _buscarContasReceberParaTeste();
    if (!mounted) return;
    if (contas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nenhum contrato encontrado.")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return MensagemTesteDialog(
          contas: contas,
          template: controller.text,
          selecionarParcela: (conta) =>
              _selecionarParcelaParaPreview(tipo, conta),
          montarTags: _montarTagsManuais,
          onEnviar: (telefone, mensagem) =>
              _abrirWhatsappTeste(context, telefone, mensagem),
        );
      },
    );
  }

  Future<void> _abrirWhatsappTeste(
    BuildContext context,
    String telefone,
    String mensagem,
  ) async {
    final telefoneLimpo = MensagemUtils.limparTelefone(telefone);
    if (telefoneLimpo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe um telefone válido.")),
      );
      return;
    }

    final mensagemFinal = Uri.encodeComponent(mensagem);
    final whatsappWebLink = "https://wa.me/$telefoneLimpo?text=$mensagemFinal";

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Escolher WhatsApp"),
            content: const Text(
              "Selecione qual aplicativo deseja usar para o teste.",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _abrirWhatsappPorPacote(
                    context,
                    whatsappWebLink,
                    'com.whatsapp',
                    "Não foi possível abrir o WhatsApp.",
                  );
                },
                child: const Text("WhatsApp"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _abrirWhatsappPorPacote(
                    context,
                    whatsappWebLink,
                    'com.whatsapp.w4b',
                    "Não foi possível abrir o WhatsApp Business.",
                  );
                },
                child: const Text("WhatsApp Business"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _abrirWhatsappFallback(
                    context,
                    whatsappWebLink,
                    "Não foi possível abrir o WhatsApp.",
                  );
                },
                child: const Text("Escolher app"),
              ),
            ],
          );
        },
      );
      return;
    }

    await _abrirWhatsappFallback(
      context,
      whatsappWebLink,
      "Não foi possível abrir o WhatsApp.",
    );
  }

  Future<void> _abrirWhatsappFallback(
    BuildContext context,
    String link,
    String mensagemErro,
  ) async {
    final ok = await launchUrlString(
      link,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
    }
  }

  Future<void> _abrirWhatsappPorPacote(
    BuildContext context,
    String link,
    String pacote,
    String mensagemErro,
  ) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: link,
        package: pacote,
      );
      await intent.launch();
    } catch (_) {
      await _abrirWhatsappFallback(context, link, mensagemErro);
    }
  }

  void _inserirTagNaMensagem(String tag, TipoMensagemManual tipo) {
    final controller = _controllers[tipo];
    if (controller == null) return;

    final selection = controller.selection;
    final text = controller.text;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final novoTexto = text.replaceRange(start, end, tag);
    controller.value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: start + tag.length),
    );
  }

  void _mostrarTagsModal(TipoMensagemManual tipo) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              const Text(
                "Tags disponiveis",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...MensagemTags.todas.map(
                (t) => ListTile(
                  title: Text(t["tag"]!),
                  subtitle: Text(t["desc"]!),
                  onTap: () {
                    Navigator.pop(context);
                    _inserirTagNaMensagem(t["tag"]!, tipo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagChips(TipoMensagemManual tipo) {
    final tags = MensagemTags.todas.take(6).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...tags.map(
          (t) => ActionChip(
            label: Text(t["tag"]!),
            onPressed: () => _inserirTagNaMensagem(t["tag"]!, tipo),
          ),
        ),
        TextButton(
          onPressed: () => _mostrarTagsModal(tipo),
          child: const Text("Mais tags"),
        ),
      ],
    );
  }

  Widget _buildMensagemCard({
    required TipoMensagemManual tipo,
    required String titulo,
    required String subtitulo,
  }) {
    final controller =
        _controllers.putIfAbsent(tipo, () => TextEditingController());
    final ativo = _habilitado[tipo] ?? true;
    final focusNode = _focusNodes.putIfAbsent(tipo, () {
      final node = FocusNode();
      return node;
    });

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(subtitulo,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: ativo,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() => _habilitado[tipo] = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ativo)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTagChips(tipo),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Digite a mensagem...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            if (ativo) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _abrirModalTesteMensagem(tipo),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text("Testar"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _salvarMensagens() async {
    final provider =
        Provider.of<MensagensManuaisProvider>(context, listen: false);
    final mensagensAtualizadas = _controllers.entries.map((entry) {
      return MensagemManual(
        tipo: entry.key,
        conteudo: entry.value.text,
        ativo: _habilitado[entry.key] ?? true,
      );
    }).toList();

    await provider.salvarMensagens(mensagensAtualizadas);

    if (provider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.successMessage!),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Erro ao salvar mensagens"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MensagensManuaisProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensagens Manuais"),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : AppBackground(
              child: SafeArea(
                bottom: true,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildMensagemCard(
                        tipo: TipoMensagemManual.cobrancaAtraso,
                        titulo: "Cobrança manual",
                        subtitulo: "Usada ao cobrar parcela em atraso",
                      ),
                      _buildMensagemCard(
                        tipo: TipoMensagemManual.baixaParcela,
                        titulo: "Baixa de parcela",
                        subtitulo: "Usada após registrar a baixa",
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: "Salvar",
                        enabled: empresaPodeUsarWhatsapp(),
                        onPressed: _salvarMensagens,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      if (!empresaPodeUsarWhatsapp())
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            "Seu plano atual não contempla envio via WhatsApp.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
