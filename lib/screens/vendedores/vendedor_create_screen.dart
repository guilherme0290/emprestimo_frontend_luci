import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/cidade.dart';
import 'package:emprestimos_app/models/parametro_vendedor.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/cidade_provider.dart';
import 'package:emprestimos_app/providers/cliente_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/screens/vendedores/vendedor_inativacao.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/dialog_widget.dart';
import 'package:emprestimos_app/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/theme.dart';
import '../../core/role.dart';

class VendedorFormScreen extends StatefulWidget {
  final Vendedor? vendedor;

  const VendedorFormScreen({this.vendedor, Key? key}) : super(key: key);

  @override
  _VendedorFormScreenState createState() => _VendedorFormScreenState();
}

class _VendedorFormScreenState extends State<VendedorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hasFocus = false;
  bool _statusAtivo = true;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ruaController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool isLoading = false;
  int? _cidadeSelecionada;
  bool _isEmpresa = true;
  int? _usuarioId;

  bool _isLoadingPermissoes = false;
  String? _permissoesError;
  List<ParametroVendedor> _permissoes = [];
  int? _permissaoAtualizadaId;
  bool _empresaPermiteTodosClientes = false;

  static const Map<String, String> _permissaoLabels = {
    "PERMITIR_CADASTRO_CLIENTE": "Permitir cadastrar cliente",
    "PERMITIR_CADASTRO_CONTAS_RECEBER": "Permite criar contas a receber",
    "PERMITIR_VENDEDOR_ACESSAR_TODOS_CLIENTES":
        "Este vendedor pode ver todos os clientes",
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CidadeProvider>(context, listen: false).carregarCidades();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarContextoUsuario();
      if (widget.vendedor?.id != null) {
        _carregarPermissoes();
      }
    });

    if (widget.vendedor != null) {
      nomeController.text = widget.vendedor?.nome ?? "";
      cpfController.text = widget.vendedor?.cpf ?? "";
      telefoneController.text = widget.vendedor?.telefone ?? "";
      emailController.text = widget.vendedor?.email ?? "";
      ruaController.text = widget.vendedor?.rua ?? "";
      bairroController.text = widget.vendedor?.bairro ?? "";
      cepController.text = widget.vendedor?.cep ?? "";
      complementoController.text = widget.vendedor?.complemento ?? "";
      numeroController.text = widget.vendedor?.numero ?? "";
      _cidadeSelecionada = widget.vendedor?.cidadeId;
      _statusAtivo = widget.vendedor?.status == "ATIVO";
    }
  }

  void _carregarContextoUsuario() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isEmpresa = authProvider.role == Role.EMPRESA;
      _usuarioId = authProvider.loginResponse?.usuario.id;
    });
  }

  Future<void> _carregarPermissoes() async {
    if (widget.vendedor?.id == null) return;
    setState(() {
      _isLoadingPermissoes = true;
      _permissoesError = null;
    });

    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);
    await parametroProvider.buscarParametrosVendedor(widget.vendedor!.id!);
    await parametroProvider.buscarParametrosEmpresa();

    if (!mounted) return;

    final parametroEmpresa = parametroProvider.buscarParametroEmpresaChave(
        "PERMITIR_VENDEDOR_ACESSAR_TODOS_CLIENTES_EMPRESA");
    final empresaPermite =
        parametroEmpresa?.valor.toLowerCase() == 'true';

    setState(() {
      _permissoes = parametroProvider.parametrosVendedor;
      _permissoesError = parametroProvider.errorMessage;
      _empresaPermiteTodosClientes = empresaPermite;
      _isLoadingPermissoes = false;
    });
  }

  bool _valorPermissao(ParametroVendedor parametro) {
    final convertido = parametro.valorConvertido;
    if (convertido is bool) return convertido;
    return parametro.valor.toLowerCase() == 'true';
  }

  String _labelPermissao(String chave) {
    return _permissaoLabels[chave] ?? chave;
  }

  int _ordemPermissao(String chave) {
    final chaves = _permissaoLabels.keys.toList();
    final idx = chaves.indexOf(chave);
    return idx == -1 ? 999 : idx;
  }

  ParametroVendedor _comValor(
    ParametroVendedor parametro,
    bool novoValor, {
    bool? pendente,
  }) {
    return ParametroVendedor(
      id: parametro.id,
      chave: parametro.chave,
      valor: novoValor.toString(),
      valorConvertido: novoValor,
      parametroPendente: pendente ?? parametro.parametroPendente,
    );
  }

  void _atualizarPermissaoLocal(int id, ParametroVendedor atualizado) {
    _permissoes = _permissoes
        .map((parametro) => parametro.id == id ? atualizado : parametro)
        .toList();
  }

  void _marcarPermissaoAtualizada(int parametroId) {
    setState(() {
      _permissaoAtualizadaId = parametroId;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_permissaoAtualizadaId == parametroId) {
        setState(() {
          _permissaoAtualizadaId = null;
        });
      }
    });
  }

  Future<void> _alterarPermissao(
    ParametroVendedor parametro,
    bool novoValor,
  ) async {
    if (parametro.parametroPendente) return;

    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);

    if (_isEmpresa) {
      final antigoValor = _valorPermissao(parametro);
      setState(() {
        _atualizarPermissaoLocal(
          parametro.id,
          _comValor(parametro, novoValor),
        );
      });

      final sucesso = await parametroProvider.atualizarParametroDireto(
        parametroId: parametro.id,
        valor: novoValor,
      );

      if (!mounted) return;

      if (!sucesso) {
        setState(() {
          _atualizarPermissaoLocal(
            parametro.id,
            _comValor(parametro, antigoValor),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao atualizar permissão."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permissão atualizada com sucesso."),
          backgroundColor: Colors.green,
        ),
      );
      _marcarPermissaoAtualizada(parametro.id);
      await _carregarPermissoes();
    } else {
      if (_usuarioId == null) return;
      final sucesso = await parametroProvider.solicitarAprovacaoVendedor(
        parametroId: parametro.id,
        novoValor: novoValor,
        usuarioId: _usuarioId!,
      );

      if (!mounted) return;

      if (!sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao solicitar aprovação."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Solicitação enviada com sucesso."),
          backgroundColor: Colors.green,
        ),
      );
      _marcarPermissaoAtualizada(parametro.id);
      await _carregarPermissoes();
    }
  }

  void _salvarVendedor() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<VendedorProvider>(context, listen: false);

    Vendedor novoVendedor = Vendedor(
      id: widget.vendedor?.id,
      cpf: Util.removerMascara(cpfController.text),
      nome: nomeController.text,
      rua: ruaController.text,
      telefone: Util.removerMascara(telefoneController.text),
      email: emailController.text,
      bairro: bairroController.text,
      cep: Util.removerMascara(cepController.text),
      complemento: complementoController.text,
      numero: numeroController.text,
      cidadeId: _cidadeSelecionada,
      password: senhaController.text.isNotEmpty ? senhaController.text : null,
      status: _statusAtivo ? "ATIVO" : "INATIVO",
    );

    Vendedor? vendedorSalvo;

    if (widget.vendedor == null) {
      vendedorSalvo = await provider.criarVendedor(novoVendedor);
    } else {
      vendedorSalvo = await provider.atualizarVendedor(novoVendedor);
    }

    if (!mounted) return;

    if (vendedorSalvo != null) {
      // Se você quiser pode manter o setState nos controllers, mas não é obrigatório
      setState(() {
        nomeController.text = _safe(vendedorSalvo!.nome);
        cpfController.text = _safeMasked(vendedorSalvo.cpf, cpfFormatter);
        telefoneController.text =
            _safeMasked(vendedorSalvo.telefone, telefoneFormatter);
        emailController.text = _safe(vendedorSalvo.email);
        ruaController.text = _safe(vendedorSalvo.rua);
        bairroController.text = _safe(vendedorSalvo.bairro);
        cepController.text = _safeMasked(vendedorSalvo.cep, cepFormatter);
        complementoController.text = _safe(vendedorSalvo.complemento);
        numeroController.text = _safe(vendedorSalvo.numero);

        _cidadeSelecionada = vendedorSalvo.cidadeId;
        _statusAtivo = (vendedorSalvo.status ?? "ATIVO") == "ATIVO";
      });

      if (widget.vendedor == null) {
        // criado
        MyAwesomeDialog(
          dialogType: DialogType.success,
          context: context,
          btnOkText: 'Ok',
          onOkPressed: () {
            Navigator.pop(context,
                vendedorSalvo); // devolve o Vendedor para a tela anterior
          },
          title: "Vendedor criado com sucesso!",
          message: 'O vendedor ${vendedorSalvo.nome} já pode logar no app.',
        ).show();
      } else {
        // atualizado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                provider.sucessMessage ?? 'Vendedor atualizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, vendedorSalvo); // devolve o vendedor atualizado
      }
    } else {
      // erro
      MyAwesomeDialog(
        dialogType: DialogType.error,
        context: context,
        btnOkText: 'Ok',
        title: "Erro ao criar/atualizar vendedor!",
        message: provider.errorMessage ?? 'Tente novamente mais tarde.',
      ).show();
    }
  }

  String _safe(String? value) => value ?? '';

  String _safeMasked(String? value, MaskTextInputFormatter formatter) {
    if (value == null || value.isEmpty) return '';
    return formatter.maskText(value);
  }

  void _alternarStatus(bool novoStatus) async {
    if (!novoStatus) {
      final provider = Provider.of<VendedorProvider>(context, listen: false);
      final resultado =
          await provider.consultarVinculosVendedor(widget.vendedor!.id!);

      if (resultado != null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.question,
          animType: AnimType.scale,
          title: 'Inativar Vendedor?',
          desc:
              'Este vendedor possui ${resultado.contasreceber} contratos em andamento e ${resultado.clientes} clientes ativos.\nO que deseja fazer?',
          btnOkText: "Transferir",
          btnCancelText: "Apenas Inativar",
          btnOkOnPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TrocarVendedorScreen(
                      vendedorDesligadoId: widget.vendedor!.id!)),
            );
          },
          btnCancelOnPress: () {
            _salvarVendedor();
          },
        ).show();
      }
    }
    setState(() {
      _statusAtivo = novoStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
                widget.vendedor == null ? "Novo Vendedor" : "Editar Vendedor"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: "Dados"),
                    Tab(text: "Permissões"),
                  ],
                ),
              ),
            ),
          ),
          body: Consumer<VendedorProvider>(builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildDadosTab(provider),
                _buildPermissoesTab(),
              ],
            );
          })),
    );
  }

  Widget _buildDadosTab(VendedorProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: AppBackground(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSectionTitle("Informações Pessoais"),
                SwitchListTile(
                  title: const Text("Status do Vendedor"),
                  subtitle: Text(_statusAtivo ? "Ativo" : "Inativo"),
                  value: _statusAtivo,
                  onChanged: _alternarStatus,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
                const SizedBox(height: 10),
                InputCustomizado(
                    controller: nomeController,
                    labelText: "Nome Completo",
                    leadingIcon:
                        const Icon(Icons.person, color: AppTheme.primaryColor),
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
                  // validator: (value) =>
                  //     Util.isCpfCnpjValid(cpfController.text),
                ),
                const SizedBox(height: 10),
                InputCustomizado(
                  controller: telefoneController,
                  labelText: "Telefone",
                  type: TextInputType.number,
                  leadingIcon:
                      const Icon(Icons.phone, color: AppTheme.primaryColor),
                  inputFormatters: [telefoneFormatter],
                  // validator: (value) =>
                  //     value!.isEmpty ? "Campo obrigatório" : null
                ),
                const SizedBox(height: 10),
                InputCustomizado(
                    controller: emailController,
                    labelText: "E-mail",
                    type: TextInputType.emailAddress,
                    leadingIcon:
                        const Icon(Icons.email, color: AppTheme.primaryColor),
                    validator: (value) =>
                        Util.isEmailValid(emailController.text)),
                const SizedBox(height: 16),
                InputCustomizado(
                  controller: senhaController,
                  labelText: widget.vendedor == null
                      ? "Senha do Vendedor"
                      : "Nova senha (opcional)",
                  leadingIcon:
                      const Icon(Icons.lock, color: AppTheme.primaryColor),
                  obscure: true, // precisa existir no seu InputCustomizado
                  validator: (value) {
                    final texto = value ?? '';

                    if (widget.vendedor == null) {
                      // criando novo vendedor → senha obrigatória
                      if (texto.isEmpty) {
                        return "Informe uma senha";
                      }
                      if (texto.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                    } else {
                      // editando → senha opcional, mas se preencher valida
                      if (texto.isNotEmpty && texto.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                provider.isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: "Salvar Vendedor",
                        onPressed: _salvarVendedor,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissoesTab() {
    if (widget.vendedor?.id == null) {
      return AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Salve o vendedor para configurar permissões.",
              style: AppTheme.titleStyle.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_isLoadingPermissoes) {
      return const AppBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_permissoesError != null) {
      return AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _permissoesError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: "Recarregar",
                  onPressed: _carregarPermissoes,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_permissoes.isEmpty) {
      return AppBackground(
        child: Center(
          child: Text(
            "Nenhuma permissão encontrada.",
            style: AppTheme.titleStyle.copyWith(fontSize: 16),
          ),
        ),
      );
    }

    final permissoesOrdenadas = [..._permissoes]
      ..sort((a, b) => _ordemPermissao(a.chave).compareTo(
            _ordemPermissao(b.chave),
          ));

    return AppBackground(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: permissoesOrdenadas.length,
        itemBuilder: (context, index) {
          final parametro = permissoesOrdenadas[index];
          final isPendente = parametro.parametroPendente;
          final isAtualizada = _permissaoAtualizadaId == parametro.id;
          final bool indicadorPermissaoIndividual =
              parametro.chave == "PERMITIR_VENDEDOR_ACESSAR_TODOS_CLIENTES" &&
                  !_empresaPermiteTodosClientes &&
                  _valorPermissao(parametro);
          final String? subtitulo = isPendente
              ? "Pendente de aprovação"
              : (indicadorPermissaoIndividual
                  ? "Ativo por permissão individual (empresa bloqueada)"
                  : null);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: SwitchListTile(
              title: Text(_labelPermissao(parametro.chave)),
              subtitle: subtitulo != null
                  ? Text(
                      subtitulo,
                      style: TextStyle(
                        color: isPendente ? Colors.orange : Colors.blueGrey,
                      ),
                    )
                  : null,
              secondary: isAtualizada
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              value: _valorPermissao(parametro),
              onChanged: isPendente
                  ? null
                  : (novoValor) => _alterarPermissao(parametro, novoValor),
              activeColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: AppTheme.titleStyle
            .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
