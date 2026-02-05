import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/providers/empresa_provider.dart';
import 'package:emprestimos_app/screens/cobranca/resumo_cobranca.dart';
import 'package:emprestimos_app/screens/cobranca/cobrancas_hoje_screen.dart';
import 'package:emprestimos_app/screens/localizar_parcela/localizar_parcela.dart';
import 'package:emprestimos_app/screens/relatorio/relatorio_recebimentos_screen.dart';
import 'package:emprestimos_app/screens/vendedores/vendedor_list_screen.dart';
import 'package:emprestimos_app/screens/config/config_screen.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/screens/home/home_empresa_screen.dart';
import 'package:emprestimos_app/screens/home/home_vendedor_screen.dart';
import 'package:emprestimos_app/screens/transferencia/transferencias_menu_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../clientes/cliente_list_screen.dart';

class MainScreen extends StatefulWidget {
  final String role; // "EMPRESA" ou "VENDEDOR"
  final Plano? plano;

  const MainScreen({required this.role, this.plano, Key? key})
      : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  bool get isWeb => kIsWeb || MediaQuery.of(context).size.width > 800;
  bool get isVendedor => widget.role == "VENDEDOR";

  bool _isPlanoPremium(Plano? plano) {
    final nome = plano?.nome?.toUpperCase() ?? '';
    return nome.contains("PREMIUM");
  }

  List<Map<String, dynamic>> _buildMainMenus(
      {required bool isVendedor, required Plano? plano}) {
    final isPlanoPremium = _isPlanoPremium(plano);
    return [
      {
        "icon": Icons.home,
        "label": "Home",
        "widget":
            isVendedor ? const HomeVendedorScreen() : const HomeEmpresaScreen()
      },
      {
        "icon": Icons.people,
        "label": "Clientes",
        "widget": const ClienteListScreen()
      },
      if (!isVendedor && isPlanoPremium)
        {
          "icon": Icons.supervisor_account,
          "label": "Vendedores",
          "widget": const VendedorListScreen()
        },
      {
        "icon": Icons.settings,
        "label": "Config.",
        "widget": const ConfigScreen()
      },
    ];
  }

  List<Map<String, dynamic>> _buildSidebarOnlyMenus(
      {required bool isVendedor}) {
    final menus = <Map<String, dynamic>>[
      {
        "icon": Icons.event,
        "label": "Cobranças de Hoje",
        "widget": const CobrancasHojeScreen()
      },
      {
        "icon": Icons.search,
        "label": "Localizar Cobrança",
        "widget": const ContasReceberSearchScreen()
      },
      {
        "icon": Icons.summarize,
        "label": "Resumo Cobranças",
        "widget": const ResumoCobrancasScreen()
      },
      {
        "icon": Icons.receipt_long,
        "label": "Relatório de Recebimentos",
        "widget": const RelatorioRecebimentosScreen()
      },
      if (!isVendedor)
        {
          "icon": Icons.swap_horiz,
          "label": "Transferências",
          "widget": const TransferenciasMenuScreen()
        },
    ];

    return menus;
  }

  @override
  Widget build(BuildContext context) {
    final empresaProvider = Provider.of<EmpresaProvider>(context);
    final plano =
        isVendedor ? null : (empresaProvider.empresa?.plano ?? widget.plano);
    final mainMenus = _buildMainMenus(isVendedor: isVendedor, plano: plano);
    final sidebarMenus = _buildSidebarOnlyMenus(isVendedor: isVendedor);
    final atualIndex = _selectedIndex >= mainMenus.length ? 0 : _selectedIndex;

    return _buildMobileScaffold(mainMenus, atualIndex, sidebarMenus);
  }

  /// Sidebar para Web

  /// Scaffold para Mobile com Drawer lateral
  Widget _buildMobileScaffold(List<Map<String, dynamic>> mainMenus, int index,
      List<Map<String, dynamic>> sidebarMenus) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(mainMenus[index]['label']),
      // ),
      drawer: Drawer(
        child: _buildSidebar(sidebarMenus, mainMenus, isDrawer: true),
      ),
      body: mainMenus[index]["widget"] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        items: mainMenus
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item["icon"]),
                  label: item["label"],
                ))
            .toList(),
        currentIndex: index,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 10,
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  /// Sidebar (Drawer no Mobile ou lateral no Web)
  Widget _buildSidebar(
      List<Map<String, dynamic>> menu, List<Map<String, dynamic>> mainMenus,
      {bool isDrawer = false}) {
    final double expandedWidth = 220;
    final double collapsedWidth = 70;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isDrawer
          ? null
          : (_isSidebarCollapsed ? collapsedWidth : expandedWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
        ],
        border: const Border(right: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        children: [
          if (!isDrawer) const SizedBox(height: 16),
          if (!isDrawer)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  _isSidebarCollapsed ? Icons.menu : Icons.arrow_back_ios,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                },
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: menu.length,
              itemBuilder: (context, i) {
                final item = menu[i];
                final isSelected =
                    mainMenus.indexWhere((m) => m['label'] == item['label']) ==
                        _selectedIndex;

                return ListTile(
                  leading: Icon(
                    item["icon"],
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade600,
                  ),
                  title: isDrawer || !_isSidebarCollapsed
                      ? Text(
                          item["label"],
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        )
                      : null,
                  selected: isSelected,
                  onTap: () {
                    Navigator.pop(context); // fecha o Drawer se for mobile

                    final indexInMainMenu = mainMenus.indexWhere(
                        (menuItem) => menuItem['label'] == item['label']);

                    if (indexInMainMenu != -1) {
                      setState(() => _selectedIndex = indexInMainMenu);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => item['widget'] as Widget),
                      );
                    }
                  },
                  selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isDrawer || !_isSidebarCollapsed ? 20 : 16,
                    vertical: 8,
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
