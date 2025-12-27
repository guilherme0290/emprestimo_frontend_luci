import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/emprestimo.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransferenciaVendedoresScreen extends StatefulWidget {
  const TransferenciaVendedoresScreen({super.key});

  @override
  State<TransferenciaVendedoresScreen> createState() =>
      _TransferenciaVendedoresScreenState();
}

class _TransferenciaVendedoresScreenState
    extends State<TransferenciaVendedoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ContasReceberDTO> _contas = [];
  final Set<int> _selecionados = {};
  int? _vendedorFiltroId;
  int? _vendedorDestinoId;
  bool _selectAll = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<VendedorProvider>(context, listen: false)
          .listarVendedores();
      await _buscarContas();
    });
  }

  Future<void> _buscarContas() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);
    final query = _searchController.text.trim();
    final result = await provider.buscarContasReceberPorFiltro(
      query: query,
      vendedorId: _vendedorFiltroId,
    );
    if (!mounted) return;
    setState(() {
      _contas = result;
      _selecionados.clear();
      _selectAll = false;
      _isLoading = false;
    });
  }

  Future<void> _transferir() async {
    if (_vendedorDestinoId == null) {
      _mostrarMensagem("Selecione o vendedor de destino.");
      return;
    }
    if (_selecionados.isEmpty) {
      _mostrarMensagem("Selecione ao menos um contas a receber.");
      return;
    }
    final provider = Provider.of<ContasReceberProvider>(context, listen: false);
    final sucesso = await provider.transferirContasReceberVendedor(
      contasReceberIds: _selecionados.toList(),
      novoVendedorId: _vendedorDestinoId!,
    );
    if (!mounted) return;
    if (sucesso) {
      _mostrarMensagem("Transferencia concluida.");
      await _buscarContas();
    } else {
      _mostrarMensagem("Erro ao transferir.");
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _toggleSelectAll(bool? value) {
    final shouldSelect = value == true;
    setState(() {
      _selectAll = shouldSelect;
      _selecionados.clear();
      if (shouldSelect) {
        _selecionados.addAll(_contas.map((e) => e.id));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendedorProvider = Provider.of<VendedorProvider>(context);
    final vendedores = vendedorProvider.vendedores;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transferencia entre vendedores"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selecione e transfira",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Escolha os contas a receber e o vendedor de destino.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 0,
              color: AppTheme.neutralColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    return Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: "Buscar por descricao ou cliente",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: _buscarContas,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _buscarContas(),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: isNarrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 12) / 2,
                              child: DropdownButtonFormField<int?>(
                                value: _vendedorFiltroId,
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text("Todos os vendedores"),
                                  ),
                                  ...vendedores.map(
                                    (v) => DropdownMenuItem<int?>(
                                      value: v.id,
                                      child: Text(v.nome),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _vendedorFiltroId = value);
                                  _buscarContas();
                                },
                                decoration: const InputDecoration(
                                  labelText: "Filtrar por vendedor",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isNarrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 12) / 2,
                              child: DropdownButtonFormField<int?>(
                                value: _vendedorDestinoId,
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text("Vendedor de destino"),
                                  ),
                                  ...vendedores.map(
                                    (v) => DropdownMenuItem<int?>(
                                      value: v.id,
                                      child: Text(v.nome),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _vendedorDestinoId = value);
                                },
                                decoration: const InputDecoration(
                                  labelText: "Destino",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _selectAll,
                              activeColor: AppTheme.primaryColor,
                              onChanged: _toggleSelectAll,
                            ),
                            const Text("Selecionar todos"),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _transferir,
                              child: const Text("Transferir"),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contas.isEmpty
                    ? const Center(child: Text("Nenhum contas a receber."))
                    : ListView.builder(
                        itemCount: _contas.length,
                        itemBuilder: (context, index) {
                          final conta = _contas[index];
                          final selecionado = _selecionados.contains(conta.id);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: CheckboxListTile(
                              value: selecionado,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selecionados.add(conta.id);
                                  } else {
                                    _selecionados.remove(conta.id);
                                  }
                                  _selectAll =
                                      _selecionados.length == _contas.length;
                                });
                              },
                              title: Text(
                                conta.cliente.nome ?? "Sem nome",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                conta.descricao?.isNotEmpty == true
                                    ? conta.descricao!
                                    : "Sem descricao",
                              ),
                              secondary: Text(
                                "R\$ ${conta.valor.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
