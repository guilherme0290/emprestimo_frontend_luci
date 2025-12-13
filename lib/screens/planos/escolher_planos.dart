import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emprestimos_app/core/storage_service.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/providers/compra_provider.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/providers/planos_provider.dart';
import 'package:emprestimos_app/screens/auth/login_screen.dart';
import 'package:emprestimos_app/screens/planos/cadastro_empresa.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/dialog_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EscolherPlanoScreen extends StatefulWidget {
  const EscolherPlanoScreen({super.key});

  @override
  State<EscolherPlanoScreen> createState() => _EscolherPlanoScreenState();
}

class _EscolherPlanoScreenState extends State<EscolherPlanoScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int selectedIndex = 0;
  List<Plano> _planos = [];
  bool _isLoading = true;
  String? _error;
  List<String> _frasesPersuasivas = [];

  int? _empresaTemporariaId;
  bool _planoAtivo = false;
  Plano? planoEscolhidoNoCadastro;

  @override
  void initState() {
    super.initState();
    _carregarPlanos();
    _verificarEmpresa();
    final contextValue = context;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final empresaProvider =
          Provider.of<EmpresaProvider>(contextValue, listen: false);
      if (!kIsWeb) {
        final compraProvider =
            Provider.of<CompraProvider>(context, listen: false);
        compraProvider.setEmpresaProvider(empresaProvider);
      }
    });
  }

  Future<void> _verificarEmpresa() async {
    final id = await StorageService.getEmpresaTemporariaId();

    if (id == null) return;

    final provider = Provider.of<EmpresaProvider>(context, listen: false);

    if (provider.empresa != null && provider.empresa!.id == id) {
      _empresaTemporariaId = provider.empresa!.id;
      _planoAtivo = provider.empresa!.planoAtivo;
    } else {
      await provider.buscarEmpresaById(id);
      if (provider.empresa != null) {
        _empresaTemporariaId = provider.empresa!.id;
        _planoAtivo = provider.empresa!.planoAtivo;
      } else {
        _empresaTemporariaId = null;
        _planoAtivo = false;
      }
    }

    final planoProvider = Provider.of<PlanoProvider>(context, listen: false);
    await planoProvider
        .getPlanoByEmpresaId(_empresaTemporariaId!)
        .then((value) {
      planoEscolhidoNoCadastro = planoProvider.planoSelecionado!;
    });

    setState(() {});
  }

  Future<void> _carregarPlanos() async {
    final provider = PlanoProvider();
    final sucesso = await provider.fetchPlanos();
    if (sucesso) {
      setState(() {
        _planos = provider.planos;
        _frasesPersuasivas = _planos.map((p) => p.descricao).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = provider.errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresaProvider = Provider.of<EmpresaProvider>(context);
    final empresa = empresaProvider.empresa;
    final bool planoInativo = empresa != null && empresa.planoAtivo;

    return Consumer<CompraProvider>(builder: (context, compraProvider, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (compraProvider.assinaturaVinculadaComSucesso) {
          MyAwesomeDialog(
                  dialogType: DialogType.success,
                  context: context,
                  btnOkText: 'Ir para Login',
                  onOkPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  },
                  title: "Plano Vinculado com sucesso !✅",
                  message:
                      'Agora você pode acessar todos os recursos do plano escolhido.')
              .show();
          compraProvider.limparStatus();
        }
      });

      return Scaffold(
          appBar: AppBar(
            title: const Text("Escolha seu plano"),
          ),
          body: AppBackground(
            child: SafeArea(
              bottom: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_empresaTemporariaId != null && !planoInativo)
                    _buildAvisoPlanoInativo(),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Planos de Assinatura",
                      style: AppTheme.titleStyle,
                    ),
                  ),
                  _buildPageViewPlanos(),
                  if (!_isLoading && _frasesPersuasivas.isNotEmpty)
                    _buildFrasesPersuasivas(),
                  _buildInfoWhatsApp(),
                ],
              ),
            ),
          ));
    });
  }

  Widget _buildInfoWhatsApp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Notificações automáticas via WhatsApp",
                  style: AppTheme.bodyStyle,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text("Como funcionam as notificações?"),
                        content: const Text(
                          "Com essa funcionalidade, sua empresa poderá enviar mensagens automáticas personalizadas para seus clientes nos seguintes casos:\n\n"
                          "- Nova venda realizado\n"
                          "- Parcelas prestes a vencer\n"
                          "- Parcelas vencidas\n"
                          "- Vendas quitadas\n\n"
                          "Essa opção está inclusa nos planos com '+ WhatsApp'.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Entendi"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "O que é isso?",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrasesPersuasivas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppTheme.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _frasesPersuasivas[selectedIndex],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageViewPlanos() {
    return SizedBox(
      height: 360, // ajuste aqui conforme o tamanho desejado do card
      child: PageView.builder(
        controller: _pageController,
        itemCount: _planos.length,
        onPageChanged: (index) => setState(() => selectedIndex = index),
        itemBuilder: (context, index) {
          return _buildPlanoCard(context, _planos[index]);
        },
      ),
    );
  }

  Widget _buildAvisoPlanoInativo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _abrirBottomSheetAtivacao(null),
              child: Text(
                "Você ainda não ativou seu plano.\nToque aqui para ativar agora.",
                style: TextStyle(
                  color: Colors.red.shade800,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _abrirBottomSheetAtivacao(Plano? plano) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Ativação de Plano",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                  "Para concluir o cadastro da sua empresa, é necessário ativar sua assinatura na Google Play."),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _iniciarAssinaturaGooglePlay(plano),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("Ativar assinatura"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _iniciarAssinaturaGooglePlay(Plano? plano) async {
    Plano? planoSelecionado;
    if (plano != null) {
      planoSelecionado = plano;
    } else {
      final provider = Provider.of<PlanoProvider>(context, listen: false);
      await provider.getPlanoByEmpresaId(_empresaTemporariaId!).then((value) {
        planoSelecionado = provider.planoSelecionado!;
      });
    }

    if (planoSelecionado != null) {
      final productId = planoSelecionado!.productIdGooglePlay;
      final response =
          await InAppPurchase.instance.queryProductDetails({productId!});
      final produto = response.productDetails.first;
      final param = PurchaseParam(productDetails: produto);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      Navigator.pop(context);
    }
  }

  Widget _buildPlanoCard(BuildContext context, Plano plano) {
    final isCustom = plano.nome.toLowerCase().contains('custom');
    final nomePlano = plano.nome.toLowerCase();

    final gradient = () {
      if (nomePlano.contains('grátis') || nomePlano.contains('gratuito')) {
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF556270)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      } else if (nomePlano.contains('básico') || nomePlano.contains('basico')) {
        return const LinearGradient(
          colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      } else if (nomePlano.contains('premium')) {
        return const LinearGradient(
          colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      } else if (nomePlano.contains('custom')) {
        return const LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      } else {
        return const LinearGradient(
          colors: [Colors.grey, Colors.blueGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }();

    return Container(
      height: 320,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plano.nome,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              plano.preco > 0
                  ? 'R\$ ${plano.preco.toStringAsFixed(2)}/mês'
                  : 'Sob consulta',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ...plano.beneficios.map((item) => Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                  ],
                )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                ),
                onPressed: () {
                  final empresaProvider =
                      Provider.of<EmpresaProvider>(context, listen: false);

                  if (isCustom) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Plano Custom"),
                        content: const Text(
                            "Entre em contato com nosso time comercial para personalizar seu plano."),
                        actions: [
                          TextButton(
                              onPressed: () {
                                final url = Uri.parse(
                                    "https://wa.me/5567992917356?text=Olá, tenho interesse no Plano Custom.");
                                launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                                return;
                              },
                              child: const Text("Chamar no WhatsApp")),
                        ],
                      ),
                    );
                    return;
                  }

                  final empresaCadastrada = empresaProvider.empresa != null;
                  final planoCadastrado = planoEscolhidoNoCadastro;

                  if (empresaCadastrada && planoCadastrado != null) {
                    final mesmoPlano = plano.id == planoCadastrado.id;

                    if (mesmoPlano) {
                      _abrirBottomSheetAtivacao(plano);
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          titlePadding:
                              const EdgeInsets.fromLTRB(24, 24, 24, 12),
                          contentPadding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 20),
                          title: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Empresa cadastrada",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 15),
                                  children: [
                                    const TextSpan(
                                        text:
                                            "Você já cadastrou sua empresa com o plano "),
                                    TextSpan(
                                      text:
                                          "'${planoEscolhidoNoCadastro!.nome}'",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          " de R\$ ${planoEscolhidoNoCadastro!.preco.toStringAsFixed(2)}.\n\n",
                                    ),
                                    const TextSpan(
                                        text: "Agora você selecionou o plano "),
                                    TextSpan(
                                      text: "'${plano.nome}'",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          " de R\$ ${plano.preco.toStringAsFixed(2)}.\n\n",
                                    ),
                                    const TextSpan(
                                      text:
                                          "Deseja ativar o plano original ou trocar para o novo?",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancelar"),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _abrirBottomSheetAtivacao(
                                    planoEscolhidoNoCadastro);
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(
                                  "Ativar '${planoEscolhidoNoCadastro!.nome}'"),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                empresaProvider
                                    .alterarPlanoEmpresa(plano)
                                    .then((value) {
                                  PlanoProvider().getPlanoByEmpresaId(
                                      _empresaTemporariaId!);
                                });

                                _abrirBottomSheetAtivacao(plano);
                              },
                              icon: const Icon(Icons.swap_horiz),
                              label: Text("Trocar para '${plano.nome}'"),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CadastroEmpresaScreen(plano: plano),
                      ),
                    ).then((_) {
                      _verificarEmpresa();
                    });
                  }
                },
                child: Text(isCustom ? "Solicitar contato" : "Assinar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
