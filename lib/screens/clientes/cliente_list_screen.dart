import 'package:emprestimos_app/core/role.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cliente_provider.dart';

import 'cliente_detail_screen.dart';
import 'cliente_create_screen.dart';
import '../../core/theme/theme.dart'; // Importa o tema global

class ClienteListScreen extends StatefulWidget {
  const ClienteListScreen({Key? key}) : super(key: key);

  @override
  _ClienteListScreenState createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  String _searchQuery = "";
  bool _isLoading = true;
  bool _isEmpresa = false;
  bool _loading = true;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _verificarTipoUsuario();
    Future.microtask(() async {
      if (!mounted) return;
      await Provider.of<ClienteProvider>(context, listen: false)
          .carregarClientes()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  Future<void> _verificarTipoUsuario() async {
    if (_authProvider == null) return;
    _authProvider!.carregarDadosSalvos();

    final roleStr = _authProvider!.loginResponse?.role ?? '';
    final roleEnum = Role.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => Role.EMPRESA,
    );

    setState(() {
      _isEmpresa = roleEnum == Role.EMPRESA;
      _loading = _authProvider!.isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(context);
    final listaClientes = _isLoading
        ? []
        : clienteProvider.clientes
            .where((cliente) => cliente.nome!
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Clientes"),
          Text(
            "${listaClientes.length}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      )),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          //_buildResumoGeral(listaClientes.length),
          const SizedBox(height: 10),
          Expanded(
            child:
                _buildListaClientes(clienteProvider, listaClientes, _isLoading),
          ),
        ],
      ),
      // 👇 mostra o FAB apenas se for empresa
      floatingActionButton: _isEmpresa
          ? CustomFloatingActionButton(
              heroTag: "novo_cliente_fab",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ClienteFormScreen()),
                ).then((_) {
                  clienteProvider.carregarClientes();
                });
              },
              icon: Icons.add,
              label: "Novo Cliente",
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null, // não exibe se não for empresa
    );
  }

  /// 🔹 Barra de pesquisa
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Pesquisar cliente...",
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

  /// 🔹 Resumo total de clientes cadastrados
  Widget _buildResumoGeral(int qtd) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              "Clientes cadastrados: $qtd",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Lista de clientes
  Widget _buildListaClientes(
      ClienteProvider provider, List<dynamic> lista, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text("Erro: ${provider.errorMessage}"));
    }

    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/nenhum_cliente_encontrado.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "Nenhum cliente encontrado.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9E9E), // equivalente a Colors.grey[500]
              ),
            ),
          ],
        ),
      );
    }

    return AppBackground(
      child: RefreshIndicator(
        onRefresh: () async {
          await provider.carregarClientes();
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: lista.length,
          itemBuilder: (context, index) {
            final cliente = lista[index];

            Color scoreColor;
            switch (cliente.scoreDescricao?.toLowerCase()) {
              case "ruim":
                scoreColor = Colors.red.shade400;
                break;
              case "bom":
                scoreColor = Colors.orange.shade400;
                break;
              case "otimo":
                scoreColor = Colors.green.shade400;
                break;
              default:
                scoreColor = Colors.grey;
            }

            IconData statusIcon;
            Color statusColor;
            String statusLabel = cliente.statusContasReceber ?? "Desconhecido";

            switch (statusLabel) {
              case "ATRASADO":
                statusIcon = Icons.warning_amber_rounded;
                statusColor = Colors.red.shade400;
                break;
              case "QUITADO":
                statusIcon = Icons.check_circle;
                statusColor = Colors.green.shade400;
                break;
              case "ATIVO":
              case "SEM_PARCELA":
              default:
                statusIcon = Icons.verified_user_rounded;
                statusColor = Colors.blue.shade400;
                break;
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalhesContasReceber(cliente: cliente),
                  ),
                ).then((_) {
                  provider.carregarClientes();
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.person,
                              color: Colors.blue, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      cliente.nome ?? "Sem nome",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(statusIcon,
                                          color: statusColor, size: 22),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "SCORE:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.circle,
                                      color: scoreColor, size: 12),
                                  Icon(
                                    Icons.circle,
                                    color: (cliente.scoreDescricao == "otimo" ||
                                            cliente.scoreDescricao == "bom")
                                        ? scoreColor
                                        : Colors.grey[300],
                                    size: 12,
                                  ),
                                  Icon(
                                    Icons.circle,
                                    color: cliente.scoreDescricao == "otimo"
                                        ? scoreColor
                                        : Colors.grey[300],
                                    size: 12,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
