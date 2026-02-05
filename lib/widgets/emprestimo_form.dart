import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/caixa.dart';
import 'package:emprestimos_app/models/parametro.dart';
import 'package:emprestimos_app/models/penhora.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/custom_checkbox.dart';
import 'package:emprestimos_app/widgets/custom_swithtile.dart';
import 'package:emprestimos_app/widgets/currency_formatter.dart';
import 'package:emprestimos_app/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ContasReceberForm extends StatefulWidget {
  final Function(
    double valor,
    double juros,
    int parcelas,
    String tipoPagamento,
    PenhoraDTO? penhora,
    Vendedor? vendedor,
    Caixa? caixa,
    DateTime dataContrato,
    DateTime? dataPrimeiroVencimento,
    bool vencimentoFixo,
    String? descricao,
  ) onSubmit;

  final bool isSimulation;
  final List<Parametro> parametrosCliente;
  final List<Parametro> parametrosEmpresa;
  final List<Vendedor>? vendedores;
  final List<Caixa>? caixas;

  const ContasReceberForm({
    Key? key,
    required this.onSubmit,
    this.isSimulation = false,
    required this.parametrosCliente,
    required this.parametrosEmpresa,
    this.vendedores = const [],
    this.caixas = const [],
  }) : super(key: key);

  @override
  _ContasReceberFormState createState() => _ContasReceberFormState();
}

