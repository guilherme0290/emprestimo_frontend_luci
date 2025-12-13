import 'package:dropdown_search/dropdown_search.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class UfDropdown extends StatelessWidget {
  final String? selectedUf;
  final Function(String) onUfSelecionada;

  UfDropdown({
    Key? key,
    required this.selectedUf,
    required this.onUfSelecionada,
  }) : super(key: key);

  final List<String> ufs = const [
    'AC',
    'AL',
    'AM',
    'AP',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SE',
    'SP',
    'TO'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: (filter, s) => ufs,
      selectedItem: selectedUf,
      validator: (uf) => uf == null ? "Informe uma UF" : null,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Selecionar UF",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      popupProps: PopupProps.menu(
        fit: FlexFit.tight,
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: "Buscar UF...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
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
      ),
      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null) {
          return const Text(
            '',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          );
        }
        return Text(
          selectedItem.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        );
      },
      onChanged: (uf) {
        if (uf != null) {
          onUfSelecionada(uf);
        }
      },
    );
  }
}
