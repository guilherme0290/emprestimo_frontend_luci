import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/caixa.dart';
import 'package:emprestimos_app/models/parametro.dart';
import 'package:emprestimos_app/models/penhora.dart';
import 'package:emprestimos_app/models/request_emprestimo.dart';
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
    String tipoContrato,
    double valor,
    double juros,
    int parcelas,
    String tipoPagamento,
    CobrancaRecorrenteDTO? cobrancaRecorrente,
    PenhoraDTO? penhora,
    Vendedor? vendedor,
    Caixa? caixa,
    DateTime dataContrato,
    DateTime? dataPrimeiroVencimento,
    bool vencimentoFixo,
    String politicaDiaNaoUtil,
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
  final _diaVencimentoController = TextEditingController();
  final _qtdCiclosController = TextEditingController();
  final _dataFimController = TextEditingController();

  String _tipoContratoSelecionado = "PARCELADO";
  String _tipoPagamentoSelecionado = "MENSAL";
  String _terminoRecorrencia = "SEM_FIM";
  String _politicaVencimento = "MANTER_DIA";
  String _politicaFeriado = "POSTERGAR";
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
  int _currentStep = 0;

  bool get _isRecorrente => _tipoContratoSelecionado == "RECORRENTE";

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

  DateTime? _obterPrimeiroVencimentoInformado() {
    final texto = _dataPrimeiroVencimentoController.text.trim();
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
      final parcelas = _isRecorrente
          ? (int.tryParse(_qtdCiclosController.text) ?? 1)
          : (int.tryParse(_numeroParcelasController.text) ?? 1);
      final valorPenhora =
          Util.removerMascaraValor(_penhoraValorEstimadoController.text);

      final penhora = _hasPenhora
          ? PenhoraDTO(
              descricao: _penhoraDescricaoController.text,
              valorEstimado: valorPenhora,
            )
          : null;

      widget.onSubmit(
        _tipoContratoSelecionado,
        valor,
        _isRecorrente ? 0.0 : juros,
        parcelas,
        _tipoPagamentoSelecionado,
        _montarCobrancaRecorrente(valor),
        penhora,
        _vendedorSelecionado,
        _caixaSelecionado,
        _dataContrato,
        _dataPrimeiroVencimentoController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy')
                .parse(_dataPrimeiroVencimentoController.text)
            : null,
        _vencimentoFixo,
        _politicaFeriado,
        _descricaoController.text.isNotEmpty ? _descricaoController.text : null,
      );
    }
  }

  CobrancaRecorrenteDTO? _montarCobrancaRecorrente(double valor) {
    if (!_isRecorrente) return null;

    final dia = int.tryParse(_diaVencimentoController.text);
    final ciclos = int.tryParse(_qtdCiclosController.text);
    DateTime? dataFim;
    if (_dataFimController.text.isNotEmpty) {
      dataFim = DateFormat('dd/MM/yyyy').parse(_dataFimController.text);
    }

    return CobrancaRecorrenteDTO(
      periodicidade: _tipoPagamentoSelecionado,
      intervalo: 1,
      valorBase: valor,
      dataInicio: _dataContrato,
      diaVencimento: _tipoPagamentoSelecionado == "MENSAL" ? dia : null,
      tipoTermino: _terminoRecorrencia,
      dataFim: dataFim,
      quantidadeCiclos: _terminoRecorrencia == "POR_CICLOS" ? ciclos : null,
      politicaVencimento: _politicaVencimento,
      politicaDiaNaoUtil: _politicaFeriado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Stepper(
            currentStep: _currentStep,
            physics: const ClampingScrollPhysics(),
            controlsBuilder: (context, details) => const SizedBox.shrink(),
            onStepTapped: (index) => setState(() => _currentStep = index),
            steps: [
              Step(
                isActive: _currentStep >= 0,
                title: const Text("1. Tipo e Valor"),
                subtitle: const Text("Defina o tipo do contrato"),
                content: _buildStepTipoEValor(),
              ),
              Step(
                isActive: _currentStep >= 1,
                title: const Text("2. Cobrança"),
                subtitle: const Text("Configure periodicidade e vencimentos"),
                content: _buildStepCobranca(),
              ),
              Step(
                isActive: _currentStep >= 2,
                title: const Text("3. Vínculos"),
                subtitle: const Text("Vendedor, caixa e garantia"),
                content: _buildStepVinculosEGarantia(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text("Voltar"),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: _currentStep < 2
                      ? "Continuar"
                      : (widget.isSimulation ? "Simular" : "Próximo"),
                  onPressed: isLimiteCreditoUltrapassado
                      ? null
                      : () {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                            return;
                          }
                          _submitForm();
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepTipoEValor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Escolha se o contrato é parcelado ou recorrente e informe os dados principais.",
        ),
        const SizedBox(height: 12),
        _buildTipoContratoSelector(),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dataContratoController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: _isRecorrente ? "Data de Início" : "Data do Contrato",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        InputCustomizado(
          controller: _valorController,
          labelText: _isRecorrente ? 'Valor por Período' : 'Valor da Venda',
          type: TextInputType.number,
          inputFormatters: [CurrencyFormatter()],
          validator: (value) => (value == null || value.isEmpty)
              ? "Favor informar o valor!"
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
      ],
    );
  }

  Widget _buildStepCobranca() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Agora defina como será cobrado: frequência, vencimento e quantidade.",
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final empilhar = constraints.maxWidth < 430;
            final juros = InputCustomizado(
              controller: _jurosController,
              labelText: 'M.Lucro (%)',
              type: TextInputType.number,
              inputFormatters: [_jurosMask],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Informe este campo"
                  : null,
            );
            final tipo = DropdownButtonFormField<String>(
              value: _tipoPagamentoSelecionado,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "MENSAL", child: Text("Mensal")),
                DropdownMenuItem(value: "SEMANAL", child: Text("Semanal")),
                DropdownMenuItem(value: "DIARIO", child: Text("Diário")),
                DropdownMenuItem(value: "QUINZENAL", child: Text("Quinzenal")),
              ],
              selectedItemBuilder: (context) => const [
                Text("Mensal", overflow: TextOverflow.ellipsis, maxLines: 1),
                Text("Semanal", overflow: TextOverflow.ellipsis, maxLines: 1),
                Text("Diário", overflow: TextOverflow.ellipsis, maxLines: 1),
                Text("Quinzenal", overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _tipoPagamentoSelecionado = newValue ?? "MENSAL";
                  if (!_isRecorrente && _tipoPagamentoSelecionado == "MENSAL") {
                    _numeroParcelasController.text = "1";
                  }
                });
                _sugerirPrimeiroVencimento();
              },
              decoration: InputDecoration(
                labelText: "Tipo de Pagamento",
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              icon: Icon(Icons.keyboard_arrow_down,
                  color: Theme.of(context).primaryColor),
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              style: Theme.of(context).textTheme.bodyMedium,
            );
            if (_isRecorrente) return tipo;
            if (empilhar) {
              return Column(
                children: [
                  juros,
                  const SizedBox(height: 12),
                  tipo,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: juros),
                const SizedBox(width: 12),
                Expanded(child: tipo),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        if (_isRecorrente) ...[
          _buildCamposRecorrencia(),
          const SizedBox(height: 12),
        ],
        Text(
          "1º vencimento é opcional. Informe apenas se quiser fixar a data inicial da cobrança.",
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dataPrimeiroVencimentoController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "1º Vencimento (Opcional)",
                  helperText:
                      "Opcional: se nao informar, o sistema calcula automaticamente.",
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
            if (_tipoPagamentoSelecionado == "MENSAL" && !_isRecorrente)
              Expanded(
                child: CustomCheckbox(
                  value: _vencimentoFixo,
                  onChanged: (value) =>
                      setState(() => _vencimentoFixo = value ?? false),
                  label: "Venc. Fixo",
                ),
              ),
          ],
        ),
        if (!_isRecorrente) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _politicaFeriado,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                  value: "POSTERGAR", child: Text("Feriado/FDS: Postergar")),
              DropdownMenuItem(
                  value: "ANTECIPAR", child: Text("Feriado/FDS: Antecipar")),
              DropdownMenuItem(
                  value: "IGNORAR", child: Text("Feriado/FDS: Ignorar")),
            ],
            selectedItemBuilder: (context) => const [
              Text("Postergar", overflow: TextOverflow.ellipsis),
              Text("Antecipar", overflow: TextOverflow.ellipsis),
              Text("Ignorar", overflow: TextOverflow.ellipsis),
            ],
            onChanged: (v) =>
                setState(() => _politicaFeriado = v ?? "POSTERGAR"),
            decoration: const InputDecoration(
              labelText: "Política feriado/fds",
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (!_isRecorrente)
          InputCustomizado(
            controller: _numeroParcelasController,
            labelText: 'Número de parcelas',
            type: TextInputType.number,
            validator: (value) => (value == null || value.isEmpty)
                ? "Favor informar o número de parcelas!"
                : null,
          ),
        if (_isRecorrente) _buildPreviewRecorrencia(),
      ],
    );
  }

  Widget _buildStepVinculosEGarantia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Finalize vinculando vendedor/caixa e, se necessário, inclua garantia.",
        ),
        const SizedBox(height: 12),
        if (_obrigarVendedorVenda || (widget.vendedores ?? []).isNotEmpty) ...[
          DropdownButtonFormField<Vendedor>(
            value: _vendedorSelecionado,
            isExpanded: true,
            items: widget.vendedores!.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c.nome, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) => setState(() => _vendedorSelecionado = value),
            validator: (value) => _obrigarVendedorVenda && value == null
                ? "Selecione um vendedor"
                : null,
            decoration: InputDecoration(
              labelText:
                  _obrigarVendedorVenda ? "Vendedor" : "Vendedor (opcional)",
              helperText: _obrigarVendedorVenda
                  ? "Obrigatório por configuração da empresa."
                  : "Opcional",
            ),
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<Caixa>(
          value: _caixaSelecionado,
          isExpanded: true,
          items: widget.caixas!.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c.descricao,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _caixaSelecionado = value),
          decoration: const InputDecoration(
            labelText: "Caixa (opcional)",
            helperText: "Opcional",
          ),
        ),
        const SizedBox(height: 12),
        _buildCardPenhora(),
      ],
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
            _buildTipoContratoSelector(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dataContratoController,
              readOnly: true,
              decoration: InputDecoration(
                labelText:
                    _isRecorrente ? "Data de Início" : "Data do Contrato",
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
              labelText: _isRecorrente ? 'Valor por Período' : 'Valor da Venda',
              type: TextInputType.number,
              inputFormatters: [CurrencyFormatter()],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Favor informar o valor!"
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
            LayoutBuilder(
              builder: (context, constraints) {
                final empilhar = constraints.maxWidth < 430;
                final juros = InputCustomizado(
                  controller: _jurosController,
                  labelText: 'M.Lucro (%)',
                  type: TextInputType.number,
                  inputFormatters: [_jurosMask],
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Informe este campo"
                      : null,
                );
                final tipo = DropdownButtonFormField<String>(
                  value: _tipoPagamentoSelecionado,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "MENSAL", child: Text("Mensal")),
                    DropdownMenuItem(value: "SEMANAL", child: Text("Semanal")),
                    DropdownMenuItem(value: "DIARIO", child: Text("Diário")),
                    DropdownMenuItem(
                        value: "QUINZENAL", child: Text("Quinzenal")),
                  ],
                  selectedItemBuilder: (context) => const [
                    Text("Mensal",
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text("Semanal",
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text("Diário",
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text("Quinzenal",
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoPagamentoSelecionado = newValue ?? "MENSAL";
                      if (!_isRecorrente &&
                          _tipoPagamentoSelecionado == "MENSAL") {
                        _numeroParcelasController.text = "1";
                      }
                    });
                    _sugerirPrimeiroVencimento();
                  },
                  decoration: InputDecoration(
                    labelText: "Tipo de Pagamento",
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor),
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
                if (_isRecorrente) return tipo;
                if (empilhar) {
                  return Column(
                    children: [
                      juros,
                      const SizedBox(height: 12),
                      tipo,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: juros),
                    const SizedBox(width: 12),
                    Expanded(child: tipo),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            if (_isRecorrente) ...[
              _buildCamposRecorrencia(),
              const SizedBox(height: 12),
            ],

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
                      labelText: "1º Vencimento (Opcional)",
                      helperText:
                          "Opcional: se nao informar, o sistema calcula automaticamente.",
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
                if (_tipoPagamentoSelecionado == "MENSAL" && !_isRecorrente)
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
              isExpanded: true,
              items: widget.caixas!.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    c.descricao,
                    overflow: TextOverflow.ellipsis,
                  ),
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
            if (!_isRecorrente)
              InputCustomizado(
                controller: _numeroParcelasController,
                labelText: 'Número de parcelas',
                type: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Favor informar o número de parcelas!"
                    : null,
              ),
            if (_isRecorrente) _buildPreviewRecorrencia(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoContratoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tipo de Contrato",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text("Parcelado"),
                selected: _tipoContratoSelecionado == "PARCELADO",
                onSelected: (_) {
                  setState(() {
                    _tipoContratoSelecionado = "PARCELADO";
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text("Recorrente"),
                selected: _tipoContratoSelecionado == "RECORRENTE",
                onSelected: (_) {
                  setState(() {
                    _tipoContratoSelecionado = "RECORRENTE";
                    _jurosController.text = "0";
                    _numeroParcelasController.text = "1";
                    if (_tipoPagamentoSelecionado == "MENSAL" &&
                        _diaVencimentoController.text.isEmpty) {
                      _diaVencimentoController.text =
                          _dataContrato.day.toString();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCamposRecorrencia() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InputCustomizado(
                controller: _diaVencimentoController,
                labelText: 'Dia de vencimento',
                type: TextInputType.number,
                validator: (value) {
                  if (_tipoPagamentoSelecionado != "MENSAL") return null;
                  if (value == null || value.isEmpty) return "Informe o dia";
                  final d = int.tryParse(value);
                  if (d == null || d < 1 || d > 31)
                    return "Dia inválido (1-31)";
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _politicaVencimento,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: "MANTER_DIA", child: Text("Manter dia")),
                  DropdownMenuItem(
                      value: "ULTIMO_DIA_MES", child: Text("Último dia mês")),
                ],
                selectedItemBuilder: (context) => const [
                  Text("Manter dia", overflow: TextOverflow.ellipsis),
                  Text("Último dia", overflow: TextOverflow.ellipsis),
                ],
                onChanged: (v) =>
                    setState(() => _politicaVencimento = v ?? "MANTER_DIA"),
                decoration: const InputDecoration(
                  labelText: "Política de venc.",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _politicaFeriado,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
                value: "POSTERGAR", child: Text("Feriado: Postergar")),
            DropdownMenuItem(
                value: "ANTECIPAR", child: Text("Feriado: Antecipar")),
            DropdownMenuItem(value: "IGNORAR", child: Text("Feriado: Ignorar")),
          ],
          selectedItemBuilder: (context) => const [
            Text("Postergar", overflow: TextOverflow.ellipsis),
            Text("Antecipar", overflow: TextOverflow.ellipsis),
            Text("Ignorar", overflow: TextOverflow.ellipsis),
          ],
          onChanged: (v) => setState(() => _politicaFeriado = v ?? "POSTERGAR"),
          decoration: const InputDecoration(
            labelText: "Política feriado/fds",
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _terminoRecorrencia,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "SEM_FIM", child: Text("Sem data final")),
            DropdownMenuItem(
                value: "POR_DATA", child: Text("Encerrar em data")),
            DropdownMenuItem(
                value: "POR_CICLOS", child: Text("Encerrar por ciclos")),
          ],
          onChanged: (v) =>
              setState(() => _terminoRecorrencia = v ?? "SEM_FIM"),
          decoration: const InputDecoration(labelText: "Término"),
        ),
        if (_terminoRecorrencia == "POR_DATA") ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _dataFimController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Data de encerramento",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            validator: (value) {
              if (_terminoRecorrencia != "POR_DATA") return null;
              return (value == null || value.isEmpty)
                  ? "Informe a data final"
                  : null;
            },
            onTap: () async {
              final dataSelecionada = await showDatePicker(
                context: context,
                initialDate: _dataContrato,
                firstDate: _dataContrato,
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (dataSelecionada != null) {
                setState(() {
                  _dataFimController.text =
                      DateFormat('dd/MM/yyyy').format(dataSelecionada);
                });
              }
            },
          ),
        ],
        if (_terminoRecorrencia == "POR_CICLOS") ...[
          const SizedBox(height: 12),
          InputCustomizado(
            controller: _qtdCiclosController,
            labelText: "Quantidade de ciclos",
            type: TextInputType.number,
            validator: (value) {
              if (_terminoRecorrencia != "POR_CICLOS") return null;
              if (value == null || value.isEmpty) return "Informe os ciclos";
              final n = int.tryParse(value);
              if (n == null || n <= 0) return "Quantidade inválida";
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewRecorrencia() {
    final valor = Util.removerMascaraValor(_valorController.text);
    if (valor <= 0) return const SizedBox.shrink();

    final primeiroVencimento = _obterPrimeiroVencimentoInformado();
    final inicio = _obterDataContratoParaVencimento() ?? DateTime.now();
    final proximas = List.generate(6, (idx) {
      if (_tipoPagamentoSelecionado == "MENSAL") {
        final dataBaseMensal = primeiroVencimento ?? inicio;
        final dia =
            int.tryParse(_diaVencimentoController.text) ?? dataBaseMensal.day;
        final deslocamento = primeiroVencimento != null ? idx : (idx + 1);
        final base = DateTime(
          dataBaseMensal.year,
          dataBaseMensal.month + deslocamento,
          1,
        );
        final ultimoDia = DateTime(base.year, base.month + 1, 0).day;
        final diaFinal = _politicaVencimento == "ULTIMO_DIA_MES"
            ? ultimoDia
            : (dia > ultimoDia ? ultimoDia : dia);
        return _ajustarDiaNaoUtilPreview(
          DateTime(base.year, base.month, diaFinal),
        );
      }
      if (_tipoPagamentoSelecionado == "SEMANAL") {
        final dataBase = primeiroVencimento ?? inicio;
        final deslocamento = primeiroVencimento != null ? idx : (idx + 1);
        return _ajustarDiaNaoUtilPreview(
          dataBase.add(Duration(days: 7 * deslocamento)),
        );
      }
      if (_tipoPagamentoSelecionado == "QUINZENAL") {
        final dataBase = primeiroVencimento ?? inicio;
        final deslocamento = primeiroVencimento != null ? idx : (idx + 1);
        return _ajustarDiaNaoUtilPreview(
          dataBase.add(Duration(days: 15 * deslocamento)),
        );
      }
      final dataBase = primeiroVencimento ?? inicio;
      final deslocamento = primeiroVencimento != null ? idx : (idx + 1);
      return _ajustarDiaNaoUtilPreview(
        dataBase.add(Duration(days: deslocamento)),
      );
    });

    return Card(
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Prévia das próximas cobranças",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...proximas.asMap().entries.map((e) {
              final i = e.key + 1;
              final d = DateFormat('dd/MM/yyyy').format(e.value);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("$i. $d  •  ${Util.formatarMoeda(valor)}"),
              );
            }),
          ],
        ),
      ),
    );
  }

  DateTime _ajustarDiaNaoUtilPreview(DateTime data) {
    if (_politicaFeriado == "IGNORAR") return data;

    bool fimDeSemana(DateTime d) =>
        d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

    if (!fimDeSemana(data)) return data;

    if (_politicaFeriado == "ANTECIPAR") {
      DateTime atual = data;
      while (fimDeSemana(atual)) {
        atual = atual.subtract(const Duration(days: 1));
      }
      return atual;
    }

    DateTime atual = data;
    while (fimDeSemana(atual)) {
      atual = atual.add(const Duration(days: 1));
    }
    return atual;
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
