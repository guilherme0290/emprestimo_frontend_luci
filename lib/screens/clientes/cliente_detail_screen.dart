import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/core/role.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/parametro.dart';
import 'package:emprestimos_app/models/parametro_vendedor.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/screens/clientes/cliente_create_screen.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_create_step1.dart';
import 'package:emprestimos_app/screens/score/score_list_screen.dart';
import 'package:emprestimos_app/widgets/custom_floating_action_button.dart';
import 'package:emprestimos_app/widgets/dialog_widget.dart';
import 'package:emprestimos_app/widgets/list_emprestimo_widget.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalhesContasReceber extends StatefulWidget {
  Cliente cliente;

  DetalhesContasReceber({super.key, required this.cliente});

  @override
  State<DetalhesContasReceber> createState() => _DetalhesClientePageState();
}

class _DetalhesClientePageState extends State<DetalhesContasReceber> {
  List<ContasReceberDTO> _emprestimos = [];
  bool isLoading = true;
  final parametrosCliente = <Parametro>[];
  List parametrosEmpresa = <Parametro>[];
  int _emprestimosEmAberto = 0;
  AuthProvider? _authProvider;
  bool _isVendedor = false;
  bool _podeCadastrarContasReceber = true;
  bool _carregandoPermissaoCadastro = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final provider =
          Provider.of<ContasReceberProvider>(context, listen: false);
      final parametroProvider =
          Provider.of<ParametroProvider>(context, listen: false);

