import 'package:dropdown_search/dropdown_search.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/cliente.dart';
import 'package:emprestimos_app/providers/cliente_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ClienteDropdown extends StatefulWidget {
  final Function(Cliente) onClienteSelecionado;

  const ClienteDropdown({Key? key, required this.onClienteSelecionado})
      : super(key: key);

  @override
  State<ClienteDropdown> createState() => _ClienteDropdownState();
}

class _ClienteDropdownState extends State<ClienteDropdown> {
  Cliente? _clienteSelecionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ClienteProvider>(context, listen: false);

      await Future.wait([
        provider.carregarClientes(),
      ]);
    });
  }

  @override
  void setState(VoidCallback fn) {}

  List<Cliente> _filtrarClientes(String filtro) {
    final provider = Provider.of<ClienteProvider>(context, listen: false);

    List<Cliente> clientes = provider.clientes;

    if (filtro.isEmpty) return clientes;
    return clientes
        .where((cliente) =>
            cliente.nome!.toLowerCase().contains(filtro.toLowerCase()) ||
            (cliente.cpf != null && cliente.cpf!.contains(filtro)) ||
            cliente.telefone!.contains(filtro))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = context.watch<ClienteProvider>();

    if (clienteProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownSearch<Cliente>(
      items: (filter, s) => _filtrarClientes(filter),
      compareFn: (a, b) => a.id == b.id,
      popupProps: PopupProps.dialog(
        fit: FlexFit.tight,
        dialogProps: DialogProps(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        showSearchBox: true,
        emptyBuilder: (context, searchEntry) =>
            Center(
              child: Lottie.asset(
                'assets/img/no-results.json',
                height: 140,
                repeat: true,
              ),
            ),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: "Pesquisar cliente...",
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: AppTheme.primaryColor.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          ),
        ),
        containerBuilder: (ctx, popupWidget) {
          return Material(
            color: Colors.transparent, // Remove qualquer fundo
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  minHeight: 300,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: popupWidget,
              ),
            ),
          );
        },
        title:const Center(
          child: Text(
            "Buscar Cliente",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Selecionar Cliente",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      itemAsString: (Cliente c) => "${c.nome} - ${c.cpf ?? 'Sem CPF'}",
      selectedItem: _clienteSelecionado,
      onChanged: (Cliente? cliente) {
        if (cliente != null) {
          setState(() => _clienteSelecionado = cliente);
          widget.onClienteSelecionado(cliente);
        }
      },
    );
    
  }
}
