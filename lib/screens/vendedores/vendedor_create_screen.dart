import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/cidade.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/providers/cidade_provider.dart';
import 'package:emprestimos_app/providers/cliente_provider.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CidadeProvider>(context, listen: false).carregarCidades();
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
    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.vendedor == null ? "Novo Vendedor" : "Editar Vendedor"),
        ),
        body: Consumer<VendedorProvider>(builder: (context, provider, child) {
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
                        // validator: (value) =>
                        //     Util.isCpfCnpjValid(cpfController.text),
                      ),
                      const SizedBox(height: 10),
                      InputCustomizado(
                        controller: telefoneController,
                        labelText: "Telefone",
                        type: TextInputType.number,
                        leadingIcon: const Icon(Icons.phone,
                            color: AppTheme.primaryColor),
                        inputFormatters: [telefoneFormatter],
                        // validator: (value) =>
                        //     value!.isEmpty ? "Campo obrigatório" : null
                      ),
                      const SizedBox(height: 10),
                      InputCustomizado(
                          controller: emailController,
                          labelText: "E-mail",
                          type: TextInputType.emailAddress,
                          leadingIcon: const Icon(Icons.email,
                              color: AppTheme.primaryColor),
                          validator: (value) =>
                              Util.isEmailValid(emailController.text)),
                      const SizedBox(height: 16),
                      InputCustomizado(
                        controller: senhaController,
                        labelText: widget.vendedor == null
                            ? "Senha do Vendedor"
                            : "Nova senha (opcional)",
                        leadingIcon: const Icon(Icons.lock,
                            color: AppTheme.primaryColor),
                        obscure:
                            true, // precisa existir no seu InputCustomizado
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }));
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
