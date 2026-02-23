import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/mensagem_cobranca.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/mensagens_cobranca_provider.dart';
import 'package:emprestimos_app/screens/config/mensagensAutomaticas/vincular_whatsapp_screen.dart';
import 'package:emprestimos_app/screens/planos/escolher_planos.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/mensagem_modelos_prontos_selector.dart';
import 'package:emprestimos_app/widgets/mensagem_tags_bottom_sheet.dart';
import 'package:emprestimos_app/widgets/mensagem_tags_quick_chips.dart';
import 'package:emprestimos_app/core/mensagem_utils.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
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
  final Map<TipoMensagemCobranca, String?> _modeloSelecionadoPorTipo = {};
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

  static const Map<TipoMensagemCobranca, List<MensagemModeloPronto>>
      _modelosProntosPorTipo = {
    TipoMensagemCobranca.antesVencimento: [
      MensagemModeloPronto(
        id: 'antes_1',
        titulo: '📅 Lembrete amigável',
        conteudo:
            '{{saudacao}}, {{primeiro_nome}}! 👋 Passando para lembrar que sua parcela {{numero_parcela}} no valor de {{valor_parcela}} vence em {{vencimento}}. Se precisar, estamos à disposição 😊',
      ),
      MensagemModeloPronto(
        id: 'antes_2',
        titulo: '🔔 Aviso objetivo',
        conteudo:
            'Olá {{nome}}. Lembrete: a parcela {{numero_parcela}} ({{valor_parcela}}) vence em {{vencimento}}. ✅',
      ),
      MensagemModeloPronto(
        id: 'antes_3',
        titulo: '📌 Com resumo do contrato',
        conteudo:
            '{{saudacao}}, {{nome}}.\nParcela {{progresso_parcela}} | Valor {{valor_parcela}} | Vencimento {{vencimento_extenso}}.\nQualquer dúvida, fale com {{cobrador}} 💬',
      ),
    ],
    TipoMensagemCobranca.diaVencimento: [
      MensagemModeloPronto(
        id: 'dia_1',
        titulo: '⏰ Vence hoje',
        conteudo:
            '{{saudacao}}, {{primeiro_nome}}! Sua parcela {{numero_parcela}} no valor de {{valor_parcela}} vence hoje ({{vencimento}}). Se já realizou o pagamento, desconsidere ✅',
      ),
      MensagemModeloPronto(
        id: 'dia_2',
        titulo: '📲 Confirmação de pagamento',
        conteudo:
            'Olá {{nome}}, a parcela {{numero_parcela}} ({{valor_parcela}}) vence hoje. Por favor, nos confirme o pagamento quando for realizado 🙏',
      ),
      MensagemModeloPronto(
        id: 'dia_3',
        titulo: '💰 Lembrete curto',
        conteudo:
            'Lembrete: parcela {{numero_parcela}} de {{valor_parcela}} vence hoje. Pagando hoje, seu contrato segue em dia ✅',
      ),
    ],
    TipoMensagemCobranca.emAtraso: [
      MensagemModeloPronto(
        id: 'apos_1',
        titulo: '⚠️ Cobrança amigável',
        conteudo:
            'Olá {{nome}} 👋 Identificamos a parcela {{numero_parcela}} ({{valor_parcela}}) em atraso desde {{vencimento}}. Se já pagou, desconsidere. Se precisar negociar, fale conosco 💬',
      ),
      MensagemModeloPronto(
        id: 'apos_2',
        titulo: '🚨 Cobrança com saldo',
        conteudo:
            'Prezado(a) {{nome}}, consta atraso na parcela {{numero_parcela}} no valor de {{valor_parcela}} (venc. {{vencimento}}).\nSaldo devedor atual: {{saldo_devedor}}.\nAguardamos seu retorno.',
      ),
      MensagemModeloPronto(
        id: 'apos_3',
        titulo: '📣 Regularização',
        conteudo:
            '{{saudacao}}, {{primeiro_nome}}. Temos {{parcelas_em_atraso}} parcela(s) em atraso.\nSaldo em atraso: {{saldo_em_atraso}}.\nPodemos te ajudar a regularizar ✅',
      ),
    ],
    TipoMensagemCobranca.dividaoQuitada: [
      MensagemModeloPronto(
        id: 'quitada_1',
        titulo: '🎉 Agradecimento',
        conteudo:
            '{{saudacao}}, {{nome}}! Recebemos o pagamento da parcela {{numero_parcela}} ✅\nValor pago: {{valor_pago}}\nObrigado por manter seu contrato em dia 🙌',
      ),
      MensagemModeloPronto(
        id: 'quitada_2',
        titulo: '🧾 Confirmação objetiva',
        conteudo:
            'Pagamento confirmado ✅\nParcela: {{numero_parcela}}\nValor pago: {{valor_pago}}\nData: {{data_pagamento}}',
      ),
      MensagemModeloPronto(
        id: 'quitada_3',
        titulo: '📈 Resumo financeiro',
        conteudo:
            'Olá {{primeiro_nome}}! Pagamento da parcela {{numero_parcela}} registrado com sucesso 🎉\nTotal pago: {{total_pago}}\nSaldo devedor: {{saldo_devedor}}',
      ),
    ],
  };

  List<MensagemModeloPronto> _modelosProntos(TipoMensagemCobranca tipo) {
    return _modelosProntosPorTipo[tipo] ?? const [];
  }

  String? _identificarModeloSelecionado(
    TipoMensagemCobranca tipo,
    String conteudo,
  ) {
    final texto = conteudo.trim();
    if (texto.isEmpty) return null;
    for (final m in _modelosProntos(tipo)) {
      if (m.conteudo.trim() == texto) return m.id;
    }
    return _modeloSelecionadoPorTipo[tipo];
  }

  Map<String, String> _tagsPreviewFake() {
    return {
      'nome': 'Maria Oliveira',
      'primeiro_nome': 'Maria',
      'saudacao': MensagemUtils.obterSaudacao(),
      'numero_parcela': '4',
      'valor_parcela': 'R\$ 185,00',
      'vencimento': '25/02/2026',
      'vencimento_extenso': '25 de fevereiro de 2026',
      'data_pagamento': '22/02/2026 14:35',
      'valor_pago': 'R\$ 185,00',
      'saldo_parcela': 'R\$ 0,00',
      'valor_total': 'R\$ 1.480,00',
      'contrato_id': '17452',
      'progresso_parcela': '4/5',
      'empresa': 'Financeira Central',
      'cobrador': 'Ana',
      'saldo_devedor': 'R\$ 740,00',
      'saldo_em_atraso': 'R\$ 185,00',
      'total_pago': 'R\$ 740,00',
      'parcelas_em_atraso': '1',
    };
  }

  Future<void> _previewModeloPronto(MensagemModeloPronto modelo) async {
    final textoFinal =
        MensagemUtils.aplicarTags(modelo.conteudo, _tagsPreviewFake());
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pré-visualização da mensagem',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Exemplo com dados fictícios para simular o envio ao cliente.',
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      textoFinal,
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

  Future<void> _abrirEditorMensagem(
    TipoMensagemCobranca tipo, {
    required StateSetter onStateChange,
  }) async {
    final controller =
        _controllers.putIfAbsent(tipo, TextEditingController.new);
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _MensagemAutomaticaEditorScreen(
          titulo: _tituloTipoMensagem(tipo),
          textoInicial: controller.text,
          accentColor: _corTipoMensagem(tipo),
          tipo: tipo,
          previewTags: _tagsPreviewFake(),
        ),
      ),
    );

    if (resultado == null || resultado.trim().isEmpty) return;
    onStateChange(() {
      controller.text = resultado.trim();
      _habilitado[tipo] = true;
    });
  }

  Color _corTipoMensagem(TipoMensagemCobranca tipo) {
    switch (tipo) {
      case TipoMensagemCobranca.antesVencimento:
        return Colors.blue;
      case TipoMensagemCobranca.diaVencimento:
        return Colors.orange;
      case TipoMensagemCobranca.emAtraso:
        return Colors.redAccent;
      case TipoMensagemCobranca.dividaoQuitada:
        return Colors.green;
    }
  }

  IconData _iconeTipoMensagem(TipoMensagemCobranca tipo) {
    switch (tipo) {
      case TipoMensagemCobranca.antesVencimento:
        return Icons.schedule_send_outlined;
      case TipoMensagemCobranca.diaVencimento:
        return Icons.event_available_outlined;
      case TipoMensagemCobranca.emAtraso:
        return Icons.notification_important_outlined;
      case TipoMensagemCobranca.dividaoQuitada:
        return Icons.verified_outlined;
    }
  }

  String _tituloTipoMensagem(TipoMensagemCobranca tipo) {
    switch (tipo) {
      case TipoMensagemCobranca.antesVencimento:
        return "1 dia antes do vencimento";
      case TipoMensagemCobranca.diaVencimento:
        return "No dia do vencimento";
      case TipoMensagemCobranca.emAtraso:
        return "Após o vencimento";
      case TipoMensagemCobranca.dividaoQuitada:
        return "Parcela quitada";
    }
  }

  String _subtituloTipoMensagem(TipoMensagemCobranca tipo) {
    switch (tipo) {
      case TipoMensagemCobranca.antesVencimento:
        return "Mensagens enviadas automaticamente 1 dia antes do vencimento da parcela";
      case TipoMensagemCobranca.diaVencimento:
        return "Mensagens enviadas automaticamente no dia do vencimento";
      case TipoMensagemCobranca.emAtraso:
        return "Mensagens enviadas automaticamente após o vencimento";
      case TipoMensagemCobranca.dividaoQuitada:
        return "Mensagens enviadas automaticamente quando a parcela for quitada";
    }
  }

  void _abrirConfiguracaoTipo(TipoMensagemCobranca tipo) {
    final accent = _corTipoMensagem(tipo);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatefulBuilder(
          builder: (context, setRouteState) => Scaffold(
            appBar: AppBar(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              title: Text(_tituloTipoMensagem(tipo)),
            ),
            body: AppBackground(
              child: SafeArea(
                bottom: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMensagemCard(
                        tipo: tipo,
                        titulo: _tituloTipoMensagem(tipo),
                        subtitulo: _subtituloTipoMensagem(tipo),
                        onStateChange: setRouteState,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Salvar esta mensagem',
                        enabled: empresaPodeUsarWhatsapp(),
                        onPressed: _salvarMensagens,
                        backgroundColor: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildAcessoTipoCard(TipoMensagemCobranca tipo,
      {required bool enabled}) {
    final accent = _corTipoMensagem(tipo);
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled
                ? () => _abrirConfiguracaoTipo(tipo)
                : _mostrarDialogPlano,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Icon(_iconeTipoMensagem(tipo), color: accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tituloTipoMensagem(tipo),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtituloTipoMensagem(tipo),
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.62),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMensagemCard({
    required TipoMensagemCobranca tipo,
    required String titulo,
    required String subtitulo,
    required StateSetter onStateChange,
  }) {
    final controller =
        _controllers.putIfAbsent(tipo, () => TextEditingController());
    final ativo = _habilitado[tipo] ?? true;
    final scheme = Theme.of(context).colorScheme;
    final accent = _corTipoMensagem(tipo);
    final modelos = _modelosProntos(tipo);
    final modeloSelecionadoId =
        _identificarModeloSelecionado(tipo, controller.text);
    MensagemModeloPronto? modeloSelecionado;
    for (final m in modelos) {
      if (m.id == modeloSelecionadoId) {
        modeloSelecionado = m;
        break;
      }
    }
    final podePersonalizar =
        modeloSelecionado != null || controller.text.trim().isNotEmpty;
    final resumoMensagemSelecionada = controller.text.trim().isEmpty
        ? ''
        : controller.text
            .trim()
            .replaceAll('\n', ' ')
            .replaceAll(RegExp(r'\s+'), ' ');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ativo
              ? accent.withValues(alpha: 0.22)
              : scheme.outline.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: (ativo ? accent : Colors.black)
                .withValues(alpha: ativo ? 0.10 : 0.03),
            blurRadius: ativo ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconeTipoMensagem(tipo),
                      color: accent,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitulo,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.62),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: (ativo ? accent : Colors.grey)
                          .withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      ativo ? 'Ativa' : 'Desativada',
                      style: TextStyle(
                        color: ativo ? accent : Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.12),
                      ),
                    ),
                    child: SwitchListTile(
                      value: ativo,
                      onChanged: (value) {
                        if (!empresaPodeUsarWhatsapp()) {
                          _mostrarDialogPlano();
                          return;
                        }
                        onStateChange(() => _habilitado[tipo] = value);
                      },
                      activeColor: accent,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      title: const Text(
                        'Ativar mensagem',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Desative para usar o padrão do sistema.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  MensagemModelosProntosSelector(
                    accentColor: accent,
                    modelos: modelos,
                    modeloSelecionadoId: modeloSelecionadoId,
                    onPreviewModelo: _previewModeloPronto,
                    onAplicarModelo: (modelo) {
                      onStateChange(() {
                        controller.text = modelo.conteudo;
                        _habilitado[tipo] = true;
                        _modeloSelecionadoPorTipo[tipo] = modelo.id;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                !podePersonalizar
                                    ? 'Escolha um modelo'
                                    : 'Mensagem',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.72),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                key: ValueKey(
                                  'preview_msg_${tipo.name}_${resumoMensagemSelecionada.hashCode}',
                                ),
                                initialValue: !podePersonalizar
                                    ? 'Nenhum modelo'
                                    : (resumoMensagemSelecionada.isEmpty
                                        ? (modeloSelecionado?.titulo ??
                                            'Modelo selecionado')
                                        : resumoMensagemSelecionada),
                                readOnly: true,
                                enabled: false,
                                minLines: 3,
                                maxLines: 4,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: podePersonalizar
                                      ? Colors.black.withValues(alpha: 0.78)
                                      : Colors.black.withValues(alpha: 0.45),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor:
                                      Colors.white.withValues(alpha: 0.9),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: accent.withValues(alpha: 0.14),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: !podePersonalizar
                              ? null
                              : () => _abrirEditorMensagem(
                                    tipo,
                                    onStateChange: onStateChange,
                                  ),
                          tooltip: 'Editar mensagem',
                          style: IconButton.styleFrom(
                            foregroundColor: accent,
                            backgroundColor: accent.withValues(alpha: 0.08),
                            disabledForegroundColor:
                                Colors.black.withValues(alpha: 0.28),
                            disabledBackgroundColor:
                                Colors.black.withValues(alpha: 0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool empresaPodeUsarWhatsapp() {
    return _empresa?.plano?.incluiWhatsapp ?? false;
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MensagemCobrancaProvider>(context);
    final scheme = Theme.of(context).colorScheme;
    final podeWhatsapp = empresaPodeUsarWhatsapp();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensagens Automáticas"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Mensagens"),
                Tab(text: "Conectar WhatsApp"),
              ],
            ),
          ),
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primary.withValues(alpha: 0.16),
                                  Colors.green.withValues(alpha: 0.10),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: scheme.primary.withValues(alpha: 0.14),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome_outlined,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        "Ao vincular o WhatsApp, o app passa a enviar cobranças automaticamente no dia do vencimento, 1 dia antes e quando a parcela estiver em atraso. Você pode personalizar as mensagens abaixo usando as tags disponíveis.",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _CobrancaInfoPill(
                                      icon: Icons.message_outlined,
                                      label: '4 mensagens',
                                      color: Colors.blue,
                                    ),
                                    _CobrancaInfoPill(
                                      icon: Icons.schedule_outlined,
                                      label: 'Envios automáticos',
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!podeWhatsapp) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
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
                                  Icon(Icons.lock_outline,
                                      color: Colors.orange),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Seu plano atual não contempla mensagens automáticas via WhatsApp.",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildAcessoTipoCard(
                            TipoMensagemCobranca.antesVencimento,
                            enabled: podeWhatsapp,
                          ),
                          _buildAcessoTipoCard(
                            TipoMensagemCobranca.diaVencimento,
                            enabled: podeWhatsapp,
                          ),
                          _buildAcessoTipoCard(
                            TipoMensagemCobranca.emAtraso,
                            enabled: podeWhatsapp,
                          ),
                          _buildAcessoTipoCard(
                            TipoMensagemCobranca.dividaoQuitada,
                            enabled: podeWhatsapp,
                          ),
                          const SizedBox(height: 20),
                          if (podeWhatsapp)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: scheme.outline.withValues(alpha: 0.08),
                                ),
                              ),
                              child: const Text(
                                'Escolha uma opção para configurar.',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
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

class _MensagemAutomaticaEditorScreen extends StatefulWidget {
  final String titulo;
  final String textoInicial;
  final Color accentColor;
  final TipoMensagemCobranca tipo;
  final Map<String, String> previewTags;

  const _MensagemAutomaticaEditorScreen({
    required this.titulo,
    required this.textoInicial,
    required this.accentColor,
    required this.tipo,
    required this.previewTags,
  });

  @override
  State<_MensagemAutomaticaEditorScreen> createState() =>
      _MensagemAutomaticaEditorScreenState();
}

class _MensagemAutomaticaEditorScreenState
    extends State<_MensagemAutomaticaEditorScreen> {
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
    switch (widget.tipo) {
      case TipoMensagemCobranca.antesVencimento:
        return Icons.schedule_send_outlined;
      case TipoMensagemCobranca.diaVencimento:
        return Icons.event_available_outlined;
      case TipoMensagemCobranca.emAtraso:
        return Icons.notification_important_outlined;
      case TipoMensagemCobranca.dividaoQuitada:
        return Icons.verified_outlined;
    }
  }

  String get _contatoNome {
    switch (widget.tipo) {
      case TipoMensagemCobranca.antesVencimento:
        return 'Cliente (lembrete)';
      case TipoMensagemCobranca.diaVencimento:
        return 'Cliente (vence hoje)';
      case TipoMensagemCobranca.emAtraso:
        return 'Cliente (cobrança)';
      case TipoMensagemCobranca.dividaoQuitada:
        return 'Cliente (pagamento)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        title: Text('Editar: ${widget.titulo}'),
      ),
      body: AppBackground(
        child: SafeArea(
          bottom: true,
          child: Padding(
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
                          ? 'Digite sua mensagem...'
                          : MensagemUtils.aplicarTags(
                              value.text,
                              widget.previewTags,
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
                            'Tags',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MensagemTagsQuickChips(
                        accentColor: accent,
                        onTagTap: _inserirTag,
                        onMoreTagsTap: _abrirTodasTags,
                        moreLabel: 'Mais',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
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
    );
  }
}

class _CobrancaInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CobrancaInfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