class _ContasReceberFormState extends State<ContasReceberForm> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _jurosController = TextEditingController();
  final _numeroParcelasController = TextEditingController();
  final _dataContratoController = TextEditingController();
  final _dataPrimeiroVencimentoController = TextEditingController();
  final _descricaoController = TextEditingController();

  String _tipoPagamentoSelecionado = "MENSAL";
  Vendedor? _vendedorSelecionado;
  Caixa? _caixaSelecionado;

  bool _vencimentoFixo = false;
  DateTime _dataContrato = DateTime.now();
  bool _obrigarVendedorVenda = false;

  bool _hasPenhora = false;

  final _penhoraDescricaoController = TextEditingController();
  final _penhoraValorEstimadoController = TextEditingController();
  final _jurosMask =
      MaskTextInputFormatter(mask: "##%", filter: {"#": RegExp(r'[0-9]')});

  bool isLimiteCreditoUltrapassado = false;
  String? mensagemErroCredito;

  @override
  void initState() {
    super.initState();

    _dataContratoController.text =
        DateFormat('dd/MM/yyyy').format(_dataContrato);
    _setarJurosPadrao();
    _carregarObrigarVendedorVenda();
    _valorController.addListener(_verificarLimiteCredito);

    // ⚡ se já tiver caixas carregados no momento da criação, aplica o default
    if (widget.caixas != null && widget.caixas!.isNotEmpty) {
      final defaultCaixa = widget.caixas!.where((c) => c.defaultCaixa).toList();
      _caixaSelecionado = defaultCaixa.isNotEmpty ? defaultCaixa.first : null;
    }
  }

  void _setarJurosPadrao() {
    final clienteParam = widget.parametrosCliente.firstWhere(
      (p) => p.chave == 'JUROS_PADRAO_CLIENTE',
      orElse: () => Parametro(
          valor: '', chave: '', id: 0, referenciaId: 0, tipoReferencia: ''),
    );
    final empresaParam = widget.parametrosEmpresa.firstWhere(
      (p) => p.chave == 'JUROS_PADRAO',
      orElse: () => Parametro(
          valor: '', chave: '', id: 0, referenciaId: 0, tipoReferencia: ''),
    );

    final valor =
        (clienteParam.valor.isNotEmpty && clienteParam.valor != "0") == true
            ? clienteParam.valor
            : empresaParam.valor;

    final valorDouble = double.tryParse(valor.replaceAll(',', '.')) ?? 0;

    final valorInt = valorDouble.toInt();

    _jurosController.text = valorInt.toString();
  }

  void _carregarObrigarVendedorVenda() {
    final parametro = widget.parametrosEmpresa.firstWhere(
      (p) => p.chave == 'OBRIGAR_VENDEDOR_VENDA',
      orElse: () => Parametro(
          valor: '', chave: '', id: 0, referenciaId: 0, tipoReferencia: ''),
    );
    _obrigarVendedorVenda = parametro.valor.toLowerCase() == 'true';
  }

  DateTime? _obterDataContratoParaVencimento() {
    final texto = _dataContratoController.text.trim();
    if (texto.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(texto);
    } catch (_) {
      return null;
    }
  }

  DateTime _adicionarMesComAjuste(DateTime dataBase, int meses) {
    final mesAlvo = dataBase.month + meses;
    final anoAlvo = dataBase.year + ((mesAlvo - 1) ~/ 12);
    final mesNormalizado = ((mesAlvo - 1) % 12) + 1;
    final ultimoDiaDoMes = DateTime(anoAlvo, mesNormalizado + 1, 0).day;
    final dia = dataBase.day > ultimoDiaDoMes ? ultimoDiaDoMes : dataBase.day;
    return DateTime(anoAlvo, mesNormalizado, dia);
  }

  void _sugerirPrimeiroVencimento() {
    final dataContrato = _obterDataContratoParaVencimento();
    if (dataContrato == null) return;

    DateTime sugestao;
    switch (_tipoPagamentoSelecionado) {
      case "SEMANAL":
        sugestao = dataContrato.add(const Duration(days: 7));
        break;
      case "QUINZENAL":
        sugestao = dataContrato.add(const Duration(days: 15));
        break;
      case "DIARIO":
        sugestao = dataContrato.add(const Duration(days: 1));
        break;
      case "MENSAL":
      default:
        sugestao = _adicionarMesComAjuste(dataContrato, 1);
        break;
    }

    setState(() {
      _dataPrimeiroVencimentoController.text =
          DateFormat('dd/MM/yyyy').format(sugestao);
    });
  }

  void _verificarLimiteCredito() {
    if (!widget.isSimulation) {
      final valorDigitado = Util.removerMascaraValor(_valorController.text);
      final limite = _getLimiteCredito();

      if (limite > 0) {
        setState(() {
          isLimiteCreditoUltrapassado = valorDigitado > limite;
          mensagemErroCredito = isLimiteCreditoUltrapassado
              ? 'Limite de crédito excedido: ${Util.formatarMoeda(limite)}'
              : null;
        });
      }
    }
  }

  double _getLimiteCredito() {
    final clienteParam = widget.parametrosCliente.firstWhere(
      (p) => p.chave == 'LIMITE_CREDITO_CLIENTE',
      orElse: () => Parametro(
          valor: '', chave: '', id: 0, referenciaId: 0, tipoReferencia: ''),
    );
    final empresaParam = widget.parametrosEmpresa.firstWhere(
      (p) => p.chave == 'LIMITE_EMPRESTIMO',
      orElse: () => Parametro(
          valor: '', chave: '', id: 0, referenciaId: 0, tipoReferencia: ''),
    );

    final clienteValor = double.tryParse(clienteParam.valor);
    final empresaValor = double.tryParse(empresaParam.valor);

    double limiteCredito = 0;
    if (clienteValor != null && clienteValor > 0) {
      limiteCredito = clienteValor;
    } else if (empresaValor != null && empresaValor > 0) {
      limiteCredito = empresaValor;
    }
    return limiteCredito;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final valor = Util.removerMascaraValor(_valorController.text);
      final juros = Util.removerMascaraValor(_jurosController.text);
      final parcelas = int.tryParse(_numeroParcelasController.text) ?? 1;
      final valorPenhora =
          Util.removerMascaraValor(_penhoraValorEstimadoController.text);

      final penhora = _hasPenhora
          ? PenhoraDTO(
              descricao: _penhoraDescricaoController.text,
              valorEstimado: valorPenhora,
            )
          : null;

      widget.onSubmit(
        valor,
        juros,
        parcelas,
        _tipoPagamentoSelecionado,
        penhora,
        _vendedorSelecionado,
        _caixaSelecionado,
        _dataContrato,
        _dataPrimeiroVencimentoController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy')
                .parse(_dataPrimeiroVencimentoController.text)
            : null,
        _vencimentoFixo,
        _descricaoController.text.isNotEmpty ? _descricaoController.text : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildCardContasReceber(),
          const SizedBox(height: 16),
          _buildCardPenhora(),
          const SizedBox(height: 16),
          CustomButton(
            text: widget.isSimulation ? "Simular" : "Próximo",
            onPressed: isLimiteCreditoUltrapassado ? null : _submitForm,
          )
        ],
      ),
    );
  }

  Widget _buildCardContasReceber() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextFormField(
              controller: _dataContratoController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Data do Contrato",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final dataSelecionada = await showDatePicker(
                  context: context,
                  initialDate: _dataContrato,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (dataSelecionada != null) {
                  setState(() {
                    _dataContrato = dataSelecionada;
                    _dataContratoController.text =
                        DateFormat('dd/MM/yyyy').format(dataSelecionada);
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // 🟢 Valor da venda
            InputCustomizado(
              controller: _valorController,
              labelText: 'Valor da Venda',
              type: TextInputType.number,
              inputFormatters: [CurrencyFormatter()],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Favor informar o valor da venda!"
                  : null,
            ),

            if (mensagemErroCredito != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  mensagemErroCredito!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            InputCustomizado(
              controller: _descricaoController,
              labelText: 'Descrição (Opcional)',
              hint: 'Ex. Venda da moto parcelada',
              type: TextInputType.text,
            ),
            const SizedBox(height: 12),
            // 🟢 Juros e Tipo Pagamento
            Row(
              children: [
                Expanded(
                  child: InputCustomizado(
                    controller: _jurosController,
                    labelText: 'M.Lucro (%)',
                    type: TextInputType.number,
                    inputFormatters: [_jurosMask],
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Informe este campo"
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tipoPagamentoSelecionado,
                    items: const [
                      DropdownMenuItem(value: "MENSAL", child: Text("Mensal")),
                      DropdownMenuItem(
                          value: "SEMANAL", child: Text("Semanal")),
                      DropdownMenuItem(value: "DIARIO", child: Text("Diário")),
                      DropdownMenuItem(
                          value: "QUINZENAL", child: Text("Quinzenal")),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _tipoPagamentoSelecionado = newValue ?? "MENSAL";

                        if (_tipoPagamentoSelecionado == "MENSAL") {
                          _numeroParcelasController.text = "1";
                        }
                      });
                      _sugerirPrimeiroVencimento();
                    },
                    decoration: InputDecoration(
                      labelText: "Tipo de Pagamento",
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    icon: Icon(Icons.arrow_drop_down,
                        color: Theme.of(context).primaryColor),
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_obrigarVendedorVenda ||
                (widget.vendedores ?? []).isNotEmpty) ...[
              DropdownButtonFormField<Vendedor>(
                value: _vendedorSelecionado,
                isExpanded: true,
                items: widget.vendedores!.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _vendedorSelecionado = value),
                validator: (value) => _obrigarVendedorVenda && value == null
                    ? "Selecione um vendedor"
                    : null,
                decoration: InputDecoration(
                  labelText: _obrigarVendedorVenda
                      ? "Vendedor"
                      : "Vendedor (opcional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dataPrimeiroVencimentoController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "1º Venc (opcional)",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final dataSelecionada = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (dataSelecionada != null) {
                        setState(() {
                          _dataPrimeiroVencimentoController.text =
                              DateFormat('dd/MM/yyyy').format(dataSelecionada);
                        });
                      }
                    },
                  ),
                ),
                if (_tipoPagamentoSelecionado == "MENSAL")
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomCheckbox(
                          value: _vencimentoFixo,
                          onChanged: (value) {
                            setState(() {
                              _vencimentoFixo = value ?? false;
                            });
                          },
                          label: "Venc. Fixo",
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Vencimento Fixo"),
                                content: const Text(
                                  "Se selecionado, as parcelas sempre vencerão no mesmo dia definido para o 1º vencimento, mesmo que o mês tenha 29, 30 ou 31 dias.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.info_outline,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // 🟢 Caixa
            DropdownButtonFormField<Caixa>(
              value: _caixaSelecionado,
              items: widget.caixas!.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.descricao),
                );
              }).toList(),
              onChanged: (value) => setState(() => _caixaSelecionado = value),
              decoration: InputDecoration(
                labelText: "Responsavel",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 12),
            InputCustomizado(
              controller: _numeroParcelasController,
              labelText: 'Número de parcelas',
              type: TextInputType.number,
              validator: (value) => (value == null || value.isEmpty)
                  ? "Favor informar o número de parcelas!"
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPenhora() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomSwitchTile(
              title: "Incluir Garantia",
              value: _hasPenhora,
              onChanged: (value) => setState(() => _hasPenhora = value),
              icon: Icons.security,
              subtitle: "Habilite para incluir uma garantia no contrato.",
            ),
            if (_hasPenhora) _buildPenhoraFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildPenhoraFields() {
    return Column(
      children: [
        InputCustomizado(
          controller: _penhoraDescricaoController,
          labelText: 'Uma breve descrição da garantia...',
          validator: (value) => (value == null || value.isEmpty)
              ? "Favor informar um nome para o produto!"
              : null,
        ),
        const SizedBox(height: 12),
        InputCustomizado(
          controller: _penhoraValorEstimadoController,
          labelText: 'Está pegando por qual valor?',
          type: TextInputType.number,
          inputFormatters: [CurrencyFormatter()],
          validator: (value) => (value == null || value.isEmpty)
              ? "Favor informar valor para o produto!"
              : null,
        )
      ],
    );
  }
}
