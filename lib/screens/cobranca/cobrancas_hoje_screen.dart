import 'package:emprestimos_app/core/data_utils.dart';
import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/detalhamento_parcela.dart';
import 'package:emprestimos_app/providers/auth_provider.dart';
import 'package:emprestimos_app/providers/caixa_provider.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/services/cobranca_hoje_service.dart';
import 'package:emprestimos_app/widgets/background_screens_widget.dart';
import 'package:emprestimos_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CobrancasHojeScreen extends StatefulWidget {
  const CobrancasHojeScreen({super.key});

  @override
  State<CobrancasHojeScreen> createState() => _CobrancasHojeScreenState();
}

class _CobrancasHojeScreenState extends State<CobrancasHojeScreen> {
  DateTime vencimento = DateTime.now();
  int? caixaIdSelecionado;
  int? vendedorIdSelecionado;

  bool isLoading = false;
  String? errorMessage;
  List<DetalheParcelaDTO> resultados = [];

  bool get _isVendedor {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.loginResponse?.role == 'VENDEDOR';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final caixaProvider = Provider.of<CaixaProvider>(context, listen: false);
      final vendedorProvider =
          Provider.of<VendedorProvider>(context, listen: false);
      await caixaProvider.listarCaixas();
      await vendedorProvider.listarVendedores();

      if (_isVendedor) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        vendedorIdSelecionado = auth.loginResponse?.usuario.id;
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> _buscar() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await CobrancaHojeService.buscar(
        vencimento: vencimento,
        vendedorId: vendedorIdSelecionado,
        caixaId: caixaIdSelecionado,
      );
      setState(() => resultados = data);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _limpar() {
    setState(() {
      vencimento = DateTime.now();
      caixaIdSelecionado = null;
      if (!_isVendedor) vendedorIdSelecionado = null;
      resultados = [];
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendedores = Provider.of<VendedorProvider>(context).vendedores;
    final caixas = Provider.of<CaixaProvider>(context).caixas;
    final vendedorValue = vendedores.any((v) => v.id == vendedorIdSelecionado)
        ? vendedorIdSelecionado
        : null;
    final caixaValue =
        caixas.any((c) => c.id == caixaIdSelecionado) ? caixaIdSelecionado : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobranças de Hoje'),
        centerTitle: true,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateField(),
              const SizedBox(height: 12),
              if (caixas.isNotEmpty)
                DropdownButtonFormField<int>(
                  value: caixaValue,
                  items: caixas
                      .map((caixa) => DropdownMenuItem<int>(
                            value: caixa.id,
                            child: Text(caixa.descricao),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => caixaIdSelecionado = val),
                  decoration: const InputDecoration(
                    labelText: 'Caixa',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              if (vendedores.isNotEmpty)
                DropdownButtonFormField<int>(
                  value: vendedorValue,
                  items: vendedores
                      .map((v) => DropdownMenuItem<int>(
                            value: v.id,
                            child: Text(v.nome),
                          ))
                      .toList(),
                  onChanged: _isVendedor
                      ? null
                      : (val) => setState(() => vendedorIdSelecionado = val),
                  decoration: const InputDecoration(
                    labelText: 'Vendedor',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Filtrar',
                      onPressed: isLoading ? null : _buscar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey[200],
                        side: BorderSide.none,
                      ),
                      onPressed: _limpar,
                      child: const Icon(Icons.cleaning_services_outlined,
                          color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildResultado(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final texto = DateFormat('dd/MM/yyyy').format(vencimento);
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Vencimento',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.date_range),
      ),
      controller: TextEditingController(text: texto),
      onTap: () async {
        final picked = await showDatePicker(
          locale: const Locale('pt', 'BR'),
          context: context,
          initialDate: vencimento,
          firstDate: DateTime(2022),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => vencimento = picked);
        }
      },
    );
  }

  Widget _buildResultado() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (resultados.isEmpty) {
      return Center(
        child: Lottie.asset(
          'assets/img/no-results.json',
          height: 180,
          repeat: true,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resultados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = resultados[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.clienteNome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Contrato: ${item.contratoNumero ?? '--'}'),
                Text(
                  'Vencimento: ${FormatData.formatarDataCompletaPadrao(item.vencimento)}',
                ),
                Text('Parcela: ${item.numeroParcela}'),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${item.status}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      Util.formatarMoeda(item.valorParcela),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
