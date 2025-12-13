import 'package:emprestimos_app/models/planos.dart';
import 'package:emprestimos_app/screens/cobranca/resumo_cobranca.dart';
import 'package:emprestimos_app/screens/localizar_parcela/localizar_parcela.dart';
import 'package:emprestimos_app/screens/vendedores/vendedor_list_screen.dart';
import 'package:emprestimos_app/screens/config/config_screen.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/screens/home/home_empresa_screen.dart';
import 'package:emprestimos_app/screens/home/home_vendedor_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  bool get isPlanoPremium =>
      widget.plano?.nome.toUpperCase().contains("PREMIUM") ?? false;

  List<Map<String, dynamic>> get _mainMenus => [
        {
          "icon": Icons.home,
          "label": "Home",
          "widget": isVendedor
              ? const HomeVendedorScreen()
              : const HomeEmpresaScreen()
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

  List<Map<String, dynamic>> get _sidebarOnlyMenus => [
        {
          "icon": Icons.summarize,
          "label": "Relatório de Parcelas",
          "widget": const ResumoCobrancasScreen()
        },
        {
          "icon": Icons.search,
          "label": "Localizar Parcelas",
          "widget": const ContasReceberSearchScreen()
        },
      ];

  List<Map<String, dynamic>> get _allMenus =>
      [..._mainMenus, ..._sidebarOnlyMenus];

  @override
  Widget build(BuildContext context) {
    final mainMenus = _mainMenus;
    final allMenus = _allMenus;
    final atualIndex = _selectedIndex >= mainMenus.length ? 0 : _selectedIndex;

    return isWeb
        ? _buildWebScaffold(allMenus, atualIndex)
        : _buildMobileScaffold(mainMenus, atualIndex, allMenus);
  }

  /// Sidebar para Web
  Widget _buildWebScaffold(List<Map<String, dynamic>> menu, int index) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(menu),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: menu[index]["widget"] as Widget,
            ),
          ),
        ],
      ),
    );
  }

  /// Scaffold para Mobile com Drawer lateral
  Widget _buildMobileScaffold(List<Map<String, dynamic>> mainMenus, int index,
      List<Map<String, dynamic>> allMenus) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(mainMenus[index]['label']),
      // ),
      drawer: Drawer(
        child: _buildSidebar(allMenus, isDrawer: true),
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
  Widget _buildSidebar(List<Map<String, dynamic>> menu,
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
                    _mainMenus.indexWhere((m) => m['label'] == item['label']) ==
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

                    final indexInMainMenu = _mainMenus.indexWhere(
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
