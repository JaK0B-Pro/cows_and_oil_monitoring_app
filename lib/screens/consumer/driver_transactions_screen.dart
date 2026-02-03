import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/driver_model.dart';
import '../../models/transaction_model.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class DriverTransactionsScreen extends StatelessWidget {
  final DriverModel driver;
  final DataService dataService;

  const DriverTransactionsScreen({
    super.key,
    required this.driver,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    // Get all transactions for this driver
    final driverTransactions = dataService.transactions
        .where((t) => t.receiverId == driver.userId && t.status == 'approved')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Calculate totals
    final totalLiters = driverTransactions.fold<double>(
      0.0,
      (sum, t) => sum + t.amountLiters,
    );
    final totalDZD = driverTransactions.fold<double>(
      0.0,
      (sum, t) => sum + t.amountDZD,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${driver.name} Transactions'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Driver Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        driver.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (driver.vehicleNumber != null)
                            Text(
                              driver.vehicleNumber!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          if (driver.truckModel != null)
                            Text(
                              driver.truckModel!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Total Transactions',
                        driverTransactions.length.toString(),
                        Icons.receipt_long,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white30,
                      ),
                      _buildStatItem(
                        'Total Liters',
                        '${totalLiters.toStringAsFixed(1)}L',
                        Icons.local_gas_station,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white30,
                      ),
                      _buildStatItem(
                        'Total Cost',
                        '${totalDZD.toStringAsFixed(0)} DZD',
                        Icons.attach_money,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: driverTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: driverTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = driverTransactions[index];
                      return _buildTransactionCard(context, transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_gas_station,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From: ${transaction.supplierCompanyName ?? 'Unknown Supplier'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTransactionDetail(
                context,
                'Liters',
                '${transaction.amountLiters.toStringAsFixed(2)} L',
                Icons.water_drop,
                Colors.blue,
              ),
              _buildTransactionDetail(
                context,
                'Price/L',
                '${transaction.pricePerLiter.toStringAsFixed(2)} DZD',
                Icons.attach_money,
                Colors.green,
              ),
              _buildTransactionDetail(
                context,
                'Total',
                '${transaction.amountDZD.toStringAsFixed(2)} DZD',
                Icons.payments,
                Colors.orange,
              ),
            ],
          ),
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionDetail(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
