import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/investment.dart';
import '../models/transaction.dart';
import '../utils/calculations.dart';

class InvestmentChart extends StatelessWidget {
  final Investment investment;

  const InvestmentChart({super.key, required this.investment});

  @override
  Widget build(BuildContext context) {
    if (investment.transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('No data to display'),
          ),
        ),
      );
    }

    final chartData = _prepareChartData();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Growth',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: chartData.yInterval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: chartData.xInterval,
                        getTitlesWidget: (value, meta) {
                          return _getBottomTitles(value, chartData);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: chartData.yInterval,
                        getTitlesWidget: (value, meta) {
                          return _getLeftTitles(value, meta);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  minX: chartData.minX,
                  maxX: chartData.maxX,
                  minY: chartData.minY,
                  maxY: chartData.maxY,
                  lineBarsData: [
                    // Invested amount line
                    LineChartBarData(
                      spots: chartData.investedSpots,
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Colors.blue,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Current value line
                    LineChartBarData(
                      spots: chartData.valueSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.green,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.9),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            touchedSpot.x.toInt(),
                          );
                          final dateStr = DateFormat('MMM d, yyyy').format(date);
                          final value = touchedSpot.y;
                          final label = touchedSpot.barIndex == 0
                              ? 'Invested'
                              : 'Value';

                          return LineTooltipItem(
                            '$label\n$dateStr\n${FinancialCalculations.formatCurrency(value)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Net Invested'),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.green, 'Current Value'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _getBottomTitles(double value, ChartData chartData) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final format = DateFormat('MMM\nyyyy');
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        format.format(date),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    String text;
    if (value >= 1000000) {
      text = '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      text = '\$${(value / 1000).toStringAsFixed(0)}K';
    } else {
      text = '\$${value.toStringAsFixed(0)}';
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
      textAlign: TextAlign.right,
    );
  }

  ChartData _prepareChartData() {
    List<FlSpot> investedSpots = [];
    List<FlSpot> valueSpots = [];

    // Sort transactions by date
    List<Transaction> sortedTx = List.from(investment.transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double runningInvested = 0;
    double runningQuantity = 0;

    for (var tx in sortedTx) {
      final timestamp = tx.date.millisecondsSinceEpoch.toDouble();

      if (tx.type == 'buy') {
        runningInvested += tx.amount;
        if (tx.quantity != null) {
          runningQuantity += tx.quantity!;
        }
      } else {
        runningInvested -= tx.amount;
        if (tx.quantity != null) {
          runningQuantity -= tx.quantity!;
        }
      }

      investedSpots.add(FlSpot(timestamp, runningInvested));

      // Calculate value at this point
      double valueAtPoint;
      if (tx.quantity != null && runningQuantity > 0) {
        valueAtPoint = runningQuantity * (tx.amount / tx.quantity!);
      } else {
        valueAtPoint = runningInvested;
      }
      valueSpots.add(FlSpot(timestamp, valueAtPoint));
    }

    // Add current value point (today)
    final now = DateTime.now();
    final currentTimestamp = now.millisecondsSinceEpoch.toDouble();
    investedSpots.add(FlSpot(currentTimestamp, investment.netInvested));
    valueSpots.add(FlSpot(currentTimestamp, investment.effectiveCurrentValue));

    // Calculate chart bounds
    final allSpots = [...investedSpots, ...valueSpots];
    final minX = allSpots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
    final maxX = allSpots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    final minY = allSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = allSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    // Add padding to Y axis
    final yPadding = (maxY - minY) * 0.1;
    final adjustedMinY = ((minY - yPadding).clamp(0.0, double.infinity)).toDouble();
    final adjustedMaxY = (maxY + yPadding).toDouble();

    // Calculate intervals
    final xRange = maxX - minX;
    final xInterval = xRange / 4; // Show ~4 date labels

    final yRange = adjustedMaxY - adjustedMinY;
    final yInterval = _calculateNiceInterval(yRange / 5); // ~5 horizontal lines

    return ChartData(
      investedSpots: investedSpots,
      valueSpots: valueSpots,
      minX: minX,
      maxX: maxX,
      minY: adjustedMinY.toDouble(),
      maxY: adjustedMaxY.toDouble(),
      xInterval: xInterval,
      yInterval: yInterval,
    );
  }

  double _calculateNiceInterval(double roughInterval) {
    if (roughInterval <= 0 || roughInterval.isInfinite || roughInterval.isNaN) {
      return 1.0; // Default fallback
    }
    
    final magnitude = pow(10, (log(roughInterval) / ln10).floor()).toDouble();
    final normalized = roughInterval / magnitude;

    double nice;
    if (normalized <= 1) {
      nice = 1;
    } else if (normalized <= 2) {
      nice = 2;
    } else if (normalized <= 5) {
      nice = 5;
    } else {
      nice = 10;
    }

    return nice * magnitude;
  }
}

class ChartData {
  final List<FlSpot> investedSpots;
  final List<FlSpot> valueSpots;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double xInterval;
  final double yInterval;

  ChartData({
    required this.investedSpots,
    required this.valueSpots,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.xInterval,
    required this.yInterval,
  });
}
