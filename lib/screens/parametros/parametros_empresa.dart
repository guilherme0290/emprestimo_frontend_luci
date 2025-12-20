import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/util.dart';
import '../../models/parametro.dart';
import '../../providers/parametros_provider.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_button.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ParametrosEmpresaScreen extends StatefulWidget {
  const ParametrosEmpresaScreen({Key? key}) : super(key: key);

  @override
  State<ParametrosEmpresaScreen> createState() =>
      _ParametrosEmpresaScreenState();
}

class _ParametrosEmpresaScreenState extends State<ParametrosEmpresaScreen> {
  final TextEditingController limiteContasReceberController =
      TextEditingController();
  final TextEditingController jurosPadraoController = TextEditingController();
  final TextEditingController limiteContasReceberEmAbertoPorClienteController =
      TextEditingController();
  bool permitirBaixaParcial = false;
  bool obrigarVendedorVenda = false;
  bool permitirVendedorTodosClientes = false;
  bool _atualizandoObrigarVendedorVenda = false;
  bool _atualizandoPermitirVendedorTodosClientes = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.wait([_carregarParametros()]);
    });
  }

  Future<void> _carregarParametros() async {
    setState(() => _isLoading = true);
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);

    await parametroProvider.buscarParametrosEmpresa();

    if (parametroProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(parametroProvider.errorMessage!),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final limite = parametroProvider
            .buscarParametroEmpresaChave("LIMITE_EMPRESTIMO")
            ?.valor ??
        "0.0";
    final juros =
        parametroProvider.buscarParametroEmpresaChave("JUROS_PADRAO")?.valor ??
            "0.0";
    final permitir = parametroProvider
            .buscarParametroEmpresaChave("PERMITIR_BAIXA_PARCIAL")
            ?.valor ??
        "false";
    final obrigarVendedor = parametroProvider
            .buscarParametroEmpresaChave("OBRIGAR_VENDEDOR_VENDA")
            ?.valor ??
        "false";
    final permitirTodosClientes = parametroProvider
            .buscarParametroEmpresaChave(
                "PERMITIR_VENDEDOR_ACESSAR_TODOS_CLIENTES_EMPRESA")
            ?.valor ??
        "false";

    final limiteContasReceberEmAbertoPorCliente = parametroProvider
            .buscarParametroEmpresaChave("LIMITE_EMPRESTIMO_CLIENTE")
            ?.valor ??
        "0";

    setState(() {
      final formatador =
          NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);
      limiteContasReceberController.text =
          formatador.format(double.tryParse(limite) ?? 0.0);
      jurosPadraoController.text = juros.toString();
      permitirBaixaParcial = permitir.toLowerCase() == 'true';
      obrigarVendedorVenda = obrigarVendedor.toLowerCase() == 'true';
      permitirVendedorTodosClientes =
          permitirTodosClientes.toLowerCase() == 'true';
      limiteContasReceberEmAbertoPorClienteController.text =
          limiteContasReceberEmAbertoPorCliente;
      _isLoading = false;
    });
  }

  Future<void> _salvarParametros() async {
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);

    int empresaId = parametroProvider.getEmpresaId();

    bool sucesso1 = await parametroProvider.atualizarParametro(
      Parametro(
        id: parametroProvider
            .buscarParametroEmpresaChave("LIMITE_EMPRESTIMO")
            ?.id,
        chave: "LIMITE_EMPRESTIMO",
        valor: Util.removerMascaraValor(limiteContasReceberController.text)
            .toString(),
        tipoReferencia: "EMPRESA",
        referenciaId: empresaId,
      ),
    );

    bool sucesso2 = await parametroProvider.atualizarParametro(
      Parametro(
        id: parametroProvider
            .buscarParametroEmpresaChave("LIMITE_EMPRESTIMO_CLIENTE")
            ?.id,
        chave: "LIMITE_EMPRESTIMO_CLIENTE",
        valor: limiteContasReceberEmAbertoPorClienteController.text,
        tipoReferencia: "EMPRESA",
        referenciaId: empresaId,
      ),
    );

    bool sucesso3 = await parametroProvider.atualizarParametro(
      Parametro(
        id: parametroProvider.buscarParametroEmpresaChave("JUROS_PADRAO")?.id,
        chave: "JUROS_PADRAO",
        valor: jurosPadraoController.text,
        tipoReferencia: "EMPRESA",
        referenciaId: empresaId,
      ),
    );

    bool sucesso4 = await parametroProvider.atualizarParametro(
      Parametro(
        id: parametroProvider
            .buscarParametroEmpresaChave("PERMITIR_BAIXA_PARCIAL")
            ?.id,
        chave: "PERMITIR_BAIXA_PARCIAL",
        valor: permitirBaixaParcial.toString(),
        tipoReferencia: "EMPRESA",
        referenciaId: empresaId,
      ),
    );

    if (sucesso1 && sucesso2 && sucesso3 && sucesso4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Parâmetros da empresa salvos com sucesso!"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Erro ao salvar um ou mais parâmetros da empresa."),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _atualizarObrigarVendedorVenda(bool value) async {
    if (_atualizandoObrigarVendedorVenda) return;
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);
    final parametro = parametroProvider
        .buscarParametroEmpresaChave("OBRIGAR_VENDEDOR_VENDA");

    if (parametro?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Parâmetro OBRIGAR_VENDEDOR_VENDA não encontrado."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _atualizandoObrigarVendedorVenda = true;
      obrigarVendedorVenda = value;
    });

    final sucesso = await parametroProvider.atualizarParametroDireto(
      parametroId: parametro!.id!,
      valor: value,
    );

    if (!mounted) return;

    if (!sucesso) {
      setState(() {
        obrigarVendedorVenda = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Erro ao atualizar parâmetro de vendedor na venda."),
        backgroundColor: Colors.red,
      ));
    }

    setState(() {
      _atualizandoObrigarVendedorVenda = false;
    });
  }

  Future<void> _atualizarPermitirVendedorTodosClientes(bool value) async {
    if (_atualizandoPermitirVendedorTodosClientes) return;
    final parametroProvider =
        Provider.of<ParametroProvider>(context, listen: false);
    final parametro = parametroProvider.buscarParametroEmpresaChave(
        "PERMITIR_VENDEDOR_ACESSAR_TODOS_CLIENTES_EMPRESA");

    if (parametro?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Parâmetro PERMITIR_VENDEDOR_ACESSAR_TODOS_CLIENTES_EMPRESA não encontrado."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _atualizandoPermitirVendedorTodosClientes = true;
      permitirVendedorTodosClientes = value;
    });

    final sucesso = await parametroProvider.atualizarParametroDireto(
      parametroId: parametro!.id!,
      valor: value,
    );

    if (!mounted) return;

    if (!sucesso) {
      setState(() {
        permitirVendedorTodosClientes = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Erro ao atualizar parâmetro de acesso a todos os clientes."),
        backgroundColor: Colors.red,
      ));
    }

    setState(() {
      _atualizandoPermitirVendedorTodosClientes = false;
    });
  }

  @override
  void dispose() {
    limiteContasReceberController.dispose();
    jurosPadraoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parâmetros da Empresa"),
      ),
      body: AppBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSectionTitle("Limites e Juros"),
                    InputCustomizado(
                      controller: limiteContasReceberController,
                      labelText: "Valor limite para novos clientes ",
                      type: TextInputType.number,
                      inputFormatters: [CurrencyFormatter()],
                      leadingIcon: const Icon(Icons.monetization_on,
                          color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 10),
                    InputCustomizado(
                      controller: jurosPadraoController,
                      labelText: "Juros Padrão (%)",
                      type: TextInputType.number,
                      inputFormatters: [
                        CurrencyInputFormatter(
                          leadingSymbol: '',
                          useSymbolPadding: false,
                          mantissaLength: 1,
                          thousandSeparator: ThousandSeparator.None,
                        )
                      ],
                      leadingIcon: const Icon(Icons.percent,
                          color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 10),
                    InputCustomizado(
                      controller:
                          limiteContasReceberEmAbertoPorClienteController,
                      labelText: "Limite de Venda em Aberto por Cliente",
                      type: TextInputType.number,
                      leadingIcon:
                          const Icon(Icons.money, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text("Permitir baixa parcial de parcelas"),
                      activeColor: AppTheme.primaryColor,
                      value: permitirBaixaParcial,
                      onChanged: (value) {
                        setState(() {
                          permitirBaixaParcial = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Obrigar vendedor na venda"),
                      activeColor: AppTheme.primaryColor,
                      value: obrigarVendedorVenda,
                      onChanged: _atualizandoObrigarVendedorVenda
                          ? null
                          : _atualizarObrigarVendedorVenda,
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Vendedor pode ver todos os clientes"),
                      activeColor: AppTheme.primaryColor,
                      value: permitirVendedorTodosClientes,
                      onChanged: _atualizandoPermitirVendedorTodosClientes
                          ? null
                          : _atualizarPermitirVendedorTodosClientes,
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: "Salvar Parâmetros",
                      onPressed: _salvarParametros,
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: AppTheme.titleStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
