import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vendedor.dart';
import '../../providers/vendedor_provider.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/theme.dart';

class TrocarVendedorScreen extends StatefulWidget {
  final int vendedorDesligadoId;

  const TrocarVendedorScreen({required this.vendedorDesligadoId, Key? key})
      : super(key: key);

  @override
  State<TrocarVendedorScreen> createState() => _TrocarVendedorScreenState();
}

class _TrocarVendedorScreenState extends State<TrocarVendedorScreen> {
  int? _vendedorSelecionadoId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<VendedorProvider>(context, listen: false).listarVendedores();
    });
  }

  void _confirmarTroca() async {
    if (_vendedorSelecionadoId == null) return;

    setState(() => _isSubmitting = true);

    final provider = Provider.of<VendedorProvider>(context, listen: false);
    final sucesso = await provider.transferirContasReceber(
      vendedorDesligadoId: widget.vendedorDesligadoId,
      novoVendedorId: _vendedorSelecionadoId!,
    );

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transferência concluída com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Erro na transferência."),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendedorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transferir Vendas "),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selecione o novo vendedor para receber as vendas e/ou clientes:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _vendedorSelecionadoId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Novo Vendedor",
                  border: OutlineInputBorder(),
                ),
                items: provider.vendedores
                    .where((c) => c.id != widget.vendedorDesligadoId)
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nome),
                        ))
                    .toList(),
                onChanged: (novoId) {
                  setState(() {
                    _vendedorSelecionadoId = novoId;
                  });
                },
                validator: (value) =>
                    value == null ? "Escolha um vendedor" : null,
              ),
              const SizedBox(height: 30),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: "Confirmar Transferência",
                      onPressed: _confirmarTroca,
                      backgroundColor: AppTheme.primaryColor,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
