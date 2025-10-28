import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/investment_provider.dart';
import '../models/investment.dart';
import '../utils/calculations.dart';
import 'add_investment_screen.dart';
import 'investment_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<InvestmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.investments.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildInvestmentList(context, provider.investments);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddInvestmentScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Investment'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No investments yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first investment',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentList(BuildContext context, List<Investment> investments) {
    // Calculate totals
    double totalInvested = 0;
    double totalCurrent = 0;

    for (var investment in investments) {
      totalInvested += investment.netInvested;
      totalCurrent += investment.effectiveCurrentValue;
    }

    double totalReturn = FinancialCalculations.calculateAbsoluteReturn(
      invested: totalInvested,
      currentValue: totalCurrent,
    );

    return Column(
      children: [
        // Summary Card
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      context,
                      'Total Invested',
                      FinancialCalculations.formatCurrency(totalInvested),
                      Colors.blue,
                    ),
                    _buildSummaryItem(
                      context,
                      'Current Value',
                      FinancialCalculations.formatCurrency(totalCurrent),
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  context,
                  'Total Return',
                  FinancialCalculations.formatPercentage(totalReturn),
                  totalReturn >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),
        // Investments List
        Expanded(
          child: ListView.builder(
            itemCount: investments.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return _buildInvestmentCard(context, investments[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentCard(BuildContext context, Investment investment) {
    double absoluteReturn = FinancialCalculations.calculateAbsoluteReturn(
      invested: investment.netInvested,
      currentValue: investment.effectiveCurrentValue,
    );

    double? xirr = FinancialCalculations.calculateXIRR(
      investment.transactions,
      currentValue: investment.effectiveCurrentValue,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvestmentDetailScreen(
                investmentId: investment.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      investment.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    absoluteReturn >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: absoluteReturn >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              if (investment.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  investment.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invested',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        FinancialCalculations.formatCurrency(
                            investment.netInvested),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        FinancialCalculations.formatCurrency(
                            investment.effectiveCurrentValue),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XIRR',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        FinancialCalculations.formatPercentage(xirr),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (xirr ?? 0) >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