      await Future.wait([
        _carregarContasReceber(),
        provider.buscarResumoCliente(widget.cliente.id!),
        _carregarParametrosCliente(widget.cliente.id!),
        parametroProvider.buscarParametrosEmpresa().then((value) {
          parametrosEmpresa = parametroProvider.parametrosEmpresa;
        }),
        _verificarPermissaoCadastroContasReceber(),
      ]);
    });
  }

  Future<void> _verificarPermissaoCadastroContasReceber() async {
    if (_authProvider == null) return;
    await _authProvider!.carregarDadosSalvos();
    if (!mounted) return;

    final roleStr = _authProvider!.loginResponse?.role ?? '';
    final roleEnum = Role.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => Role.EMPRESA,
    );

    final isVendedor = roleEnum == Role.VENDEDOR;
    setState(() {
      _isVendedor = isVendedor;
      _podeCadastrarContasReceber = !isVendedor;
      _carregandoPermissaoCadastro = isVendedor;
    });

    if (!isVendedor) return;
    if (_authProvider?.loginResponse?.usuario.id == null) {
      setState(() {
        _carregandoPermissaoCadastro = false;
        _podeCadastrarContasReceber = false;
      });
      return;
    }

    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);
    await parametroProvider
        .buscarParametrosVendedor(_authProvider!.loginResponse!.usuario.id);

    if (!mounted) return;

    final ParametroVendedor? parametro = parametroProvider.parametrosVendedor
        .where((p) => p.chave == 'PERMITIR_CADASTRO_CONTAS_RECEBER')
        .cast<ParametroVendedor?>()
        .firstWhere((p) => p != null, orElse: () => null);

    final bool permitido = parametro == null
        ? false
        : (parametro.valorConvertido is bool
            ? parametro.valorConvertido as bool
            : parametro.valor.toLowerCase() == 'true');

    setState(() {
      _podeCadastrarContasReceber = permitido;
      _carregandoPermissaoCadastro = false;
    });
  }

  void _mostrarPermissaoCadastroBloqueada() {
    MyAwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: "Permissão bloqueada",
      message:
          "O parâmetro não está habilitado para Nova Venda. Consulte o administrador ou solicite liberação na tela XX.",
      btnOkText: "Entendi",
    ).show();
  }

  Future<List<Parametro>> _carregarParametrosCliente(int clienteId) async {
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);

    await parametroProvider.buscarParametrosCliente(clienteId);

    final p1 =
        parametroProvider.buscarParametroPorChave("LIMITE_EMPRESTIMO_CLIENTE");
    if (p1 != null) {
      parametrosCliente.add(p1);
    } else {
      parametrosCliente.add(Parametro(
        chave: "LIMITE_EMPRESTIMO_CLIENTE",
        valor: "1",
        tipoReferencia: "CLIENTE",
        referenciaId: clienteId,
      ));
    }

    final p2 =
        parametroProvider.buscarParametroPorChave("LIMITE_CREDITO_CLIENTE");
    if (p2 != null) {
      final valor = double.tryParse(p2.valor) ?? 0.0;
      final formatador = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: '',
        decimalDigits: 2,
      );
      parametrosCliente.add(Parametro(
        chave: "LIMITE_CREDITO_CLIENTE",
        valor: formatador.format(valor), // já formatado para exibição
        tipoReferencia: "CLIENTE",
        referenciaId: clienteId,
      ));
    } else {
      parametrosCliente.add(Parametro(
        chave: "LIMITE_CREDITO_CLIENTE",
        valor: "0,00",
        tipoReferencia: "CLIENTE",
        referenciaId: clienteId,
      ));
    }

    final p3 =
        parametroProvider.buscarParametroPorChave("JUROS_PADRAO_CLIENTE");
    if (p3 != null) {
      parametrosCliente.add(p3);
    } else {
      parametrosCliente.add(Parametro(
        chave: "JUROS_PADRAO_CLIENTE",
        valor: "0",
        tipoReferencia: "CLIENTE",
        referenciaId: clienteId,
      ));
    }

    return parametrosCliente;
  }

  Future<void> _carregarContasReceber() async {
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);
    setState(() => isLoading = true);

    final lista = await provider.listarContasReceberCliente(widget.cliente.id!);

    setState(() {
      _emprestimos = lista;
      _emprestimosEmAberto =
          lista.where((e) => e.statusContasReceber != 'QUITADO').length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          final provider =
              Provider.of<ContasReceberProvider>(context, listen: false);
          await provider.buscarResumoCliente(widget.cliente.id!);
        },
        child: Scaffold(
          body: Column(
            children: [
              _buildClienteResumoHeader(widget.cliente),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: ListaContasReceberWidget(
                    contasreceber: _emprestimos,
                    onRefresh: _carregarContasReceber,
                    isLoading: isLoading,
                    exibirNomeCliente: false),
              ),
            ],
          ),
          floatingActionButton: Consumer<ParametroProvider>(
            builder: (context, parametroProvider, _) {
              final podeCriar = parametroProvider
                  .podeCriarNovoContasReceber(_emprestimosEmAberto);
              final podeCadastrar =
                  !_isVendedor || _podeCadastrarContasReceber;
              final podeAbrir = podeCriar &&
                  podeCadastrar &&
                  !_carregandoPermissaoCadastro;
              final podeMostrarBloqueio = podeCriar &&
                  _isVendedor &&
                  !_podeCadastrarContasReceber &&
                  !_carregandoPermissaoCadastro;

              return CustomFloatingActionButton(
                heroTag: "novo_emprestimo_fab",
                onPressed: podeAbrir
                    ? () {
                        // função síncrona que chama async sem retornar
                        _navegarParaCriarContasReceber();
                      }
                    : (podeMostrarBloqueio
                        ? _mostrarPermissaoCadastroBloqueada
                        : null),
                icon: Icons.add,
                label: "Nova Venda",
                backgroundColor:
                    podeAbrir ? Theme.of(context).primaryColor : Colors.grey,
              );
            },
          ),
        ));
  }

  Future<void> _navegarParaCriarContasReceber() async {
    final novoContasReceber = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContasReceberCreateStep1(cliente: widget.cliente),
      ),
    );

    if (novoContasReceber != null && novoContasReceber is ContasReceberDTO) {
      setState(() {
        _emprestimos.insert(0, novoContasReceber);
        _emprestimosEmAberto++;
      });
    }
  }

  Future<void> abrirNavegacaoGoogleMaps(String endereco) async {
    final url = Uri.encodeFull(
        'https://www.google.com/maps/dir/?api=1&destination=$endereco');

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o Google Maps para o endereço: $endereco';
    }
  }

  Widget _buildClienteResumoHeader(Cliente cliente) {
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);

    final saldoReceber = provider.resumoCliente?.totalReceber ?? 0;
    final int score = cliente.score ?? 0;
    final String scoreDescricao = cliente.scoreDescricao ?? "Sem Score";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    "${cliente.id}-${cliente.nome!}",
                    style: AppTheme.titleStyle.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_search,
                      color: Colors.white, size: 28),
                  onPressed: () async {
                    final clienteAtualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClienteFormScreen(cliente: cliente),
                      ),
                    );
                    setState(() {
                      if (clienteAtualizado != null &&
                          clienteAtualizado is Cliente) {
                        widget.cliente = clienteAtualizado;
                      }
                    });
                  },
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.navigation, color: Colors.white, size: 28),
              tooltip: 'Abrir no mapa',
              onPressed: () async {
                final endereco =
                    "${cliente.bairro}, ${cliente.rua}, ${cliente.numero}, ${cliente.cidadeNome}, ${cliente.estado}";
                if (endereco.isNotEmpty) {
                  await abrirNavegacaoGoogleMaps(endereco);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Endereço do cliente não informado")),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 🔹 Exibe o Score do Cliente e permite navegação para o histórico
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HistoricoScoreScreen(clienteId: cliente.id!),
                      ),
                    );
                  },
                  child: _buildInfoItem(
                      Icons.star,
                      "Score $score ($scoreDescricao)",
                      "$score",
                      scoreDescricao),
                ),
                provider.isLoading
                    ? const CircularProgressIndicator()
                    : _buildInfoItem(Icons.trending_up, "Total em Aberto",
                        Util.formatarMoeda(saldoReceber), ""),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, String descricao) {
    bool isScore = label.toLowerCase().contains("score");

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 26),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),

        // 🔹 Se for Score, exibe as bolinhas coloridas
        if (isScore)
          _buildScoreIndicator(descricao)
        else
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

// 🔹 Widget para exibir as bolinhas de Score
  Widget _buildScoreIndicator(String descricaoScore) {
    Color scoreColor;
    List<Color> colors = [
      Colors.grey[300]!,
      Colors.grey[300]!,
      Colors.grey[300]!
    ];

    if (descricaoScore == "otimo") {
      scoreColor = Colors.green;
      colors = [scoreColor, scoreColor, scoreColor]; // 🔹 Ótimo (tudo verde)
    } else if (descricaoScore == "bom") {
      scoreColor = Colors.orange;
      colors = [
        scoreColor,
        scoreColor,
        Colors.grey[300]!
      ]; // 🔹 Bom (duas laranjas)
    } else {
      scoreColor = Colors.red;
      colors = [
        scoreColor,
        Colors.grey[300]!,
        Colors.grey[300]!
      ]; // 🔹 Ruim (uma vermelha)
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle, color: colors[0], size: 12),
        const SizedBox(width: 4),
        Icon(Icons.circle, color: colors[1], size: 12),
        const SizedBox(width: 4),
        Icon(Icons.circle, color: colors[2], size: 12),
      ],
    );
  }
}
