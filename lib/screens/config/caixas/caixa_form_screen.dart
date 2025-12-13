import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/caixa.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/currency_formatter.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:emprestimos_app/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CaixaFormScreen extends StatefulWidget {
  final Caixa? caixa;
  const CaixaFormScreen({super.key, this.caixa});

  @override
  State<CaixaFormScreen> createState() => _CaixaFormScreenState();
}

class _CaixaFormScreenState extends State<CaixaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorInicialController = TextEditingController();
  bool _defaultCaixa = false;

  @override
  void initState() {
    super.initState();
    if (widget.caixa != null) {
      _descricaoController.text = widget.caixa!.descricao;

      final formatador =
          NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);
      _valorInicialController.text =
          formatador.format(widget.caixa!.valorInicial).trim();

      _defaultCaixa = widget.caixa!.defaultCaixa;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorInicialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaixaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caixa != null ? 'Editar Caixa' : 'Novo Caixa'),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InputCustomizado(
                  controller: _descricaoController,
                  labelText: 'Descrição',
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Favor informar a descrição!"
                      : null,
                ),
                const SizedBox(height: 12),
                InputCustomizado(
                  controller: _valorInicialController,
                  labelText: 'Valor Inicial',
                  type: TextInputType.number,
                  inputFormatters: [CurrencyFormatter()],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Caixa Padrão'),
                  value: _defaultCaixa,
                  onChanged: (value) => setState(() => _defaultCaixa = value),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text:
                      widget.caixa != null ? 'Atualizar Caixa' : 'Abrir Caixa',
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final caixa = Caixa(
                      id: widget.caixa?.id,
                      descricao: _descricaoController.text,
                      valorInicial: _valorInicialController.text.trim().isEmpty
                          ? 0.0
                          : Util.removerMascaraValor(
                              _valorInicialController.text),
                      defaultCaixa: _defaultCaixa,
                    );

                    if (widget.caixa == null) {
                      await provider.abrirCaixa(caixa);
                    } else {
                      await provider.editarCaixa(caixa);
                    }
                    Navigator.pop(context, true);
                  },
                ),
                if (widget.caixa != null) const SizedBox(height: 16),
                if (widget.caixa != null)
                  CustomButton(
                      text: 'Encerrar Caixa',
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        await provider.fecharCaixa(widget.caixa!.id!);
                        Navigator.pop(context);
                      }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
