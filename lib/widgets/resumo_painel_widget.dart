import 'package:emprestimos_app/screens/notificacoes/notificacao_screen.dart';
import 'package:flutter/material.dart';
import 'package:emprestimos_app/core/theme/theme.dart';
import 'package:emprestimos_app/core/util.dart';

import 'package:badges/badges.dart' as badges;

class ResumoPainelWidget extends StatelessWidget {
  final bool isEmpresa;
  final double capitalInvestido;
  final double totalReceber;
  final double inadimplentes;
  final double adimplentes;
  final bool esconderValores;
  final VoidCallback onToggleEsconderValores;
  final String nomeUsuario;
  final int notificacoesNaoVisualizadas;
  final VoidCallback onOpenDrawer;

  const ResumoPainelWidget(
      {super.key,
      required this.isEmpresa,
      required this.capitalInvestido,
      required this.totalReceber,
      required this.inadimplentes,
      required this.adimplentes,
      required this.esconderValores,
      required this.onToggleEsconderValores,
      required this.nomeUsuario,
      required this.notificacoesNaoVisualizadas,
      required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            top: true,
            bottom: false,
            left: false,
            right: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: onOpenDrawer,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Painel da Empresa",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Olá $nomeUsuario",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificacoesScreen()),
                      );
                    },
                    icon: badges.Badge(
                      badgeContent: Text(
                        notificacoesNaoVisualizadas.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      showBadge: notificacoesNaoVisualizadas > 0,
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResumoItem(
                  isEmpresa ? "Capital Investido" : "A Receber",
                  esconderValores
                      ? "*****"
                      : Util.formatarMoeda(
                          isEmpresa ? capitalInvestido : totalReceber),
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12), // 🔹 Espaçamento entre os cards
              Expanded(
                child: _buildResumoItem(
                  "A Receber",
                  esconderValores ? "*****" : Util.formatarMoeda(totalReceber),
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildIndicadorMini(
                Icons.warning_amber_rounded,
                "${inadimplentes.toStringAsFixed(1)}%",
                Colors.red,
              ),
              const SizedBox(width: 8),
              _buildIndicadorMini(
                Icons.check_circle,
                "${adimplentes.toStringAsFixed(1)}%",
                Colors.green,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  esconderValores ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: onToggleEsconderValores,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadorMini(IconData icon, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: cor, size: 16),
          const SizedBox(width: 4),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Card de Resumo Financeiro (Total Emprestado / A Receber)
  Widget _buildResumoItem(String titulo, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
