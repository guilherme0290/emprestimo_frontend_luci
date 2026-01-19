import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/mensagem_cobranca.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/mensagens_cobranca_provider.dart';
import 'package:emprestimos_app/screens/config/mensagensAutomaticas/vincular_whatsapp_screen.dart';
import 'package:emprestimos_app/screens/planos/escolher_planos.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/mensagem_tags.dart';
import 'package:emprestimos_app/core/mensagem_utils.dart';
import 'package:emprestimos_app/widgets/placeholdertag.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/widgets/mensagem_teste_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MensagensCobrancaScreen extends StatefulWidget {
  const MensagensCobrancaScreen({super.key});

  @override
  State<MensagensCobrancaScreen> createState() =>
      _MensagensCobrancaScreenState();
}

class _MensagensCobrancaScreenState extends State<MensagensCobrancaScreen>
    with TickerProviderStateMixin {
  final Map<TipoMensagemCobranca, TextEditingController> _controllers = {};
  final Map<TipoMensagemCobranca, bool> _habilitado = {};
  final Map<TipoMensagemCobranca, FocusNode> _focusNodes = {};
  Empresa? _empresa;

  late TabController _tabController;
  TipoMensagemCobranca? _tipoSelecionado;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _carregarEmpresa();
      final provider =
          Provider.of<MensagemCobrancaProvider>(context, listen: false);
      provider.buscarMensagens().then((_) {
        for (var msg in provider.mensagens) {
          _controllers[msg.tipo] = TextEditingController(text: msg.conteudo);
          _habilitado[msg.tipo] = msg.ativo;
        }
        setState(() {});
      });
    });
  }

  final Map<TipoMensagemCobranca, bool> _isExpanded = {
    TipoMensagemCobranca.antesVencimento: false,
    TipoMensagemCobranca.diaVencimento: false,
    TipoMensagemCobranca.dividaoQuitada: false,
    TipoMensagemCobranca.emAtraso: false,
  };

  @override
  void dispose() {
    _tabController.dispose();
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

  void _inserirTagNaMensagem(String tag, TipoMensagemCobranca tipo) {
    if (_controllers.isEmpty) return;
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

  void _mostrarTagsModal(TipoMensagemCobranca tipo) {
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

  Widget _buildTagChips(TipoMensagemCobranca tipo) {
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
    required TipoMensagemCobranca tipo,
    required String titulo,
    required String subtitulo,
  }) {
    final controller =
        _controllers.putIfAbsent(tipo, () => TextEditingController());
    final ativo = _habilitado[tipo] ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                GestureDetector(
                  onTap: () {
                    if (!empresaPodeUsarWhatsapp()) {
                      _mostrarDialogPlano();
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: !empresaPodeUsarWhatsapp(),
                    child: Switch(
                      value: ativo,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        setState(() => _habilitado[tipo] = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ativo)
              TextField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Digite a mensagem...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool empresaPodeUsarWhatsapp() {
    return _empresa?.plano?.incluiWhatsapp ?? false;
  }

  ParcelaDTO _selecionarParcelaParaPreview(ContasReceberDTO conta) {
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

    final pendente = conta.parcelas.firstWhere(
      (p) => p.status != "PAGA",
      orElse: () => conta.parcelas.first,
    );
    return pendente;
  }

  Map<String, String> _montarTagsCobranca(
      ContasReceberDTO conta, ParcelaDTO parcela) {
    final nomeCliente = conta.cliente.nome ?? "Cliente";
    final primeiroNome = Util.getPrimeiroNome(nomeCliente);
    final valorParcela = Util.formatarMoeda(parcela.valor);
    final totalContrato = Util.formatarMoeda(conta.valor);
    final dataVencimento = FormatData.formatarData(parcela.dataVencimento);
    final dataVencimentoExtenso =
        FormatData.formatarDataCompleta(parcela.dataVencimento);
    final totalParcelas = conta.parcelas.length;
    final progressoParcela =
        "${parcela.numeroParcela}/${totalParcelas == 0 ? 1 : totalParcelas}";
    final nomeEmpresa = _empresa?.responsavel ?? "";
    final cobrador = conta.vendedorNome ?? "";

    final totalPago = conta.parcelas
        .expand((p) => p.baixas ?? const [])
        .fold(0.0, (total, b) => total + b.valor);
    final saldoDevedor = Util.formatarMoeda(conta.valor - totalPago);
    final saldoEmAtraso = Util.formatarMoeda(
      conta.parcelas
          .where((p) => p.status == "ATRASADA")
          .fold(0.0, (total, p) => total + p.valor),
    );
    final totalPagoFormatado = Util.formatarMoeda(totalPago);
    final parcelasEmAtraso =
        conta.parcelas.where((p) => p.status == "ATRASADA").length.toString();

    return {
      "nome": nomeCliente,
      "primeiro_nome": primeiroNome,
      "saudacao": MensagemUtils.obterSaudacao(),
      "vencimento": dataVencimento,
      "vencimento_extenso": dataVencimentoExtenso,
      "valor_parcela": valorParcela,
      "valor_total": totalContrato,
      "progresso_parcela": progressoParcela,
      "empresa": nomeEmpresa,
      "saldo_em_atraso": saldoEmAtraso,
      "total_pago": totalPagoFormatado,
      "saldo_devedor": saldoDevedor,
      "cobrador": cobrador,
      "parcelas_em_atraso": parcelasEmAtraso,
      "contrato_id": conta.id.toString(),
    };
  }

  Future<List<ContasReceberDTO>> _buscarContasReceberParaTeste() async {
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);
    await provider.buscarAllContasReceber(null);
    return provider.contasreceber;
  }

  Future<void> _abrirModalTesteMensagem(TipoMensagemCobranca tipo) async {
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
          selecionarParcela: _selecionarParcelaParaPreview,
          montarTags: _montarTagsCobranca,
          onEnviar: (telefone, mensagem) =>
              MensagemUtils.enviarMensagemTeste(context, telefone, mensagem),
        );
      },
    );
  }

  void _mostrarDialogPlano() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Funcionalidade indisponível"),
          content: const Text(
              "Seu plano atual não contempla o envio de mensagens por WhatsApp para cobranças automáticas. Deseja conhecer os planos disponíveis?"),
          actions: [
            TextButton(
              child: const Text("Agora não"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Ver planos"),
              onPressed: () {
                Navigator.of(context).pop(); // fecha o diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EscolherPlanoScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _salvarMensagens() async {
    final provider =
        Provider.of<MensagemCobrancaProvider>(context, listen: false);
    final mensagensAtualizadas = _controllers.entries.map((entry) {
      return MensagemCobranca(
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

  void _restaurarPadroes() async {
    final provider =
        Provider.of<MensagemCobrancaProvider>(context, listen: false);
    await provider.restaurarPadroes();
    if (provider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mensagens restauradas para os padrões."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      for (var msg in provider.mensagens) {
        _controllers[msg.tipo]?.text = msg.conteudo;
        _habilitado[msg.tipo] = msg.ativo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MensagemCobrancaProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensagens Automáticas"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.backgroundColor,
          unselectedLabelColor: const Color.fromARGB(255, 86, 156, 236),
          indicatorColor: AppTheme.accentColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Mensagens"),
            Tab(text: "Conectar WhatsApp"),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                AppBackground(
                  child: SafeArea(
                    bottom: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          Card(
                            color: Colors.grey[100],
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "🔖 Você pode usar os seguintes placeholders nas mensagens:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.label_outline, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              "{{nome}} → Nome do cliente")),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money_outlined,
                                          size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              "{{valor}} → Valor da parcela")),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.event_outlined, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              "{{data_vencimento}} → Data de vencimento da parcela")),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildMensagemCard(
                            tipo: TipoMensagemCobranca.antesVencimento,
                            titulo: "Antes do vencimento",
                            subtitulo:
                                "Enviada 1 dia antes do vencimento da parcela",
                          ),
                          _buildMensagemCard(
                            tipo: TipoMensagemCobranca.diaVencimento,
                            titulo: "No dia do vencimento",
                            subtitulo: "Enviada na data de vencimento",
                          ),
                          _buildMensagemCard(
                            tipo: TipoMensagemCobranca.dividaoQuitada,
                            titulo: "Contrato quitado",
                            subtitulo:
                                "Enviada quando o cliente quitar o contrato",
                          ),
                          _buildMensagemCard(
                            tipo: TipoMensagemCobranca.emAtraso,
                            titulo: "Em atraso",
                            subtitulo:
                                "Enviado todos os dias enquanto a parcela estiver em atraso",
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              empresaPodeUsarWhatsapp()
                                  ? OutlinedButton.icon(
                                      onPressed: _restaurarPadroes,
                                      icon: const Icon(Icons.restore),
                                      label: const Text("Restaurar Padrões"),
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomButton(
                                  text: "Salvar",
                                  enabled: empresaPodeUsarWhatsapp(),                                  
                                  onPressed: _salvarMensagens,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const AppBackground(child: VinculoWhatsappScreen()),
              ],
            ),
    );
  }

  void _onTagInsert(String tag) {
    if (_tipoSelecionado == null) return;

    final controller = _controllers[_tipoSelecionado!];
    if (controller == null) return;

    final selection = controller.selection;
    final newText = controller.text.replaceRange(
      selection.start,
      selection.end,
      tag,
    );

    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: selection.start + tag.length,
    );

    setState(() {}); // atualiza visual se necessário
  }
}
