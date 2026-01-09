import 'package:emprestimos_app/core/role.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/cidade.dart';
import 'package:emprestimos_app/models/parametro.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/cidade_provider.dart';
import 'package:emprestimos_app/providers/cliente_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/cidade_dropdown.dart';
import 'package:emprestimos_app/widgets/currency_formatter.dart';
import 'package:emprestimos_app/widgets/dialog_solicitacao_aprovacao_parametro.dart';
import 'package:emprestimos_app/widgets/input_field.dart';
import 'package:emprestimos_app/widgets/uf_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/theme.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ClienteFormScreen extends StatefulWidget {
  Cliente? cliente;

  ClienteFormScreen({this.cliente, Key? key}) : super(key: key);

  @override
  _ClienteFormScreenState createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();

//Aba informações Pessoais
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ruaController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();

  //Aba Parametros
  final TextEditingController limiteContasReceberController =
      TextEditingController();
  final TextEditingController limiteCreditoController = TextEditingController();
  final TextEditingController jurosPadraoController = TextEditingController();
  final TextEditingController valorMultaDiariaController =
      TextEditingController();

  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

// 🔹 Máscara para CEP (00000-000)
  final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

// 🔹 Máscara para Telefone (com e sem DDD)
  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool isLoading = false;
  int? _cidadeSelecionada;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _isEmpresa = false;
  bool _statusAtivo = true;

  String? ufSelecionada;
  List<Cidade> cidades = [];
  Cidade? cidadeSelecionada;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });

    Future.microtask(() {
      _verificarTipoUsuario();
    });

    if (widget.cliente != null) {
      nomeController.text = widget.cliente?.nome ?? "";
      cpfController.text = widget.cliente?.cpf ?? "";
      telefoneController.text = widget.cliente?.telefone ?? "";
      emailController.text = widget.cliente?.email ?? "";
      ruaController.text = widget.cliente?.rua ?? "";
      bairroController.text = widget.cliente?.bairro ?? "";
      cepController.text = widget.cliente?.cep ?? "";
      complementoController.text = widget.cliente?.complemento ?? "";
      numeroController.text = widget.cliente?.numero ?? "";
      _cidadeSelecionada = widget.cliente?.cidadeId;
      _statusAtivo = (widget.cliente?.status ?? "ATIVO") == "ATIVO";

      if (_cidadeSelecionada != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _carregarCidadeInicial(_cidadeSelecionada!);
          }
        });
      }
    }
  }

  Future<void> _carregarCidadeInicial(int cidadeId) async {
    final provider = Provider.of<CidadeProvider>(context, listen: false);

    final cidade = await provider.buscarCidadesById(cidadeId);

    if (cidade != null) {
      setState(() {
        cidadeSelecionada = cidade;
        ufSelecionada = cidade.uf;
      });
    }
  }

  Future<void> _verificarTipoUsuario() async {
    final authProvider =
        await Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isEmpresa = authProvider.role == Role.EMPRESA;
    });
  }

  void _salvarParametrosCliente() async {
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);

    await parametroProvider.atualizarParametro(
      Parametro(
        id: parametroProvider
            .buscarParametroPorChave("LIMITE_EMPRESTIMO_CLIENTE")
            ?.id,
        chave: "LIMITE_EMPRESTIMO_CLIENTE",
        valor: limiteContasReceberController.text,
        tipoReferencia: "CLIENTE",
        referenciaId: widget.cliente!.id!,
      ),
    );

    double valor = Util.removerMascaraValor(limiteCreditoController.text);
    await parametroProvider.atualizarParametro(
      Parametro(
        id: parametroProvider
            .buscarParametroPorChave("LIMITE_CREDITO_CLIENTE")
            ?.id,
        chave: "LIMITE_CREDITO_CLIENTE",
        valor: valor.toString(),
        tipoReferencia: "CLIENTE",
        referenciaId: widget.cliente!.id!,
      ),
    );

    await parametroProvider.atualizarParametro(
      Parametro(
        id: parametroProvider
            .buscarParametroPorChave("JUROS_PADRAO_CLIENTE")
            ?.id,
        chave: "JUROS_PADRAO_CLIENTE",
        valor: jurosPadraoController.text,
        tipoReferencia: "CLIENTE",
        referenciaId: widget.cliente!.id!,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Parâmetros atualizados com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _carregarParametrosCliente(int clienteId) async {
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);

    await parametroProvider.buscarParametrosCliente(clienteId);

    limiteContasReceberController.text = parametroProvider
            .buscarParametroPorChave("LIMITE_EMPRESTIMO_CLIENTE")
            ?.valor ??
        '1';

    final parametro = parametroProvider
            .buscarParametroPorChave("LIMITE_CREDITO_CLIENTE")
            ?.valor ??
        "0.00";

    final valor = double.tryParse(parametro) ?? 0.0;

    final formatador = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );

    limiteCreditoController.text =
        formatador.format(valor); // Exemplo: "1.600,00"

    jurosPadraoController.text = parametroProvider
            .buscarParametroPorChave("JUROS_PADRAO_CLIENTE")
            ?.valor ??
        "0.0";
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    ruaController.dispose();
    bairroController.dispose();
    cepController.dispose();
    complementoController.dispose();
    numeroController.dispose();
    cidadeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _salvarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ClienteProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    int? vendedorId;
    if (authProvider.loginResponse?.role == "VENDEDOR") {
      vendedorId = authProvider.loginResponse!.usuario.id;
    }

    Cliente novoCliente = Cliente(
      id: widget.cliente?.id,
      cpf: Util.removerMascara(cpfController.text),
      nome: nomeController.text,
      rua: ruaController.text,
      telefone: Util.removerMascara(telefoneController.text),
      email: emailController.text,
      bairro: bairroController.text,
      cep: Util.removerMascara(cepController.text),
      complemento: complementoController.text,
      numero: numeroController.text,
      cidadeId: _cidadeSelecionada ?? cidadeSelecionada?.id,
      vendedorId: vendedorId,
      status: _statusAtivo ? "ATIVO" : "INATIVO",
    );

    if (widget.cliente == null) {
      // Cadastro novo
      bool sucesso = await provider.criarCliente(novoCliente);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cliente salvo com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? "Erro ao salvar Cliente"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Atualização
      Cliente? clienteAtualizado = await provider.atualizarCliente(novoCliente);
      if (clienteAtualizado != null) {
        setState(() {
          widget.cliente = clienteAtualizado;
          _statusAtivo = (clienteAtualizado.status ?? "ATIVO") == "ATIVO";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cliente atualizado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, clienteAtualizado);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? "Erro ao atualizar Cliente"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClienteProvider>(context);

    return DefaultTabController(
      length: widget.cliente == null ? 1 : 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.cliente == null ? "Novo Cliente" : "Editar Cliente",
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          iconTheme: Theme.of(context).appBarTheme.iconTheme,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: Theme.of(context).appBarTheme.elevation,
          shadowColor: Theme.of(context).appBarTheme.shadowColor,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontFamily: 'Poppins',
            ),
            indicatorColor: AppTheme.accentColor,
            indicatorWeight: 3.5,
            tabs: [
              const Tab(text: 'Informações Pessoais'),
              if (widget.cliente != null) const Tab(text: 'Parâmetros'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInformacoesPessoais(context, provider),
            if (widget.cliente != null) _buildParametros(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacoesPessoais(
      BuildContext context, ClienteProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: AppBackground(
          child: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSectionTitle("Informações Pessoais"),
                  SwitchListTile(
                    title: const Text("Status do Cliente"),
                    subtitle: Text(_statusAtivo ? "Ativo" : "Inativo"),
                    value: _statusAtivo,
                    onChanged: (novoStatus) {
                      setState(() {
                        _statusAtivo = novoStatus;
                      });
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                  InputCustomizado(
                      controller: nomeController,
                      labelText: "Nome Completo",
                      leadingIcon: const Icon(Icons.person,
                          color: AppTheme.primaryColor),
                      validator: (value) =>
                          value!.isEmpty ? "Campo obrigatório" : null),
                  const SizedBox(height: 10),
                  InputCustomizado(
                    controller: cpfController,
                    labelText: "CPF",
                    type: TextInputType.number,
                    leadingIcon: const Icon(Icons.credit_card,
                        color: AppTheme.primaryColor),
                    inputFormatters: [cpfFormatter],
                    validator: (value) => Util.isCpfCnpjValid(
                        cpfController.text,
                        obrigatorio: false),
                  ),
                  const SizedBox(height: 10),
                  InputCustomizado(
                      controller: telefoneController,
                      labelText: "Telefone",
                      type: TextInputType.number,
                      leadingIcon:
                          const Icon(Icons.phone, color: AppTheme.primaryColor),
                      inputFormatters: [telefoneFormatter],
                      validator: (value) =>
                          value!.isEmpty ? "Campo obrigatório" : null),
                  const SizedBox(height: 10),
                  InputCustomizado(
                    controller: emailController,
                    labelText: "E-mail",
                    type: TextInputType.emailAddress,
                    leadingIcon:
                        const Icon(Icons.email, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle("Endereço"),
                  _buildFieldCep(),
                  InputCustomizado(
                    controller: ruaController,
                    labelText: "Rua",
                    leadingIcon: const Icon(Icons.location_on,
                        color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  InputCustomizado(
                    controller: bairroController,
                    labelText: "Bairro",
                    leadingIcon:
                        const Icon(Icons.home, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  UfDropdown(
                    selectedUf: ufSelecionada,
                    onUfSelecionada: (uf) {
                      setState(() {
                        ufSelecionada = uf;
                        cidadeSelecionada = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  CidadeDropdown(
                    key: ValueKey(ufSelecionada),
                    uf: ufSelecionada,
                    selectedCidade: cidadeSelecionada,
                    onCidadeSelecionada: (cidade) {
                      cidadeSelecionada = cidade;
                      _cidadeSelecionada = cidade.id;
                    },
                  ),
                  const SizedBox(height: 10),
                  InputCustomizado(
                    controller: complementoController,
                    labelText: "Complemento",
                    leadingIcon: const Icon(Icons.add_location_alt,
                        color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  InputCustomizado(
                    controller: numeroController,
                    labelText: "Número",
                    type: TextInputType.number,
                    leadingIcon: const Icon(Icons.format_list_numbered,
                        color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  provider.isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: "Salvar Cliente",
                          onPressed: _salvarCliente,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool permitirMulta = false;

  Widget _buildParametros(BuildContext context) {
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);

    final bool isPendenteJurosPadrao = parametroProvider
            .buscarParametroPorChave("JUROS_PADRAO_CLIENTE")
            ?.isPendente ??
        false;
    final bool isPendenteLimiteContasReceber = parametroProvider
            .buscarParametroPorChave("LIMITE_EMPRESTIMO_CLIENTE")
            ?.isPendente ??
        false;
    final bool isPendenteLimiteCredito = parametroProvider
            .buscarParametroPorChave("LIMITE_CREDITO_CLIENTE")
            ?.isPendente ??
        false;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppBackground(
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSectionTitle("Parâmetros do Cliente"),

                /// LIMITE_EMPRESTIMO_CLIENTE
                InputCustomizado(
                  controller: limiteContasReceberController,
                  labelText: "Máximo de contratos em aberto para este cliente",
                  type: TextInputType.number,
                  readOnly: !_isEmpresa,
                  enabled: !isPendenteLimiteContasReceber,
                  leadingIcon: const Icon(Icons.attach_money,
                      color: AppTheme.primaryColor),
                  onTap: _isEmpresa
                      ? null
                      : () => _solicitarAlteracaoParametro(
                            chave: "LIMITE_EMPRESTIMO_CLIENTE",
                            valorAtual: limiteContasReceberController.text,
                          ),
                ),
                if (isPendenteLimiteContasReceber) _buildLabelPendente(),

                const SizedBox(height: 10),

                /// LIMITE_CREDITO_CLIENTE
                InputCustomizado(
                  controller: limiteCreditoController,
                  labelText: "Limite de Crédito deste cliente",
                  type: TextInputType.number,
                  inputFormatters: [CurrencyFormatter()],
                  readOnly: !_isEmpresa,
                  enabled: !isPendenteLimiteCredito,
                  leadingIcon:
                      const Icon(Icons.money_off, color: AppTheme.primaryColor),
                  onTap: _isEmpresa
                      ? null
                      : () => _solicitarAlteracaoParametro(
                            chave: "LIMITE_CREDITO_CLIENTE",
                            valorAtual: limiteCreditoController.text,
                          ),
                ),
                if (isPendenteLimiteCredito) _buildLabelPendente(),

                const SizedBox(height: 10),

                InputCustomizado(
                  controller: jurosPadraoController,
                  labelText: "Juros Padrão deste cliente (%)",
                  type: TextInputType.number,
                  readOnly: !_isEmpresa,
                  enabled: !isPendenteJurosPadrao,
                  inputFormatters: [
                    CurrencyInputFormatter(
                      leadingSymbol: '',
                      useSymbolPadding: false,
                      mantissaLength: 1,
                      thousandSeparator: ThousandSeparator.None,
                    )
                  ],
                  leadingIcon:
                      const Icon(Icons.percent, color: AppTheme.primaryColor),
                  onTap: _isEmpresa
                      ? null
                      : () => _solicitarAlteracaoParametro(
                            chave: "JUROS_PADRAO_CLIENTE",
                            valorAtual: jurosPadraoController.text,
                          ),
                ),
                if (isPendenteJurosPadrao) _buildLabelPendente(),

                const SizedBox(height: 20),

                if (_isEmpresa)
                  CustomButton(
                    text: "Salvar Parâmetros",
                    onPressed: _salvarParametrosCliente,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelPendente() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            "Pendente de autorização",
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[800],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  TextFormField _buildFieldCep() {
    final theme = Theme.of(context);

    final effectiveBorderColor =
        _hasFocus ? theme.colorScheme.primary : Colors.grey.shade400;
    final borderSide = BorderSide(
      color: effectiveBorderColor,
      width: _hasFocus ? 3 : 1.5,
    );

    return TextFormField(
      controller: cepController,
      inputFormatters: [cepFormatter],
      decoration: InputDecoration(
          labelText: "CEP",
          prefixIcon: const Icon(Icons.local_post_office),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), borderSide: borderSide),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), borderSide: borderSide),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), borderSide: borderSide),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          prefixIconColor: theme.primaryColor,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
          hintText: 'Cep'),
      keyboardType: TextInputType.number,
      maxLength: 9,
      onChanged: (value) {
        if (value.length == 9) {
          _buscarCep(); // Chama a função automaticamente ao completar 8 dígitos
        }
      },
      // validator: (value) {
      //   if (value == null || value.isEmpty) return "Obrigatório";
      //   if (value.length < 8) return "CEP inválido";
      //   return null;
      // },
    );
  }

  void _buscarCep() async {
    final cep = cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length == 8) {
      final clienteProvider =
          Provider.of<ClienteProvider>(context, listen: false);
      final cidadeProvider =
          Provider.of<CidadeProvider>(context, listen: false);

      final endereco = await clienteProvider.buscarCep(cep);

      if (endereco != null) {
        // atualiza rua e bairro diretamente
        setState(() {
          ruaController.text = endereco["logradouro"] ?? "";
          bairroController.text = endereco["bairro"] ?? "";
        });

        final nomeCidade = endereco["cidade"];
        final uf = endereco["uf"];

        if (nomeCidade != null && uf != null) {
          // define a UF primeiro
          setState(() {
            ufSelecionada = uf;
            cidadeSelecionada = null;
            _cidadeSelecionada = null;
          });

          await cidadeProvider.buscarCidadesPorUf(uf);

          // encontra cidade pelo nome
          final cidadeEncontrada = cidadeProvider.cidades.firstWhere(
            (cidade) => cidade.nome.toLowerCase() == nomeCidade.toLowerCase(),
            orElse: () => Cidade(id: -1, nome: "Cidade não encontrada", uf: uf),
          );

          if (cidadeEncontrada.id != -1) {
            setState(() {
              cidadeSelecionada = cidadeEncontrada;
              _cidadeSelecionada = cidadeEncontrada.id;
            });
          } else {
            setState(() {
              cidadeSelecionada = null;
              _cidadeSelecionada = null;
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CEP não encontrado!")),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: AppTheme.titleStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🔹 Campo de dropdown para cidades

  void _solicitarAlteracaoParametro({
    required String chave,
    required String valorAtual,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => DialogSolicitarAlteracaoParametro(
        chave: chave,
        valorAtual: valorAtual,
        onEnviar: (novoValor) async {
          await _enviarSolicitacaoAprovacao(chave, novoValor);
        },
      ),
    );
  }

  Future<void> _enviarSolicitacaoAprovacao(
      String chave, String novoValor) async {
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);
    final parametro = parametroProvider.buscarParametroPorChave(chave);
    final usuarioId = Provider.of<AuthProvider>(context, listen: false)
        .loginResponse!
        .usuario
        .id;

    if (parametro != null) {
      await parametroProvider.solicitarAprovacao(
        parametroId: parametro.id!,
        novoValor: novoValor,
        usuarioId: usuarioId,
        clienteId: widget.cliente!.id!,
      );
    }

    // 🔁 Recarrega parâmetros atualizados do cliente
    await _carregarParametrosCliente(widget.cliente!.id!);
    setState(() {});
  }
}
