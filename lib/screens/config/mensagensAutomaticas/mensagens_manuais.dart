import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/mensagem_manual.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/mensagens_manuais_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MensagensManuaisScreen extends StatefulWidget {
  const MensagensManuaisScreen({super.key});

  @override
  State<MensagensManuaisScreen> createState() => _MensagensManuaisScreenState();
}

class _MensagensManuaisScreenState extends State<MensagensManuaisScreen> {
  final Map<TipoMensagemManual, TextEditingController> _controllers = {};
  final Map<TipoMensagemManual, bool> _habilitado = {};
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

  Widget _buildMensagemCard({
    required TipoMensagemManual tipo,
    required String titulo,
    required String subtitulo,
  }) {
    final controller = _controllers[tipo] ?? TextEditingController();
    final ativo = _habilitado[tipo] ?? true;

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
                              _TagInfo(
                                icon: Icons.person_outline,
                                text: "{{nome}} → Nome do cliente",
                              ),
                              _TagInfo(
                                icon: Icons.confirmation_number_outlined,
                                text: "{{numeroParcela}} → Número da parcela",
                              ),
                              _TagInfo(
                                icon: Icons.attach_money_outlined,
                                text: "{{valorParcela}} → Valor da parcela",
                              ),
                              _TagInfo(
                                icon: Icons.account_balance_wallet_outlined,
                                text:
                                    "{{totalContasReceber}} → Valor total do contrato",
                              ),
                              _TagInfo(
                                icon: Icons.event_outlined,
                                text:
                                    "{{dataVencimento}} → Data de vencimento",
                              ),
                              _TagInfo(
                                icon: Icons.event_available_outlined,
                                text:
                                    "{{dataPagamento}} → Data do pagamento (baixa)",
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

class _TagInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TagInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
