import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/mensagem_cobranca.dart';
import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/mensagens_cobranca_provider.dart';
import 'package:emprestimos_app/screens/config/mensagensAutomaticas/vincular_whatsapp_screen.dart';
import 'package:emprestimos_app/screens/planos/escolher_planos.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/placeholdertag.dart';
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

  Widget _buildMensagemCard({
    required TipoMensagemCobranca tipo,
    required String titulo,
    required String subtitulo,
  }) {
    final controller = _controllers[tipo] ?? TextEditingController();
    final ativo = _habilitado[tipo] ?? true;
    final isExpanded = _isExpanded[tipo] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (val) => setState(() => _isExpanded[tipo] = val),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitulo,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
        children: ativo
            ? [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      PlaceholderTagsWidget(onTagInsert: _onTagInsert),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        maxLines: null,
                        onTap: () {
                          setState(() => _tipoSelecionado = tipo);
                        },
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
                ),
              ]
            : [],
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
                          if (!empresaPodeUsarWhatsapp()) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock, color: Colors.orange),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      "O envio automático de mensagens por WhatsApp está disponível apenas para planos com suporte a essa funcionalidade.",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const EscolherPlanoScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text("Ver planos"),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
