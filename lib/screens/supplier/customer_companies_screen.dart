import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../models/transaction_model.dart';

class CustomerCompaniesScreen extends StatelessWidget {
  const CustomerCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final currentCompany = dataService.currentUser != null
        ? dataService.getCompanyByUserId(dataService.currentUser!.id)
        : null;

    if (currentCompany == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer Companies'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(child: Text('No company data available')),
      );
    }

    // Get all approved transactions for this supplier
    final allTransactions = dataService.transactions;
    final supplierTransactions = allTransactions.where((t) =>
        t.status == 'approved' &&
        t.supplierCompanyId == currentCompany.id).toList();

    // Group by consumer company
    Map<String, CustomerData> customerData = {};
    
    for (var transaction in supplierTransactions) {
      if (transaction.consumerCompanyId != null) {
        final companyId = transaction.consumerCompanyId!;
        if (!customerData.containsKey(companyId)) {
          customerData[companyId] = CustomerData(
            companyId: companyId,
            companyName: transaction.consumerCompanyName ?? 'Unknown Company',
            totalDZD: 0,
            totalLiters: 0,
            transactionCount: 0,
            lastTransaction: transaction.createdAt,
          );
        }
        
        customerData[companyId]!.totalDZD += transaction.amountDZD;
        customerData[companyId]!.totalLiters += transaction.amountLiters;
        customerData[companyId]!.transactionCount++;
        
        if (transaction.createdAt.isAfter(customerData[companyId]!.lastTransaction)) {
          customerData[companyId]!.lastTransaction = transaction.createdAt;
        }
      }
    }

    // Sort by total amount descending
    final sortedCustomers = customerData.values.toList()
      ..sort((a, b) => b.totalDZD.compareTo(a.totalDZD));

    // Calculate totals
    double totalRevenue = 0;
    double totalFuelSold = 0;
    for (var customer in sortedCustomers) {
      totalRevenue += customer.totalDZD;
      totalFuelSold += customer.totalLiters;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Companies'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Summary section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Total Customers',
                      sortedCustomers.length.toString(),
                      Icons.business,
                    ),
                    _buildSummaryItem(
                      'Total Revenue',
                      '${totalRevenue.toStringAsFixed(0)} DZD',
                      Icons.attach_money,
                    ),
                    _buildSummaryItem(
                      'Fuel Sold',
                      '${totalFuelSold.toStringAsFixed(0)} L',
                      Icons.local_gas_station,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Customer list
          Expanded(
            child: sortedCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No customer companies yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = sortedCustomers[index];
                      final percentage = (customer.totalDZD / totalRevenue * 100);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showCustomerDetails(context, customer, supplierTransactions);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        customer.companyName[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.companyName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${customer.transactionCount} transactions',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCustomerStat(
                                        'Revenue',
                                        '${customer.totalDZD.toStringAsFixed(2)} DZD',
                                        Icons.payments,
                                        Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildCustomerStat(
                                        'Fuel Sold',
                                        '${customer.totalLiters.toStringAsFixed(2)} L',
                                        Icons.local_gas_station,
                                        Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Last transaction: ${DateFormat('MMM dd, yyyy').format(customer.lastTransaction)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
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
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(
    BuildContext context,
    CustomerData customer,
    List<TransactionModel> allTransactions,
  ) {
    final customerTransactions = allTransactions
        .where((t) => t.consumerCompanyId == customer.companyId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    customer.companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${customer.transactionCount} total transactions',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: customerTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = customerTransactions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.local_gas_station,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(transaction.createdAt),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        '${transaction.amountLiters.toStringAsFixed(2)} L',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        '${transaction.amountDZD.toStringAsFixed(2)} DZD',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerData {
  final String companyId;
  final String companyName;
  double totalDZD;
  double totalLiters;
  int transactionCount;
  DateTime lastTransaction;

  CustomerData({
    required this.companyId,
    required this.companyName,
    required this.totalDZD,
    required this.totalLiters,
    required this.transactionCount,
    required this.lastTransaction,
  });
}
