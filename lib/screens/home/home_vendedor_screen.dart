import 'package:emprestimos_app/core/util.dart';
import 'package:emprestimos_app/models/parcela_resumo.dart';
import 'package:emprestimos_app/providers/vendedor_provider.dart';
import 'package:emprestimos_app/providers/emprestimo_provider.dart';
import 'package:emprestimos_app/providers/parametros_provider.dart';
import 'package:emprestimos_app/screens/clientes/cliente_create_screen.dart';
import 'package:emprestimos_app/screens/clientes/cliente_list_screen.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_create_step1.dart';
import 'package:emprestimos_app/screens/emprestimos/emprestimo_detail_screen.dart';
import 'package:emprestimos_app/widgets/botoes_acoes_rapidas.dart';
import 'package:emprestimos_app/widgets/label_titulo.dart';
import 'package:emprestimos_app/widgets/parcelas_relevantes.dart';
import 'package:emprestimos_app/widgets/previsao_recebimento_horizontal.dart';
import 'package:emprestimos_app/widgets/resumo_trasacoes.dart';
import 'package:emprestimos_app/widgets/scroll_hint.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';

class HomeVendedorScreen extends StatefulWidget {
  const HomeVendedorScreen({super.key});

  @override
  State<HomeVendedorScreen> createState() => _HomeVendedorScreenState();
}

class _HomeVendedorScreenState extends State<HomeVendedorScreen> {
  String? nomeVendedor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider =
          Provider.of<ContasReceberProvider>(context, listen: false);
      nomeVendedor = Provider.of<VendedorProvider>(context, listen: false)
          .getNomeVendedor();
      final parametroProvider =
          Provider.of<ParametroProvider>(context, listen: false);

      await Future.wait([
        provider.buscarParcelasRelevantes(),
        provider.buscarResumoVendedor(null),
        provider.buscarPrevisaoRecebimentos(),
        parametroProvider.buscarParametrosEmpresa()
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContasReceberProvider>(
      builder: (context, emprestimoProvider, child) {
        if (emprestimoProvider.errorMessage != null) {
          return Center(child: Text(emprestimoProvider.errorMessage!));
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Painel do Vendedor",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Olá $nomeVendedor",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildResumoPainel(context, emprestimoProvider),
              const SizedBox(height: 10),
              Expanded(child: _buildPainelResumoCobranca(emprestimoProvider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumoPainel(
      BuildContext context, ContasReceberProvider provider) {
    final resumo = provider.resumoVendedor;
    final bool esconder = provider.esconderValores;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: resumo == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildResumoReceberItem(
                        "A Receber",
                        esconder
                            ? "*****"
                            : Util.formatarMoeda(resumo.totalReceber),
                        Icons.account_balance_wallet,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        esconder ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: provider.toggleEsconderValores,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: _buildIndicador(
                        "Em atraso",
                        "${resumo.inadimplentes.toStringAsFixed(1)}%",
                        Colors.red,
                        Icons.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildIndicador(
                        "Regular",
                        "${resumo.adimplentes.toStringAsFixed(1)}%",
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildPainelResumoCobranca(ContasReceberProvider emprestimoProvider) {
    return RefreshIndicator(
        onRefresh: () async {
          await emprestimoProvider.buscarParcelasRelevantes();
          await emprestimoProvider.buscarResumoVendedor(null);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BtnAcoesRapidas(),
              const SizedBox(height: 10),
              LabelTitulo(titulo: "Parcelas Relevantes"),
              emprestimoProvider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ParcelasResumoCard(
                      fetchData: emprestimoProvider.buscarParcelasRelevantes,
                      parcelas: emprestimoProvider.parcelas,
                      isLoading: false,
                    ),
              const SizedBox(height: 8),
              const ScrollHint(label: "Mais recursos abaixo"),
              const SizedBox(height: 20),
              // 🔹 Transações (agora aqui dentro, rolando junto)
              LabelTitulo(titulo: "📄 Transações"),
              const SizedBox(height: 12),
              const TransacoesResumoCard(),

              const SizedBox(height: 20),
              LabelTitulo(titulo: "Previsão de Recebimentos"),
              SizedBox(
                height: 180,
                child: emprestimoProvider.isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : PrevisaoRecebimentosHorizontal(
                        previsoes: emprestimoProvider.previsoes),
              )
            ],
          ),
        ));
  }

  Widget _buildResumoReceberItem(String titulo, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 **Indicadores de Adimplência/Inadimplência**
  Widget _buildIndicador(
      String titulo, String valor, Color cor, IconData icone) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                    color: cor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                valor,
                style: TextStyle(
                    color: cor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
