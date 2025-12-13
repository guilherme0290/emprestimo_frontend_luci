import 'package:emprestimos_app/models/caixa.dart';
import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/models/request_emprestimo.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_create_step2.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/emprestimo_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContasReceberCreateStep1 extends StatefulWidget {
  final Cliente? cliente;

  const ContasReceberCreateStep1({Key? key, required this.cliente})
      : super(key: key);

  @override
  State<ContasReceberCreateStep1> createState() =>
      _ContasReceberCreateStep1State();
}

class _ContasReceberCreateStep1State extends State<ContasReceberCreateStep1> {
  bool isSimulation = false;
  List<Vendedor> vendedores = [];
  List<Caixa> caixas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isSimulation = widget.cliente == null;
      _carregarParametros();
      _carregarVendedores();
      _carregarCaixas();
    });
  }

  void _carregarCaixas() async {
    final caixaProvider = Provider.of<CaixaProvider>(context, listen: false);
    await caixaProvider.listarCaixas();
    caixas = caixaProvider.caixas;
    if (mounted) {
      setState(() {});
    }
  }

  void _carregarParametros() async {
    final provider = Provider.of<ParametroProvider>(context, listen: false);
    if (provider.parametrosCliente.isEmpty) {
      if (widget.cliente != null) {
        await provider.buscarParametrosCliente(widget.cliente!.id!);
      }
    }
    if (provider.parametrosEmpresa.isEmpty) {
      await provider.buscarParametrosEmpresa();
    }
  }

  void _carregarVendedores() async {
    final vendedorProvider =
        Provider.of<VendedorProvider>(context, listen: false);
    await vendedorProvider.listarVendedores();
    vendedores = vendedorProvider.vendedores;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParametroProvider>(
        builder: (context, parametroProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isSimulation ? "Simular Venda" : "Nova Venda"),
        ),
        body: Padding(
          padding:
              const EdgeInsets.all(16.0), // 🔹 Adiciona um espaçamento ao redor
          child: AppBackground(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContasReceberForm(
                    parametrosCliente: parametroProvider.parametrosCliente,
                    parametrosEmpresa: parametroProvider.parametrosEmpresa,
                    isSimulation: isSimulation,
                    vendedores: vendedores,
                    caixas: caixas,
                    onSubmit: (valor,
                        juros,
                        parcelas,
                        tipoPagamento,
                        penhora,
                        vendedor,
                        caixa,
                        dataContrato,
                        dataPrimeiroVencimento,
                        vencimentoFixo,
                        descricao) {
                      final dto = NovoContasReceberDTO(
                          valor: valor,
                          juros: juros,
                          numeroParcelas: parcelas,
                          tipoPagamento: tipoPagamento,
                          cliente: widget.cliente,
                          penhora: penhora,
                          vendedorId: vendedor?.id,
                          caixaId: caixa?.id,
                          dataContrato: dataContrato,
                          dataPrimeiroVencimento: dataPrimeiroVencimento,
                          vencimentoFixo: vencimentoFixo,
                          descricao: descricao);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ContasReceberCreateStep2(emprestimoDraft: dto),
                        ),
                      );
                    },
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
