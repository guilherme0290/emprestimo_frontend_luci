import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/providers/cliente_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClienteDeleteScreen extends StatefulWidget {
  final Cliente cliente;

  const ClienteDeleteScreen({super.key, required this.cliente});

  @override
  State<ClienteDeleteScreen> createState() => _ClienteDeleteScreenState();
}

class _ClienteDeleteScreenState extends State<ClienteDeleteScreen> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = true;
  bool _isDeleting = false;
  int _abertos = 0;
  int _fechados = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      setState(() {});
    });
    _carregarStatusContasReceber();
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _carregarStatusContasReceber() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider =
          Provider.of<ContasReceberProvider>(context, listen: false);
      final lista =
          await provider.listarContasReceberCliente(widget.cliente.id!);

      final abertos = lista
          .where((e) => e.statusContasReceber.toUpperCase() != 'QUITADO')
          .length;

      if (!mounted) return;
      setState(() {
        _abertos = abertos;
        _fechados = lista.length - abertos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Erro ao consultar contratos do cliente.";
        _isLoading = false;
      });
    }
  }

  bool get _confirmado {
    return _confirmController.text.trim().toLowerCase() == 'excluir';
  }

  Future<void> _excluirCliente() async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
    });

    final provider = Provider.of<ClienteProvider>(context, listen: false);
    final sucesso = await provider.excluirCliente(widget.cliente.id!);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cliente excluido com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _isDeleting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? "Erro ao excluir cliente."),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildStatusResumo() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
      );
    }

    if (_abertos == 0 && _fechados == 0) {
      return const Text("Nenhum contrato encontrado para este cliente.");
    }

    return Text(
      "Este cliente possui $_abertos contrato(s) em aberto e $_fechados contrato(s) quitados.",
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Excluir cliente"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppBackground(
          child: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red.shade400),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Excluir um cliente apaga todo o historico, incluindo valores recebidos e a receber. Essa acao nao pode ser desfeita.",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Se voce so precisa parar de usar o cliente, o recomendado e apenas inativar.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusResumo(),
                  const SizedBox(height: 24),
                  Text(
                    "Para confirmar, digite EXCLUIR abaixo:",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmController,
                    decoration: InputDecoration(
                      labelText: "Digite EXCLUIR",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: _isDeleting ? "Excluindo..." : "Excluir cliente",
                    onPressed: _confirmado && !_isDeleting
                        ? _excluirCliente
                        : null,
                    enabled: _confirmado && !_isDeleting,
                    backgroundColor: Colors.red.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
