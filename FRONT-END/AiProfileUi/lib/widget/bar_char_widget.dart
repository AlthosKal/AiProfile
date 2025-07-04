import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../dto/chat/rest/char_data_dto.dart';

class BarChartWidget extends StatelessWidget {
  final List<CharDataDTO> data;

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          barGroups:
              data.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value.value,
                      width: 16,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  showingTooltipIndicators: [0],
                );
              }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Text(
                      data[index].label,
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
