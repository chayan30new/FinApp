import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/stock_price_service.dart';
import '../utils/calculations.dart';
import 'dart:math' as math;

class HistoricalPriceChart extends StatefulWidget {
  final HistoricalPriceData data;

  const HistoricalPriceChart({
    super.key,
    required this.data,
  });

  @override
  State<HistoricalPriceChart> createState() => _HistoricalPriceChartState();
}

class _HistoricalPriceChartState extends State<HistoricalPriceChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.prices.isEmpty) {
      return const Center(
        child: Text('No historical data available'),
      );
    }

    final prices = widget.data.prices;
    final minPrice = widget.data.minPrice ?? 0;
    final maxPrice = widget.data.maxPrice ?? 1;
    final priceRange = maxPrice - minPrice;
    
    // Add padding to y-axis
    final yMin = minPrice - (priceRange * 0.1);
    final yMax = maxPrice + (priceRange * 0.1);

    // Determine if overall trend is positive
    final isPositive = prices.last.close >= prices.first.close;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart legend/info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPeriodLabel(widget.data.period),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.data.priceChangePercent != null)
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isPositive ? Colors.green[700] : Colors.red[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${widget.data.priceChangePercent!.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Range',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${FinancialCalculations.formatCurrency(minPrice)} - ${FinancialCalculations.formatCurrency(maxPrice)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Chart
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 8, bottom: 16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateNiceInterval(yMin, yMax, 5),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
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
                      interval: _calculateDateInterval(prices.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= prices.length) {
                          return const Text('');
                        }
                        
                        // Show labels only at intervals
                        if (index == 0 || index == prices.length - 1 || 
                            index % _calculateDateInterval(prices.length).toInt() == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM yy').format(prices[index].date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: _calculateNiceInterval(yMin, yMax, 5),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                minX: 0,
                maxX: (prices.length - 1).toDouble(),
                minY: yMin,
                maxY: yMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: prices.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.close);
                    }).toList(),
                    isCurved: true,
                    color: isPositive ? Colors.green[600] : Colors.red[600],
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (isPositive ? Colors.green[600] : Colors.red[600])!
                          .withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= prices.length) {
                          return null;
                        }
                        final price = prices[index];
                        return LineTooltipItem(
                          '${DateFormat('MMM d, yyyy').format(price.date)}\n',
                          const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                          children: [
                            TextSpan(
                              text: FinancialCalculations.formatCurrency(price.close),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case '1mo':
        return 'Last Month';
      case '3mo':
        return 'Last 3 Months';
      case '6mo':
        return 'Last 6 Months';
      case '1y':
        return 'Last Year';
      case '2y':
        return 'Last 2 Years';
      case '5y':
        return 'Last 5 Years';
      case 'max':
        return 'All Time';
      default:
        return period;
    }
  }

  double _calculateDateInterval(int pointCount) {
    if (pointCount <= 30) return 7; // Show every week for month
    if (pointCount <= 90) return 30; // Show monthly for 3 months
    if (pointCount <= 180) return 60; // Show every 2 months for 6 months
    if (pointCount <= 365) return 90; // Show quarterly for 1 year
    return 180; // Show semi-annually for longer periods
  }

  double _calculateNiceInterval(double min, double max, int targetCount) {
    final range = max - min;
    if (range <= 0 || range.isInfinite || range.isNaN) return 1.0;

    final roughInterval = range / targetCount;
    
    // Find the magnitude (power of 10)
    final magnitude = math.pow(10, (math.log(roughInterval) / math.ln10).floor()).toDouble();
    
    // Normalize to [1, 10)
    final normalized = roughInterval / magnitude;
    
    // Pick a nice number
    double niceNormalized;
    if (normalized < 1.5) {
      niceNormalized = 1;
    } else if (normalized < 3) {
      niceNormalized = 2;
    } else if (normalized < 7) {
      niceNormalized = 5;
    } else {
      niceNormalized = 10;
    }
    
    final result = niceNormalized * magnitude;
    return result.isFinite ? result : 1.0;
  }
}
