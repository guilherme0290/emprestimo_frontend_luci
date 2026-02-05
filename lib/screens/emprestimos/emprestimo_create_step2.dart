import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/models/parcela_simulada.dart';
import 'package:emprestimos_app/models/request_emprestimo.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/cliente_dropdown_search.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/resumo_penhora_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContasReceberCreateStep2 extends StatefulWidget {
  final NovoContasReceberDTO emprestimoDraft;

  const ContasReceberCreateStep2({Key? key, required this.emprestimoDraft})
      : super(key: key);

  @override
  State<ContasReceberCreateStep2> createState() =>
      _ContasReceberCreateStep2State();
}

class _ContasReceberCreateStep2State extends State<ContasReceberCreateStep2> {
  List<ParcelaSimulada> _parcelasSimuladas = [];
  late TextEditingController _parcelaController;
  double _jurosCalculado = 0.0;
  bool _mostrarJuros = false;
  String? _erroCliente;

  Cliente? _clienteSelecionado;
  @override
  void initState() {
    super.initState();
    _simularParcelas();
    _setCliente();
  }

  void _setCliente() {
    if (widget.emprestimoDraft.cliente != null) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            _clienteSelecionado = widget.emprestimoDraft.cliente;
          });
        }
      });
    }
  }

  void _simularParcelas() {
    final valor = widget.emprestimoDraft.valor;
    final juros = widget.emprestimoDraft.juros;
    final tipoRaw = widget.emprestimoDraft.tipoPagamento;
    final n = widget.emprestimoDraft.numeroParcelas;

    final dataContrato = widget.emprestimoDraft.dataContrato ?? DateTime.now();
    final dataPrimeiroVencimento =
        widget.emprestimoDraft.dataPrimeiroVencimento;
    final vencimentoFixo = widget.emprestimoDraft.vencimentoFixo;

    final String tipo = (tipoRaw ?? '').trim().toUpperCase();

    final taxaDecimal = juros / 100;
    final totalJuros = valor * taxaDecimal;
    final totalPagar = valor + totalJuros;
    final valorParcela = totalPagar / n;

    _parcelaController = TextEditingController(
      text: Util.formatarMoeda(valorParcela),
    );

    final primeiroVencimento = dataPrimeiroVencimento ??
        _calcularPrimeiroVencimento(dataContrato, tipo);
    final temp = <ParcelaSimulada>[];

    for (int i = 1; i <= n; i++) {
      final dataVencimento =
          _calcularDataVencimento(i, primeiroVencimento, tipo);

      temp.add(
        ParcelaSimulada(
          numero: i,
          valor: valorParcela,
          dataVencimento: dataVencimento,
        ),
      );
    }

    setState(() {
      _parcelasSimuladas = temp;
      _jurosCalculado = juros;
    });
  }

  DateTime _calcularPrimeiroVencimento(DateTime dataContrato, String tipo) {
    switch (tipo) {
      case "MENSAL":
        return DateTime(
            dataContrato.year, dataContrato.month + 1, dataContrato.day);
      case "SEMANAL":
        return dataContrato.add(const Duration(days: 7));
      case "DIARIO":
        return dataContrato.add(const Duration(days: 1));
      case "QUINZENAL":
        return dataContrato.add(const Duration(days: 15));
      default:
        return dataContrato.add(const Duration(days: 1));
    }
  }

  DateTime _calcularDataVencimento(
      int indice, DateTime primeiroVencimento, String tipo) {
    if (indice == 1) return primeiroVencimento;

    if (widget.emprestimoDraft.vencimentoFixo && tipo == "MENSAL") {
      final base = DateTime(
          primeiroVencimento.year, primeiroVencimento.month + indice - 1);
      final diaFixo = primeiroVencimento.day;
      final ultimoDiaMes = DateTime(base.year, base.month + 1, 0).day;
      final dia = diaFixo <= ultimoDiaMes ? diaFixo : ultimoDiaMes;
      return DateTime(base.year, base.month, dia);
    }

    switch (tipo) {
      case "MENSAL":
        return _addMonthsClamp(primeiroVencimento, indice - 1);
      case "SEMANAL":
        return primeiroVencimento.add(Duration(days: 7 * (indice - 1)));
      case "DIARIO":
        return primeiroVencimento.add(Duration(days: indice - 1));
      case "QUINZENAL":
        return primeiroVencimento.add(Duration(days: 15 * (indice - 1)));
      default:
        return primeiroVencimento.add(Duration(days: indice - 1));
    }
  }

  DateTime _addMonthsClamp(DateTime base, int addMonths) {
    final targetYear = base.year + ((base.month - 1 + addMonths) ~/ 12);
    final targetMonth = ((base.month - 1 + addMonths) % 12) + 1;
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    final day = base.day <= lastDay ? base.day : lastDay;
    return DateTime(targetYear, targetMonth, day);
  }

  void _aplicarValorParcela(double novoValor) {
    if (novoValor <= 0) return;
    setState(() {
      for (final p in _parcelasSimuladas) {
        p.valor = novoValor;
      }
      _recalcularJurosPorParcelas();
    });
  }

  void _recalcularJurosPorParcelas() {
    final somaParcelas =
        _parcelasSimuladas.fold<double>(0.0, (s, p) => s + p.valor);
    final valorContasReceber = widget.emprestimoDraft.valor;
    if (valorContasReceber <= 0) return;
    final novoJuros =
        ((somaParcelas - valorContasReceber) / valorContasReceber) * 100;
    _jurosCalculado = novoJuros;
  }

  /// 🔹 Recalcula a taxa de juros com base no novo valor da parcela
  void _recalcularJuros() {
    double novoValorParcela = Util.removerMascaraValor(_parcelaController.text);

    if (novoValorParcela <= 0) return;

    _aplicarValorParcela(novoValorParcela);
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.emprestimoDraft;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pré-visualização da venda"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AppBackground(
          child: SafeArea(
            bottom: true,
            child: Column(
              children: [
                _buildResumoContasReceber(draft),
                const SizedBox(height: 16),
                (_clienteSelecionado == null || _erroCliente != null)
                    ? Column(
                        children: [
                          ClienteDropdown(
                            onClienteSelecionado: (cliente) async {
                              final isValido =
                                  await _validaClienteTemp(cliente);
                              if (mounted && isValido) {
                                setState(() {
                                  _clienteSelecionado = cliente;
                                  _erroCliente = null;
                                });
                              }
                            },
                          ),
                          if (_erroCliente != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _erroCliente!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : const SizedBox.shrink(),
                ResumoPenhoraWidget(
                  emprestimo: draft,
                ),
                const SizedBox(height: 16),
                _buildAjusteParcelas(),
                _buildListaParcelas(),
                const SizedBox(height: 16),
                _buildBotoes(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumoContasReceber(NovoContasReceberDTO draft) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Informações principais organizadas em um grid compacto
            Wrap(
                spacing: 12, // Espaço entre os itens
                runSpacing: 8, // Espaço entre linhas
                alignment: WrapAlignment.start,
                children: [
                  _buildInfoItem(Icons.monetization_on, "Valor",
                      Util.formatarMoeda(draft.valor)),
                  if (_mostrarJuros)
                    _buildInfoItem(Icons.percent, "Juros",
                        "${_jurosCalculado.toStringAsFixed(2)}%"),
                  _buildInfoItem(Icons.calendar_today, "Parcelas",
                      "${draft.numeroParcelas}x"),
                  // _buildInfoItem(Icons.attach_money, "Parcela",
                  //     Util.formatarMoeda((_parcelasSimuladas.first.valor))),
                ]),

            const SizedBox(height: 8),

            // 🔹 Dados do Cliente, se estiver selecionado
            if (_clienteSelecionado != null)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildInfoItem(Icons.person, "Cliente",
                      _clienteSelecionado?.nome ?? "Não selecionado"),
                  _buildInfoItem(Icons.phone, "Telefone",
                      _clienteSelecionado?.telefone ?? "Não informado"),
                ],
              ),

            // 🔹 Botão para mostrar/ocultar juros sem ocupar muito espaço
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _mostrarJuros = !_mostrarJuros;
                  });
                },
                child: Text(
                  _mostrarJuros ? "Ocultar Juros" : "Mostrar Juros",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Campo para ajuste da parcela
  Widget _buildAjusteParcelas() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _parcelaController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Ajustar Valor da Parcela",
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _recalcularJuros(),
      ),
    );
  }

  /// 🔹 Lista de Parcelas Simuladas
  Widget _buildListaParcelas() {
    return Expanded(
      child: ListView.builder(
        itemCount: _parcelasSimuladas.length,
        itemBuilder: (context, index) {
          final parc = _parcelasSimuladas[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              onTap: () => _editarParcela(index),
              leading: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor,
                child: Text(
                  "${parc.numero}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              title: Text(
                Util.formatarMoeda(parc.valor),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Vencimento: ${FormatData.formatarDataCompleta(parc.dataVencimento.toString())}",
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBotoes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text("Voltar"),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
            text: 'Confirmar',
            enabled: _erroCliente == null && _clienteSelecionado != null,
            onPressed: () {
              if (_erroCliente == null) {
                _validaClienteTemp(_clienteSelecionado!);
                _confirmarContasReceber();
              }
            }),
      ],
    );
  }

  Future<void> _valida() async {
    if (_clienteSelecionado == null) {
      setState(() {
        _erroCliente = "Selecione um cliente antes de continuar.";
      });
      return;
    }

    final provider = Provider.of<ParametroProvider>(context, listen: false);

    await Provider.of<ParametroProvider>(context, listen: false)
        .buscarParametrosEmpresa();

    await Provider.of<ParametroProvider>(context, listen: false)
        .buscarParametrosCliente(_clienteSelecionado!.id!);

    final qtdContasReceberAtivos =
        await Provider.of<ContasReceberProvider>(context, listen: false)
            .countContasReceberCliente(_clienteSelecionado!.id!);

    double valorContasReceber = widget.emprestimoDraft.valor;
    int numeroParcelas = widget.emprestimoDraft.numeroParcelas;
    double juros = _jurosCalculado;

    double? limiteCreditoCliente = Util.getParametroDouble(
        'LIMITE_CREDITO_CLIENTE', provider.parametrosCliente);
    double? limiteCreditoEmpresa = Util.getParametroDouble(
        'LIMITE_EMPRESTIMO', provider.parametrosEmpresa);

    double? limiteCredito = limiteCreditoCliente ?? limiteCreditoEmpresa;

    int? limiteQtdContasReceberCliente = Util.getParametroInt(
        'LIMITE_EMPRESTIMO_CLIENTE', provider.parametrosCliente);
    int? limiteQtdContasReceberEmpresa = Util.getParametroInt(
        'LIMITE_EMPRESTIMO_CLIENTE', provider.parametrosEmpresa);

    int? limiteQtdContasReceber =
        limiteQtdContasReceberCliente ?? limiteQtdContasReceberEmpresa;

// 🔹 Verifica limite de crédito
    if (limiteCredito != null && valorContasReceber > limiteCredito) {
      setState(() {
        _erroCliente =
            "Valor excede o limite de crédito permitido: ${Util.formatarMoeda(limiteCredito)}";
      });
      return;
    }

// 🔹 Verifica limite de empréstimos em aberto
    if (limiteQtdContasReceber != null &&
        qtdContasReceberAtivos!.contasreceber > limiteQtdContasReceber) {
      setState(() {
        _erroCliente =
            "Número de empréstimos em aberto excede o permitido (${limiteQtdContasReceber}).";
      });
      return;
    }

    // Limpa erro se passou na validação
    setState(() {
      _erroCliente = null;
    });
  }

  Future<bool> _validaClienteTemp(Cliente cliente) async {
    final provider = Provider.of<ParametroProvider>(context, listen: false);

    bool isValido = true;
    final erros = StringBuffer();

    await provider.buscarParametrosEmpresa();
    await provider.buscarParametrosCliente(cliente.id!);

    final qtdContasReceberAtivos =
        await Provider.of<ContasReceberProvider>(context, listen: false)
            .countContasReceberCliente(cliente.id!);

    int limiteQtdContasReceber = 0;
    double limiteCredito = 0.0;

    double valorContasReceber = widget.emprestimoDraft.valor;
    int numeroParcelas = widget.emprestimoDraft.numeroParcelas;
    double juros = _jurosCalculado;

    double? limiteCreditoCliente = Util.getParametroDouble(
        'LIMITE_CREDITO_CLIENTE', provider.parametrosCliente);
    double? limiteCreditoEmpresa = Util.getParametroDouble(
        'LIMITE_EMPRESTIMO', provider.parametrosEmpresa);

    int limiteQtdContasReceberCliente = Util.getParametroInt(
        'LIMITE_EMPRESTIMO_CLIENTE', provider.parametrosCliente);
    int limiteQtdContasReceberEmpresa = Util.getParametroInt(
        'LIMITE_EMPRESTIMO_CLIENTE', provider.parametrosEmpresa);

    if (limiteQtdContasReceberCliente > 0) {
      limiteQtdContasReceber = limiteQtdContasReceberCliente;
    } else if (limiteQtdContasReceberEmpresa > 0) {
      limiteQtdContasReceber = limiteQtdContasReceberEmpresa;
    } else {
      limiteQtdContasReceber = 0;
    }

    if (limiteCreditoCliente > 0.0) {
      limiteCredito = limiteCreditoCliente;
    } else if (limiteCreditoEmpresa > 0) {
      limiteCredito = limiteCreditoEmpresa;
    } else {
      limiteCredito = 0;
    }

    if (limiteCredito != 0 && valorContasReceber > limiteCredito) {
      erros.writeln(
          "Valor excede o limite de crédito permitido: ${Util.formatarMoeda(limiteCredito)}");
      isValido = false;
    }

    if (limiteQtdContasReceber != 0 &&
        qtdContasReceberAtivos!.contasreceber >= limiteQtdContasReceber) {
      erros.writeln(
          "Número de contratos em aberto excede o permitido (${limiteQtdContasReceber}).");
      isValido = false;
    }

    if (!isValido) {
      setState(() {
        _erroCliente = erros.toString().trim();
      });
      return false;
    }

    return true;
  }

  Future<void> _validarAntesDeConfirmar() async {
    await _valida(); // executa a validação primeiro

    if (_erroCliente == null) {
      _confirmarContasReceber();
    }
  }

  /// 🔹 Confirma o empréstimo e retorna à tela anterior
  void _confirmarContasReceber() async {
    final emprestimoProvider =
        Provider.of<ContasReceberProvider>(context, listen: false);

    widget.emprestimoDraft.juros = _jurosCalculado;
    widget.emprestimoDraft.cliente = _clienteSelecionado;
    widget.emprestimoDraft.parcelas = _parcelasSimuladas;

    final novoContasReceber =
        await emprestimoProvider.criarContasReceber(widget.emprestimoDraft);

    if (!mounted) return;

    if (novoContasReceber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erro ao criar empréstimo"),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Empréstimo criado com sucesso!"),
            backgroundColor: Colors.green),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context, novoContasReceber);
    }
  }

  Future<void> _editarParcela(int index) async {
    final parc = _parcelasSimuladas[index];
    final controller = TextEditingController(
      text: Util.formatarMoeda(parc.valor),
    );
    DateTime dataSelecionada = parc.dataVencimento;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar parcela ${parc.numero}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Valor da parcela",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dataSelecionada,
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dataSelecionada = picked;
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Data de vencimento",
                    border: OutlineInputBorder(),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      FormatData.formatarDataCompletaPadrao(dataSelecionada),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final valor = Util.removerMascaraValor(controller.text);
                Navigator.pop(context, {
                  'valor': valor,
                  'dataVencimento': dataSelecionada,
                });
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );

    if (resultado == null) return;
    final novoValor = resultado['valor'] as double? ?? 0;
    final novaData = resultado['dataVencimento'] as DateTime?;
    if (novoValor <= 0 || novaData == null) return;
    setState(() {
      _parcelasSimuladas[index] = ParcelaSimulada(
        numero: parc.numero,
        valor: novoValor,
        dataVencimento: novaData,
      );
      _recalcularJurosPorParcelas();
    });
  }
}

/// 🔹 Helper: Informações do Resumo
Widget _buildInfoRow(List<Widget> items) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items,
    ),
  );
}

Widget _buildInfoItem(IconData icon, String label, String value) {
  return Row(
    mainAxisSize: MainAxisSize.min, // Mantém os itens compactos
    children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(width: 4),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    ],
  );
}
