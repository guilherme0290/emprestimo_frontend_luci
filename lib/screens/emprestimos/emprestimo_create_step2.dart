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

    final temp = <ParcelaSimulada>[];

    DateTime dataBase;

    // Definição da 1ª data
    if (dataPrimeiroVencimento != null) {
      dataBase = dataPrimeiroVencimento;
    } else {
      // fallback: usa dataContrato + regra de parcelamento
      dataBase = dataContrato;
      if (tipo == "MENSAL") {
        dataBase = DateTime(dataBase.year, dataBase.month + 1, dataBase.day);
      } else if (tipo == "QUINZENAL") {
        dataBase = dataBase.add(const Duration(days: 15));
      } else if (tipo == "SEMANAL") {
        dataBase = dataBase.add(const Duration(days: 7));
      } else if (tipo == "DIARIO") {
        dataBase = dataBase.add(const Duration(days: 1));
      }
    }

    for (int i = 1; i <= n; i++) {
      if (i > 1) {
        if (tipo == "MENSAL") {
          if (vencimentoFixo && dataPrimeiroVencimento != null) {
            // mantém o "dia do mês" do primeiro vencimento
            dataBase = DateTime(
              dataBase.year,
              dataBase.month + 1,
              dataPrimeiroVencimento.day,
            );
          } else {
            dataBase =
                DateTime(dataBase.year, dataBase.month + 1, dataBase.day);
          }
        } else if (tipo == "QUINZENAL") {
          dataBase = dataBase.add(const Duration(days: 15));
        } else if (tipo == "SEMANAL") {
          dataBase = dataBase.add(const Duration(days: 7));
        } else if (tipo == "DIARIO") {
          dataBase = dataBase.add(const Duration(days: 1));
        }
      }

      temp.add(
        ParcelaSimulada(
          numero: i,
          valor: valorParcela,
          dataVencimento: dataBase,
        ),
      );
    }

    setState(() {
      _parcelasSimuladas = temp;
      _jurosCalculado = juros;
    });
  }

  /// 🔹 Recalcula a taxa de juros com base no novo valor da parcela
  void _recalcularJuros() {
    double novoValorParcela = Util.removerMascaraValor(_parcelaController.text);

    if (novoValorParcela <= 0) return;

    final valorContasReceber = widget.emprestimoDraft.valor;
    final numParcelas = widget.emprestimoDraft.numeroParcelas;

    // Calculando os novos juros com a fórmula reversa
    double novoJuros =
        (((novoValorParcela * numParcelas) - valorContasReceber) /
                valorContasReceber) *
            100;

    setState(() {
      _jurosCalculado = novoJuros;
    });
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
              leading: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor,
                child: Text(
                  "${parc.numero}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              title: Text(
                Util.formatarMoeda(
                    Util.removerMascaraValor(_parcelaController.text)),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Vencimento: ${FormatData.formatarDataCompleta(parc.dataVencimento.toString())}",
                style: const TextStyle(color: Colors.grey),
              ),
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
