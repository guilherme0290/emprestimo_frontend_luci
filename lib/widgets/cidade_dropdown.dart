import 'package:dropdown_search/dropdown_search.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/models/cidade.dart';
import 'package:emprestimos_app/providers/cidade_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CidadeDropdown extends StatefulWidget {
  final String? uf;
  final Cidade? selectedCidade;
  final Function(Cidade) onCidadeSelecionada;

  const CidadeDropdown({
    Key? key,
    required this.uf,
    required this.onCidadeSelecionada,
    this.selectedCidade,
  }) : super(key: key);

  @override
  State<CidadeDropdown> createState() => _CidadeDropdownState();
}

class _CidadeDropdownState extends State<CidadeDropdown> {
  Cidade? cidadeSelecionada;
  List<Cidade> cidades = [];

  @override
  void initState() {
    super.initState();
    if (widget.uf != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _carregarCidades();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CidadeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uf != widget.uf && widget.uf != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _carregarCidades();
      });
    }
  }

  void _carregarCidades() async {
    final provider = Provider.of<CidadeProvider>(context, listen: false);
    if (widget.uf != null) {
      setState(() {
        cidadeSelecionada = null; // limpa seleção anterior
      });

      await provider.buscarCidadesPorUf(widget.uf!).then((_) {
        setState(() {
          cidades = provider.cidades;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CidadeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownSearch<Cidade>(
          items: (filter, s) => cidades,
          compareFn: (a, b) => a.id == b.id,
          validator: (cidade) => null,
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
                labelText: "Pesquisar cidade...",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppTheme.primaryColor.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primaryColor),
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
            title: const Center(
              child: Text(
                "Buscar Cidade",
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
              labelText: "Selecionar Cidade",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          itemAsString: (Cidade c) => "${c.nome} - ${c.uf}",
          selectedItem: widget.selectedCidade,
          onChanged: (cidade) {
            if (cidade != null) {
              setState(() => cidadeSelecionada = cidade);
              widget.onCidadeSelecionada(cidade);
            }
          },
          dropdownBuilder: (context, selectedItem) {
            if (selectedItem == null) {
              return const Text(
                '',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              );
            }

            return Text(
              '${selectedItem.nome} - ${selectedItem.uf}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            );
          },
        );
      },
    );
  }
}
