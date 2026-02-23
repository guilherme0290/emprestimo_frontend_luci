import 'package:emprestimos_app/core/mensagem_utils.dart';
import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/mensagem_manual.dart';
import 'package:emprestimos_app/models/mensagem_manual_template.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/mensagens_manuais_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/mensagem_tags_bottom_sheet.dart';
import 'package:emprestimos_app/widgets/mensagem_tags_quick_chips.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MensagensManuaisScreen extends StatefulWidget {
  const MensagensManuaisScreen({super.key});

  @override
  State<MensagensManuaisScreen> createState() => _MensagensManuaisScreenState();
}

class _MensagensManuaisScreenState extends State<MensagensManuaisScreen> {
  Empresa? _empresa;
  bool _loadingEmpresa = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarEmpresa());
  }

  Future<void> _carregarEmpresa() async {
    await Provider.of<EmpresaProvider>(context, listen: false)
        .buscarEmpresaById(null);
    if (!mounted) return;
    setState(() {
      _empresa = Provider.of<EmpresaProvider>(context, listen: false).empresa;
      _loadingEmpresa = false;
    });
  }

  bool _empresaPodeUsarWhatsapp() {
    return _empresa?.plano?.incluiWhatsapp ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final podeUsarWhatsapp = _empresaPodeUsarWhatsapp();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mensagens Manuais')),
      body: _loadingEmpresa
          ? const Center(child: CircularProgressIndicator())
          : AppBackground(
              child: SafeArea(
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              scheme.primary.withValues(alpha: 0.18),
                              scheme.secondary.withValues(alpha: 0.12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: scheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Escolha qual mensagem deseja configurar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Selecione um modelo pronto e personalize apenas se quiser.',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _TipoMensagemCard(
                        icon: Icons.price_check,
                        accentColor: Colors.green,
                        title: 'Definir mensagem padrão ao baixar parcela',
                        subtitle:
                            'Escolha entre modelos prontos para confirmação de pagamento.',
                        enabled: podeUsarWhatsapp,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ConfigurarMensagemTipoScreen(
                                tipo: TipoMensagemManual.baixaParcela,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _TipoMensagemCard(
                        icon: Icons.chat,
                        accentColor: Colors.orange,
                        title: 'Definir mensagem padrão para cobrança',
                        subtitle:
                            'Escolha entre modelos prontos para cobrar parcelas pendentes.',
                        enabled: podeUsarWhatsapp,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ConfigurarMensagemTipoScreen(
                                tipo: TipoMensagemManual.cobrancaAtraso,
                              ),
                            ),
                          );
                        },
                      ),
                      if (!podeUsarWhatsapp)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Seu plano atual não contempla envio via WhatsApp.',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
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

class ConfigurarMensagemTipoScreen extends StatefulWidget {
  final TipoMensagemManual tipo;

  const ConfigurarMensagemTipoScreen({
    super.key,
    required this.tipo,
  });

  @override
  State<ConfigurarMensagemTipoScreen> createState() =>
      _ConfigurarMensagemTipoScreenState();
}

class _ConfigurarMensagemTipoScreenState
    extends State<ConfigurarMensagemTipoScreen> {
  bool _isLoading = true;
  String? _erro;
  bool _ativo = true;
  String? _templateSelecionadoId;
  String? _templateExpandidoId;
  String? _conteudoPersonalizado;
  List<MensagemManualTemplate> _templates = const [];
  final Map<String, ExpansibleController> _expansionControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  String get _tituloTela {
    return widget.tipo == TipoMensagemManual.baixaParcela
        ? 'Mensagem de baixa'
        : 'Mensagem de cobrança';
  }

  Color get _accentColor {
    return widget.tipo == TipoMensagemManual.baixaParcela
        ? Colors.green
        : Colors.orange;
  }

  IconData get _accentIcon {
    return widget.tipo == TipoMensagemManual.baixaParcela
        ? Icons.price_check_outlined
        : Icons.chat_bubble_outline;
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final provider = Provider.of<MensagensManuaisProvider>(
        context,
        listen: false,
      );

      await provider.buscarMensagens();
      final templates = await provider.buscarTemplatesPorTipo(widget.tipo);
      final atual = _mensagemAtual(provider.mensagens);

      if (templates.isEmpty) {
        setState(() {
          _erro = 'Nenhum template disponível para este tipo.';
          _isLoading = false;
        });
        return;
      }

      final templatePorId = atual?.templateId;
      MensagemManualTemplate? selecionado;

      if (templatePorId != null && templatePorId.isNotEmpty) {
        selecionado = templates.where((t) => t.id == templatePorId).firstOrNull;
      }

      if (selecionado == null && (atual?.conteudo.trim().isNotEmpty ?? false)) {
        selecionado = templates
            .where((t) => t.conteudo.trim() == atual!.conteudo.trim())
            .firstOrNull;
      }

      selecionado ??= templates.first;

      final conteudoCustom = atual == null
          ? null
          : (atual.conteudo.trim() == selecionado.conteudo.trim()
              ? null
              : atual.conteudo);

      setState(() {
        _templates = templates;
        _ativo = atual?.ativo ?? true;
        _templateSelecionadoId = selecionado!.id;
        _templateExpandidoId = selecionado.id;
        _conteudoPersonalizado = conteudoCustom;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar configurações: $e';
        _isLoading = false;
      });
    }
  }

  MensagemManual? _mensagemAtual(List<MensagemManual> mensagens) {
    for (final m in mensagens) {
      if (m.tipo == widget.tipo) return m;
    }
    return null;
  }

  MensagemManualTemplate get _templateSelecionado {
    for (final t in _templates) {
      if (t.id == _templateSelecionadoId) return t;
    }
    return _templates.first;
  }

  bool get _temPersonalizada {
    return (_conteudoPersonalizado ?? '').trim().isNotEmpty;
  }

  ExpansibleController _controllerTemplate(String id) {
    return _expansionControllers.putIfAbsent(id, ExpansibleController.new);
  }

  void _aoAlterarExpansaoTemplate(String templateId, bool expandido) {
    if (expandido) {
      final anteriorId = _templateExpandidoId;
      if (anteriorId != null && anteriorId != templateId) {
        _expansionControllers[anteriorId]?.collapse();
      }
      setState(() {
        _templateExpandidoId = templateId;
        _templateSelecionadoId = templateId;
        _conteudoPersonalizado = null;
      });
      return;
    }

    if (_templateExpandidoId == templateId) {
      setState(() => _templateExpandidoId = null);
    }
  }

  void _mostrarToastSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarToastErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _salvarTemplatePadrao() async {
    if (_templates.isEmpty) return;

    final provider = Provider.of<MensagensManuaisProvider>(
      context,
      listen: false,
    );

    if (_temPersonalizada) {
      await provider.salvarMensagemPersonalizada(
        tipo: widget.tipo,
        conteudo: (_conteudoPersonalizado ?? _templateSelecionado.conteudo).trim(),
        ativo: _ativo,
        templateId: _templateSelecionadoId,
      );
    } else {
      await provider.salvarTemplatePadrao(
        tipo: widget.tipo,
        template: _templateSelecionado,
        ativo: _ativo,
      );
    }

    if (!mounted) return;
    if (provider.errorMessage != null) {
      _mostrarToastErro(provider.errorMessage!);
      return;
    }

    if (_temPersonalizada) {
      _mostrarToastSucesso('Mensagem personalizada salva com sucesso.');
    } else {
      setState(() {
        _conteudoPersonalizado = null;
      });
      _mostrarToastSucesso('Template padrão atualizado com sucesso.');
    }
  }

  Future<void> _editarTemplate(MensagemManualTemplate template) async {
    final usaConteudoPersonalizado =
        _temPersonalizada && _templateSelecionadoId == template.id;
    final textoInicial = usaConteudoPersonalizado
        ? (_conteudoPersonalizado ?? template.conteudo)
        : template.conteudo;

    setState(() {
      _templateSelecionadoId = template.id;
    });

    final novoConteudo = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => MensagemManualEditorScreen(
          titulo: _tituloTela,
          textoInicial: textoInicial,
          accentColor: _accentColor,
          tipo: widget.tipo,
        ),
      ),
    );

    if (novoConteudo == null || novoConteudo.trim().isEmpty || !mounted) return;

    final provider = Provider.of<MensagensManuaisProvider>(
      context,
      listen: false,
    );

    await provider.salvarMensagemPersonalizada(
      tipo: widget.tipo,
      conteudo: novoConteudo.trim(),
      ativo: _ativo,
      templateId: template.id,
    );

    if (!mounted) return;
    if (provider.errorMessage != null) {
      _mostrarToastErro(provider.errorMessage!);
      return;
    }

    setState(() {
      _templateSelecionadoId = template.id;
      _conteudoPersonalizado = novoConteudo.trim();
    });

    _mostrarToastSucesso('Mensagem personalizada salva com sucesso.');
  }

  Map<String, String> _tagsExemplo() {
    return {
      'nome': 'Maria da Silva',
      'primeiro_nome': 'Maria',
      'saudacao': 'Boa tarde',
      'numero_parcela': '3',
      'valor_parcela': 'R\$ 180,00',
      'vencimento': '25/02/2026',
      'vencimento_extenso': '25 de fevereiro de 2026',
      'data_pagamento': '22/02/2026 14:35',
      'valor_pago': 'R\$ 120,00',
      'saldo_parcela': 'R\$ 60,00',
      'valor_total': 'R\$ 1.200,00',
      'contrato_id': '10234',
      'progresso_parcela': '3/8',
      'empresa': 'Financeira Exemplo',
      'cobrador': 'Joao',
      'saldo_devedor': 'R\$ 840,00',
      'saldo_em_atraso': 'R\$ 240,00',
      'total_pago': 'R\$ 360,00',
      'parcelas_em_atraso': '2',
    };
  }

  String _conteudoExemplo(MensagemManualTemplate template) {
    final usaPersonalizado =
        _temPersonalizada && _templateSelecionadoId == template.id;
    final base = usaPersonalizado
        ? (_conteudoPersonalizado ?? template.conteudo)
        : template.conteudo;
    return MensagemUtils.aplicarTags(base, _tagsExemplo());
  }

  Future<void> _abrirPreviewTemplate(MensagemManualTemplate template) async {
    final exemplo = _conteudoExemplo(template);
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Exemplo da mensagem final',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Preview com dados fictícios para simular o envio ao cliente.',
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      exemplo,
                      style: const TextStyle(height: 1.35),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _restaurarPadrao() async {
    final provider = Provider.of<MensagensManuaisProvider>(
      context,
      listen: false,
    );
    await provider.restaurarPadrao(
      tipo: widget.tipo,
      template: _templateSelecionado,
      ativo: _ativo,
    );

    if (!mounted) return;
    if (provider.errorMessage != null) {
      _mostrarToastErro(provider.errorMessage!);
      return;
    }

    setState(() {
      _conteudoPersonalizado = null;
    });

    _mostrarToastSucesso('Mensagem restaurada para o padrão.');
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        title: Text(_tituloTela),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_erro!, textAlign: TextAlign.center),
                  ),
                )
              : AppBackground(
                  child: SafeArea(
                    bottom: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _accentIcon,
                                    color: accent,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Selecione um modelo pronto entre 10 opções. Toque para expandir e ver o conteúdo completo.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._templates.map(
                            (template) {
                              final selecionado =
                                  template.id == _templateSelecionadoId;
                              final personalizadoSelecionado =
                                  selecionado && _temPersonalizada;
                              final conteudoExibicao =
                                  personalizadoSelecionado
                                      ? (_conteudoPersonalizado ??
                                          template.conteudo)
                                      : template.conteudo;
                              return _TemplateOpcaoCard(
                                key: ValueKey(
                                  'manual_${template.id}_${conteudoExibicao.hashCode}_${personalizadoSelecionado}',
                                ),
                                controller: _controllerTemplate(template.id),
                                accentColor: accent,
                                template: template,
                                conteudoExibicao: conteudoExibicao,
                                personalizado: personalizadoSelecionado,
                                selecionado: selecionado,
                                onTap: () {
                                  setState(() {
                                    _templateSelecionadoId = template.id;
                                    _conteudoPersonalizado = null;
                                  });
                                },
                                onExpansionChanged: (expandido) =>
                                    _aoAlterarExpansaoTemplate(
                                  template.id,
                                  expandido,
                                ),
                                onEdit: () => _editarTemplate(template),
                                onPreview: () => _abrirPreviewTemplate(template),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _StatusCard(
                            accentColor: accent,
                            tituloTemplate: _templateSelecionado.titulo,
                            personalizada: _temPersonalizada,
                            ativo: _ativo,
                            onToggleAtivo: (value) =>
                                setState(() => _ativo = value),
                          ),
                          const SizedBox(height: 14),
                          CustomButton(
                            text: _temPersonalizada
                                ? 'Salvar mensagem personalizada'
                                : 'Salvar template padrão',
                            onPressed: _salvarTemplatePadrao,
                          ),
                          if (_temPersonalizada)
                            TextButton(
                              onPressed: _restaurarPadrao,
                              child: const Text('Voltar ao padrão'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class MensagemManualEditorScreen extends StatefulWidget {
  final String titulo;
  final String textoInicial;
  final Color accentColor;
  final TipoMensagemManual tipo;

  const MensagemManualEditorScreen({
    super.key,
    required this.titulo,
    required this.textoInicial,
    required this.accentColor,
    required this.tipo,
  });

  @override
  State<MensagemManualEditorScreen> createState() =>
      _MensagemManualEditorScreenState();
}

class _MensagemManualEditorScreenState
    extends State<MensagemManualEditorScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textoInicial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _inserirTag(String tag) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final novoTexto = text.replaceRange(start, end, tag);
    _controller.value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: start + tag.length),
    );
  }

  void _abrirTodasTags() {
    showMensagemTagsBottomSheet(
      context: context,
      accentColor: widget.accentColor,
      onTagSelected: _inserirTag,
    );
  }

  IconData get _tipoIcone {
    return widget.tipo == TipoMensagemManual.baixaParcela
        ? Icons.price_check_outlined
        : Icons.chat_bubble_outline;
  }

  String get _contatoNome {
    return widget.tipo == TipoMensagemManual.baixaParcela
        ? 'Cliente (baixa)'
        : 'Cliente (cobrança)';
  }

  Map<String, String> _tagsPreviewFake() {
    final agora = DateTime.now();
    final data = '${agora.day.toString().padLeft(2, '0')}/'
        '${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    final dataHora = '$data '
        '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    return {
      'nome': 'Maria Oliveira',
      'primeiro_nome': 'Maria',
      'saudacao': MensagemUtils.obterSaudacao(),
      'numero_parcela': '4',
      'valor_parcela': 'R\$ 185,00',
      'vencimento': '28/02/2026',
      'vencimento_extenso': '28 de fevereiro de 2026',
      'data_pagamento': dataHora,
      'valor_pago': 'R\$ 185,00',
      'saldo_parcela': 'R\$ 0,00',
      'valor_total': 'R\$ 1.480,00',
      'contrato_id': '17452',
      'progresso_parcela': '4/8',
      'empresa': 'Financeira Central',
      'cobrador': 'Ana',
      'saldo_devedor': 'R\$ 740,00',
      'saldo_em_atraso': 'R\$ 185,00',
      'total_pago': 'R\$ 740,00',
      'parcelas_em_atraso': '1',
    };
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final editorHeight =
        (MediaQuery.of(context).size.height * (bottomInset > 0 ? 0.28 : 0.34))
            .clamp(220.0, 340.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        title: Text('Editar: ${widget.titulo}'),
      ),
      body: AppBackground(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: accent.withValues(alpha: 0.16),
                        foregroundColor: accent,
                        child: Icon(_tipoIcone, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _contatoNome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pré-visualização do WhatsApp',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.lock_outline, size: 16, color: accent),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEEDF).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.10),
                    ),
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, value, __) {
                      final texto = value.text.trim().isEmpty
                          ? 'Digite sua mensagem personalizada...'
                          : MensagemUtils.aplicarTags(
                              value.text,
                              _tagsPreviewFake(),
                            );
                      final isPlaceholder = value.text.trim().isEmpty;

                      return Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          constraints: const BoxConstraints(maxWidth: 320),
                          padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7FFDB),
                            borderRadius: BorderRadius.circular(14).copyWith(
                              bottomRight: const Radius.circular(4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  texto,
                                  style: TextStyle(
                                    height: 1.35,
                                    color: isPlaceholder
                                        ? Colors.black45
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '14:35',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sell_outlined,
                            size: 18,
                            color: accent,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Tags disponíveis',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MensagemTagsQuickChips(
                        accentColor: accent,
                        onTagTap: _inserirTag,
                        onMoreTagsTap: _abrirTodasTags,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: editorHeight,
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    scrollPadding: const EdgeInsets.only(bottom: 120),
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem personalizada...',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.88),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: accent.withValues(alpha: 0.18)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: accent, width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final conteudo = _controller.text.trim();
                          if (conteudo.isEmpty) return;
                          Navigator.pop(context, conteudo);
                        },
                        child: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _TipoMensagemCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _TipoMensagemCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = accentColor.withValues(alpha: enabled ? 0.10 : 0.06);
    final borderColor = accentColor.withValues(alpha: enabled ? 0.25 : 0.12);

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.96),
              bgColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.62),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateOpcaoCard extends StatelessWidget {
  final ExpansibleController controller;
  final Color accentColor;
  final MensagemManualTemplate template;
  final String conteudoExibicao;
  final bool personalizado;
  final bool selecionado;
  final VoidCallback onTap;
  final ValueChanged<bool> onExpansionChanged;
  final VoidCallback onEdit;
  final VoidCallback onPreview;

  const _TemplateOpcaoCard({
    super.key,
    required this.controller,
    required this.accentColor,
    required this.template,
    required this.conteudoExibicao,
    required this.personalizado,
    required this.selecionado,
    required this.onTap,
    required this.onExpansionChanged,
    required this.onEdit,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlight = accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              selecionado ? highlight : scheme.outline.withValues(alpha: 0.08),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (selecionado ? highlight : Colors.black)
                .withValues(alpha: selecionado ? 0.10 : 0.03),
            blurRadius: selecionado ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          controller: controller,
          key: ValueKey('template_${template.id}'),
          initiallyExpanded: selecionado,
          collapsedBackgroundColor:
              selecionado ? highlight.withValues(alpha: 0.04) : null,
          backgroundColor: highlight.withValues(alpha: 0.03),
          iconColor: highlight,
          collapsedIconColor: Colors.black54,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          onExpansionChanged: (expandido) {
            if (expandido) onTap();
            onExpansionChanged(expandido);
          },
          title: Row(
            children: [
              Icon(
                selecionado ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selecionado ? highlight : Colors.black38,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: selecionado
                    ? Container(
                        key: const ValueKey('badge_ativo'),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: highlight.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                              personalizado ? 'Personalizado' : 'Ativo',
                          style: TextStyle(
                            color: highlight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('badge_empty')),
              ),
            ],
          ),
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: highlight.withValues(alpha: selecionado ? 0.06 : 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: highlight.withValues(alpha: selecionado ? 0.10 : 0.06),
                ),
              ),
              child: Text(
                conteudoExibicao,
                style: const TextStyle(height: 1.3),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPreview,
                    icon: const Icon(Icons.preview_outlined),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: highlight,
                      backgroundColor: highlight.withValues(alpha: 0.06),
                      side: BorderSide(
                        color: highlight.withValues(alpha: 0.24),
                      ),
                    ),
                    label: Text(
                      selecionado ? 'Ver exemplo' : 'Pré-visualizar',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: highlight,
                      side: BorderSide(
                        color: highlight.withValues(alpha: 0.20),
                      ),
                    ),
                    label: const Text('Editar modelo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Color accentColor;
  final String tituloTemplate;
  final bool personalizada;
  final bool ativo;
  final ValueChanged<bool> onToggleAtivo;

  const _StatusCard({
    required this.accentColor,
    required this.tituloTemplate,
    required this.personalizada,
    required this.ativo,
    required this.onToggleAtivo,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = !ativo
        ? Colors.grey
        : (personalizada ? Colors.deepOrange : accentColor);

    final statusTexto = !ativo
        ? 'Status: usando padrão do sistema (configuração desativada)'
        : (personalizada
            ? 'Status: usando versão personalizada'
            : 'Status: usando padrão do template');
    final statusIcone = !ativo
        ? Icons.pause_circle_outline
        : (personalizada ? Icons.edit_note : Icons.verified_outlined);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.10),
            scheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CheckboxListTile(
              value: ativo,
              onChanged: (value) => onToggleAtivo(value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              dense: true,
              activeColor: scheme.primary,
              checkColor: Colors.white,
              title: const Text(
                'Usar mensagem configurada',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Desmarque para usar o texto padrão do sistema.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: Row(
              key: ValueKey('${ativo}_$personalizada'),
              children: [
                Icon(
                  statusIcone,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text('Template selecionado: $tituloTemplate')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey('status_chip_${ativo}_$personalizada'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusTexto,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstWhereOrNullExt<E> on Iterable<E> {
  E? get firstOrNull {
    for (final e in this) {
      return e;
    }
    return null;
  }
}
