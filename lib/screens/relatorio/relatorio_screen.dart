import 'package:flutter/material.dart';
import '../../services/relatorio_service.dart';
import '../../models/relatorio.dart';
import 'package:fl_chart/fl_chart.dart';

class RelatorioScreen extends StatefulWidget {
  @override
  _RelatorioScreenState createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  late Future<Relatorio> relatorio;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    relatorio = RelatorioService.buscarRelatorio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Relatório Financeiro")),
      body: FutureBuilder<Relatorio>(
        future: relatorio,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(child: Text("Erro ao carregar relatório"));
          }

          final dados = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total de Contratos: ${dados.totalContasReceber}",
                    style: TextStyle(fontSize: 18)),
                Text(
                    "Total Juros Recebidos: R\$ ${dados.jurosRecebidos.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, color: Colors.green)),
                Text("Total Atrasados: ${dados.totalAtrasados}",
                    style: TextStyle(fontSize: 18, color: Colors.red)),
                SizedBox(height: 20),
                Text("Projeção de Recebimentos:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // _buildGraficoRecebimentos(dados),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildGraficoRecebimentos(Relatorio relatorio) {
  //   return SizedBox(
  //     height: 250,
  //     child: BarChart(
  //       BarChartData(
  //         titlesData: const FlTitlesData(leftTitles: SideTitles(showTitles: true)),
  //         borderData: FlBorderData(show: false),
  //         barGroups: relatorio.projecaoMensal.map((mes, valor) {
  //           return MapEntry(
  //             mes,
  //             BarChartGroupData(
  //               x: int.parse(mes),
  //               barRods: [BarChartRodData(toY: valor.toDouble(), color: Colors.blue)],
  //             ),
  //           );
  //         }).values.toList(),
  //       ),
  //     ),
  //   );
  // }
}
