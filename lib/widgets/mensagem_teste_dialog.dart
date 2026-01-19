import 'package:emprestimos_app/core/mensagem_utils.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/models/parcela.dart';
import 'package:flutter/material.dart';

typedef SelecionarParcela = ParcelaDTO Function(ContasReceberDTO conta);
typedef MontarTags = Map<String, String> Function(
    ContasReceberDTO conta, ParcelaDTO parcela);
typedef EnviarMensagem = Future<void> Function(
    String telefone, String mensagem);

class MensagemTesteDialog extends StatefulWidget {
  final List<ContasReceberDTO> contas;
  final String template;
  final SelecionarParcela selecionarParcela;
  final MontarTags montarTags;
  final EnviarMensagem onEnviar;
  final String titulo;
  final String infoRodape;

  const MensagemTesteDialog({
    super.key,
    required this.contas,
    required this.template,
    required this.selecionarParcela,
    required this.montarTags,
    required this.onEnviar,
    this.titulo = "Teste de mensagem",
    this.infoRodape = "Este envio nao altera o telefone do cliente.",
  });

  @override
  State<MensagemTesteDialog> createState() => _MensagemTesteDialogState();
}

class _MensagemTesteDialogState extends State<MensagemTesteDialog> {
  late ContasReceberDTO _contaSelecionada;
  late TextEditingController _telefoneController;

  @override
  void initState() {
    super.initState();
    _contaSelecionada = widget.contas.first;
    _telefoneController =
        TextEditingController(text: _contaSelecionada.cliente.telefone ?? "");
  }

  @override
  void dispose() {
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parcelaPreview = widget.selecionarParcela(_contaSelecionada);
    final tags = widget.montarTags(_contaSelecionada, parcelaPreview);
    final mensagemPreview = MensagemUtils.aplicarTags(widget.template, tags);

    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ContasReceberDTO>(
              value: _contaSelecionada,
              isExpanded: true,
              items: widget.contas
                  .map(
                    (conta) => DropdownMenuItem(
                      value: conta,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Contrato #${conta.id} - ${conta.cliente.nome ?? ''}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _contaSelecionada = value;
                  _telefoneController.text =
                      _contaSelecionada.cliente.telefone ?? "";
                });
              },
              decoration: const InputDecoration(
                labelText: "Contrato",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Telefone de destino",
                hintText: "Ex.: 11999999999",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Previa da mensagem",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(mensagemPreview),
            ),
            const SizedBox(height: 8),
            Text(
              widget.infoRodape,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fechar"),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.onEnviar(
                _telefoneController.text, mensagemPreview);
          },
          child: const Text("Enviar teste"),
        ),
      ],
    );
  }
}
