import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoPrevisaoRecebimentos extends StatelessWidget {
  const GraficoPrevisaoRecebimentos({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10000,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Hoje');
                    case 1:
                      return const Text('+7d');
                    case 2:
                      return const Text('+15d');
                    case 3:
                      return const Text('+30d');
                    case 4:
                      return const Text('Custom');
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: 500, color: Colors.green, width: 20)
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: 3200, color: Colors.orange, width: 20)
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: 6750, color: Colors.deepPurple, width: 20)
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(toY: 9000, color: Colors.indigo, width: 20)
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(toY: 4200, color: Colors.blueGrey, width: 20)
            ]),
          ],
        ),
      ),
    );
  }
}
