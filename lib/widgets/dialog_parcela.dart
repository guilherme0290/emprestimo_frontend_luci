import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/baixa-parcela.dart';
import 'package:emprestimos_app/models/baixa_parcela_result.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogBaixaParcelas extends StatefulWidget {
  final List<ParcelaDTO> parcelasSelecionadas;

  const DialogBaixaParcelas({super.key, required this.parcelasSelecionadas});

  @override
  State<DialogBaixaParcelas> createState() => _DialogBaixaParcelasState();
}

class _DialogBaixaParcelasState extends State<DialogBaixaParcelas> {
  final _valorController = TextEditingController();
  double _valorTotal = 0.0;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _calcularTotalParcelas();
  }

  void _calcularTotalParcelas() {
    _valorTotal = widget.parcelasSelecionadas
        .fold(0.0, (sum, parcela) => sum + parcela.valor);
    _valorController.text = Util.formatarMoeda(_valorTotal);
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

  Widget _buildValorTextField() {
    return TextField(
      controller: _valorController,
      keyboardType: TextInputType.number,
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
    return Consumer<ContasReceberProvider>(builder: (context, provider, child) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    });
  }

  void _confirmarBaixa() async {
    final valorInformado = Util.removerMascaraValor(_valorController.text);
    if (valorInformado <= 0) {
      setState(() {
        _mensagemErro = "Valor inválido!";
      });
      return;
    }

    final provider = Provider.of<ContasReceberProvider>(context, listen: false);
    bool algumaBaixaFoiRegistrada = false;
    String? mensagemErro;

    setState(() {
      _mensagemErro = null;
    });

    for (var parcela in widget.parcelasSelecionadas) {
      final baixaDTO = BaixaParcelaDTO(
        valor: valorInformado / widget.parcelasSelecionadas.length,
        parcelaId: parcela.id,
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
