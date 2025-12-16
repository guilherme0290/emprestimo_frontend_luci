import 'package:emprestimos_app/core/status_baixa_enum.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/baixa-parcela.dart';
import 'package:emprestimos_app/models/baixa_parcela_result.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogBaixaParcelas extends StatefulWidget {
  final List<ParcelaDTO> parcelasSelecionadas;
  final ContasReceberDTO contasReceber;

  const DialogBaixaParcelas({
    super.key,
    required this.parcelasSelecionadas,
    required this.contasReceber,
  });

  @override
  State<DialogBaixaParcelas> createState() => _DialogBaixaParcelasState();
}

class _DialogBaixaParcelasState extends State<DialogBaixaParcelas> {
  final _valorController = TextEditingController();

  double _valorParcelas = 0.0;
  double _valorJuros = 0.0;
  double _valorTotalComJuros = 0.0;

  String? _mensagemErro;

  StatusBaixaEnum _tipoBaixaMensal = StatusBaixaEnum.TOTAL;

  bool get _isMensal =>
      (widget.contasReceber.tipoPagamento).toUpperCase() == "MENSAL";

  @override
  void initState() {
    super.initState();
    _recalcularTotais();
    _aplicarValorPorTipo();
  }

  void _recalcularTotais() {
    // ✅ valor das parcelas já vem com juros embutido
    _valorTotalComJuros = widget.parcelasSelecionadas.fold(
      0.0,
      (sum, p) => sum + p.valor,
    );

    // ✅ juros separado só para opção "Juros"
    _valorJuros = widget.parcelasSelecionadas.fold(
      0.0,
      (sum, p) => sum + (p.jurosParcela ?? 0.0),
    );

    // ✅ opcional: só pra exibir no resumo "Total parcelas" (mesmo que seja o total final)
    _valorParcelas = _valorTotalComJuros;
  }

  void _aplicarValorPorTipo() {
    double v;

    if (!_isMensal) {
      v = _valorTotalComJuros; // comportamento antigo
    } else {
      switch (_tipoBaixaMensal) {
        case StatusBaixaEnum.JUROS:
          v = _valorJuros;
          break;
        case StatusBaixaEnum.TOTAL:
          v = _valorTotalComJuros;
          break;
        case StatusBaixaEnum.PARCIAL:
          v = _valorTotalComJuros; // começa no máximo, mas deixa editar
          break;
        case StatusBaixaEnum.QUITADA:
          v = _valorTotalComJuros;
          break;
      }
    }

    _valorController.text = Util.formatarMoeda(v);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            const SizedBox(height: 12),
            if (_isMensal) ...[
              _buildTipoBaixaMensal(),
              const SizedBox(height: 12),
              _buildResumoMensal(),
              const SizedBox(height: 12),
            ],
            _buildValorTextField(),
            const SizedBox(height: 8),
            if (_mensagemErro != null) ...[
              Text(
                _mensagemErro!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Icon(Icons.payments, size: 40, color: Colors.blueAccent),
        SizedBox(height: 8),
        Text(
          "Dar Baixa nas Parcelas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTipoBaixaMensal() {
    return Column(
      children: [
        RadioListTile<StatusBaixaEnum>(
          value: StatusBaixaEnum.JUROS,
          groupValue: _tipoBaixaMensal,
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _tipoBaixaMensal = v;
              _mensagemErro = null;
              _aplicarValorPorTipo();
            });
          },
          title: const Text("Juros"),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<StatusBaixaEnum>(
          value: StatusBaixaEnum.TOTAL,
          groupValue: _tipoBaixaMensal,
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _tipoBaixaMensal = v;
              _mensagemErro = null;
              _aplicarValorPorTipo();
            });
          },
          title: const Text("Total (valor + juros)"),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<StatusBaixaEnum>(
          value: StatusBaixaEnum.PARCIAL,
          groupValue: _tipoBaixaMensal,
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _tipoBaixaMensal = v;
              _mensagemErro = null;
              _aplicarValorPorTipo();
            });
          },
          title: const Text("Parcial (digitar valor)"),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildResumoMensal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Juros: ${Util.formatarMoeda(_valorJuros)}"),
          const SizedBox(height: 4),
          Text("Total parcelas: ${Util.formatarMoeda(_valorParcelas)}"),
          const SizedBox(height: 4),
          Text(
            "Total (com juros): ${Util.formatarMoeda(_valorTotalComJuros)}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildValorTextField() {
    final readOnly = _isMensal && _tipoBaixaMensal != StatusBaixaEnum.PARCIAL;

    return TextField(
      controller: _valorController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: "Valor Pago",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.attach_money),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Consumer<ContasReceberProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: provider.isLoading ? null : _confirmarBaixa,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  void _confirmarBaixa() async {
    final valorInformado = Util.removerMascaraValor(_valorController.text);

    if (valorInformado <= 0) {
      setState(() => _mensagemErro = "Valor inválido!");
      return;
    }

    // Validações extras do mensal
    if (_isMensal) {
      if (_tipoBaixaMensal == StatusBaixaEnum.JUROS && _valorJuros <= 0) {
        setState(() => _mensagemErro = "Não há juros para baixar.");
        return;
      }

      if (valorInformado > _valorTotalComJuros) {
        setState(() => _mensagemErro =
            "Valor maior que o total permitido (${Util.formatarMoeda(_valorTotalComJuros)}).");
        return;
      }
    } else {
      if (valorInformado > _valorParcelas) {
        setState(() => _mensagemErro =
            "Valor maior que o total das parcelas (${Util.formatarMoeda(_valorParcelas)}).");
        return;
      }
    }

    final provider = Provider.of<ContasReceberProvider>(context, listen: false);

    bool algumaBaixaFoiRegistrada = false;
    String? mensagemErro;

    setState(() => _mensagemErro = null);

    // Divide proporcionalmente (igual) entre parcelas selecionadas (mantém seu padrão atual)
    final valorPorParcela = valorInformado / widget.parcelasSelecionadas.length;

    for (var parcela in widget.parcelasSelecionadas) {
      final baixaDTO = BaixaParcelaDTO(
        valor: valorPorParcela,
        parcelaId: parcela.id,

        // ✅ Se você tiver como enviar pro backend o tipo, adicione no DTO:
        // tipoBaixa: _isMensal ? _tipoBaixaMensal.name : null,
      );

      final resultado = await provider.darBaixaParcela(baixaDTO);

      if (resultado.sucesso) {
        algumaBaixaFoiRegistrada = true;
      } else {
        mensagemErro = resultado.mensagemErro;
        break;
      }
    }

    if (algumaBaixaFoiRegistrada) {
      Navigator.pop(context, BaixaParcelaResult(sucesso: true));
    } else {
      setState(() {
        _mensagemErro = mensagemErro ?? "Erro ao registrar baixa.";
      });
    }
  }
}
