import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/vendedor.dart';
import 'package:emprestimos_app/screens/vendedores/vendedor_create_screen.dart';
import 'package:emprestimos_app/screens/vendedores/vendedor_detail_screen.dart';
import 'package:emprestimos_app/widgets/custom_floating_action_button.dart';
import 'package:emprestimos_app/widgets/list_vendedores_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';

class VendedorListScreen extends StatefulWidget {
  const VendedorListScreen({super.key});

  @override
  State<VendedorListScreen> createState() => _VendedorListScreenState();
}

class _VendedorListScreenState extends State<VendedorListScreen> {
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Provider.of<VendedorProvider>(context, listen: false)
          .listarVendedores()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendedores')),
      body: Consumer<VendedorProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() => _isLoading = true);
                          await provider.listarVendedores();
                          setState(() => _isLoading = false);
                        },
                        child: ListaVendedoresWidget(
                          vendedores: provider.vendedores,
                          searchQuery: _searchQuery,
                        ),
                      ),
              )
            ],
          );
        },
      ),
      floatingActionButton: CustomFloatingActionButton(
        heroTag: "novo_vendedor_fab",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VendedorFormScreen()),
          );

          if (result != null && result is Vendedor) {
            setState(() => _isLoading = true);
            await Provider.of<VendedorProvider>(context, listen: false)
                .listarVendedores();
            setState(() => _isLoading = false);
          }
        },
        icon: Icons.add,
        label: "Novo Vendedor",
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  /// 🔹 Cabeçalho da Tela com Total de Vendedores
  Widget _buildHeader(BuildContext context, VendedorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.group, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(
                  "Vendedores",
                  style: AppTheme.titleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "Total: ${provider.vendedores.length}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Pesquisar vendedor...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  /// 🔹 Ícone dinâmico no Trailing baseado no Status do Vendedor
  Widget _buildTrailingIcon(String status) {
    IconData icon;
    Color color;

    switch (status.toUpperCase()) {
      case "ATIVO":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "INATIVO":
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 26);
  }
}
