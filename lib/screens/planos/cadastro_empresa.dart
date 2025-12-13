import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/cidade.dart';
import 'package:emprestimos_app/models/empresa.dart';
import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/providers/cidade_provider.dart';
import 'package:emprestimos_app/providers/compra_provider.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/screens/auth/login_screen.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/cidade_dropdown.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/dialog_widget.dart';
import 'package:emprestimos_app/widgets/input_field.dart';
import 'package:emprestimos_app/widgets/uf_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class CadastroEmpresaScreen extends StatefulWidget {
  final Plano plano;

  const CadastroEmpresaScreen({
    super.key,
    required this.plano,
  });

  @override
  State<CadastroEmpresaScreen> createState() => _CadastroEmpresaScreenState();
}

class _CadastroEmpresaScreenState extends State<CadastroEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _responsavelController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaVisivel = false;

  bool _isLoading = false;
  String? _planoToken;

  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  String? ufSelecionada;
  List<Cidade> cidades = [];
  Cidade? cidadeSelecionada;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {

    //       Provider.of<CidadeProvider>(context, listen: false)

    // });
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Cadastro da Empresa'),
        ),
        body: AppBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total mensal: R\$${widget.plano.preco.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Plano selecionado: ${widget.plano.nome.toUpperCase()}',
                          style: AppTheme.titleStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  InputCustomizado(
                    labelText: 'Nome do responsável',
                    controller: _responsavelController,
                    type: TextInputType.text,
                    leadingIcon:
                        const Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  InputCustomizado(
                      controller: _telefoneController,
                      labelText: "Telefone",
                      type: TextInputType.number,
                      leadingIcon:
                          const Icon(Icons.phone, color: AppTheme.primaryColor),
                      inputFormatters: [telefoneFormatter],
                      validator: (value) =>
                          value!.isEmpty ? "Campo obrigatório" : null),
                  const SizedBox(height: 16),
                  UfDropdown(
                    selectedUf: ufSelecionada,
                    onUfSelecionada: (uf) {
                      setState(() => ufSelecionada = uf);
                      // buscarCidadesPorUf(uf)
                    },
                  ),
                  const SizedBox(height: 16),
                  CidadeDropdown(
                    uf: ufSelecionada,
                    onCidadeSelecionada: (cidade) {
                      cidadeSelecionada = cidade;
                    },
                  ),
                  const SizedBox(height: 16),
                  InputCustomizado(
                      labelText: 'E-mail',
                      controller: _emailController,
                      type: TextInputType.emailAddress,
                      leadingIcon:
                          const Icon(Icons.email, color: AppTheme.primaryColor),
                      validator: (value) =>
                          Util.isEmailValid(_emailController.text)),
                  const SizedBox(height: 16),
                  InputCustomizado(
                    labelText: 'Senha',
                    controller: _senhaController,
                    type: TextInputType.visiblePassword,
                    obscure: !_senhaVisivel,
                    leadingIcon: IconButton(
                      icon: Icon(
                        _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _senhaVisivel = !_senhaVisivel;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Finalizar Cadastro',
                          enabled: Provider.of<EmpresaProvider>(context,
                                      listen: false)
                                  .empresa ==
                              null,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final empresaDTO = Empresa(
                                responsavel: _responsavelController.text,
                                telefone: Util.removerMascara(
                                    _telefoneController.text),
                                email: _emailController.text,
                                senha: _senhaController.text,
                                planoId: widget.plano.id,
                              );

                              setState(() {
                                _isLoading = true;
                              });
                              final empresaProvider =
                                  Provider.of<EmpresaProvider>(context,
                                      listen: false);
                              final sucesso = await empresaProvider
                                  .cadastrarEmpresa(empresaDTO);

                              setState(() {
                                _isLoading = false;
                              });
                              if (sucesso) {
                                MyAwesomeDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  title: 'Cadastro concluído!',
                                  message:
                                      'Sua empresa foi cadastrada com sucesso.\nVocê já pode logar no sistema.',
                                  dialogType: DialogType.success,
                                  btnOkText: 'Ir para o Login',
                                  onOkPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()),
                                      (route) => false,
                                    );
                                  },
                                ).show();

                                //metodo para o usario vincular o plano e cobrar a recorrencia
                                // final _inAppPurchase = InAppPurchase.instance;
                                // final productId =
                                //     widget.plano.productIdGooglePlay;

                                // if (productId == null) {
                                //   throw Exception(
                                //       "ID do produto não definido para este plano.");
                                // }

                                // final response = await _inAppPurchase
                                //     .queryProductDetails({productId});
                                // final produto = response.productDetails.first;
                                // final param =
                                //     PurchaseParam(productDetails: produto);
                                // await _inAppPurchase.buyNonConsumable(
                                //     purchaseParam: param);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          empresaProvider.errorMessage ??
                                              'Erro ao cadastrar')),
                                );
                              }
                            }
                          },
                        ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ao clicar em "Finalizar Cadastro", você concorda com os Termos de Uso e Política de Privacidade.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
