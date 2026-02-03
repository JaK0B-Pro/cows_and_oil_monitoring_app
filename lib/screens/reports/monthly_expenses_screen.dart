import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../models/transaction_model.dart';

class MonthlyExpensesScreen extends StatefulWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  State<MonthlyExpensesScreen> createState() => _MonthlyExpensesScreenState();
}

class _MonthlyExpensesScreenState extends State<MonthlyExpensesScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
    'All Time'
  ];

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final currentUser = dataService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expenses'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade700],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      dropdownColor: Colors.purple.shade700,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: _periods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSummaryCards(dataService),
          ),

          // Monthly breakdown
          Expanded(
            child: _buildMonthlyBreakdown(dataService),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DataService dataService) {
    final transactions = _getFilteredTransactions(dataService);
    
    double totalDZD = 0;
    double totalLiters = 0;
    int transactionCount = transactions.length;

    for (var transaction in transactions) {
      if (transaction.status == 'approved') {
        totalDZD += transaction.amountDZD;
        totalLiters += transaction.amountLiters;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Spent',
            '${totalDZD.toStringAsFixed(2)} DZD',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Fuel',
            '${totalLiters.toStringAsFixed(2)} L',
            Icons.local_gas_station,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Transactions',
            transactionCount.toString(),
            Icons.receipt_long,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, MaterialColor color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color[300]!, color[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown(DataService dataService) {
    final transactions = _getFilteredTransactions(dataService);
    
    // Group by month
    Map<String, List<TransactionModel>> monthlyTransactions = {};
    
    for (var transaction in transactions) {
      if (transaction.status == 'approved') {
        final monthKey = DateFormat('MMMM yyyy').format(transaction.createdAt);
        monthlyTransactions.putIfAbsent(monthKey, () => []);
        monthlyTransactions[monthKey]!.add(transaction);
      }
    }

    // Sort by date descending
    final sortedMonths = monthlyTransactions.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    if (sortedMonths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No transactions in this period',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final monthTransactions = monthlyTransactions[month]!;
        
        double monthDZD = 0;
        double monthLiters = 0;
        
        for (var t in monthTransactions) {
          monthDZD += t.amountDZD;
          monthLiters += t.amountLiters;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Icon(Icons.calendar_month, color: Colors.purple.shade700),
              ),
              title: Text(
                month,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${monthTransactions.length} transactions',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${monthDZD.toStringAsFixed(2)} DZD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${monthLiters.toStringAsFixed(2)} L',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              children: monthTransactions.map((transaction) {
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.local_gas_station,
                    color: Colors.blue.shade300,
                    size: 20,
                  ),
                  title: Text(
                    transaction.initiatorName == dataService.currentUser?.name
                        ? 'To: ${transaction.receiverName}'
                        : 'From: ${transaction.initiatorName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, HH:mm').format(transaction.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction.amountDZD.toStringAsFixed(2)} DZD',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${transaction.amountLiters.toStringAsFixed(2)} L',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  List<TransactionModel> _getFilteredTransactions(DataService dataService) {
    final allTransactions = dataService.transactions;
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        final endDate = DateTime(now.year, now.month, 1);
        return allTransactions
            .where((t) => t.createdAt.isAfter(startDate) && t.createdAt.isBefore(endDate))
            .toList();
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'Last 6 Months':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'All Time':
      default:
        return allTransactions;
    }

    return allTransactions
        .where((t) => t.createdAt.isAfter(startDate))
        .toList();
  }
}
