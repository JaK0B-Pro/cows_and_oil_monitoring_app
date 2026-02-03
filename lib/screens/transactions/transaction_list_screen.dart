import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final currentUser = dataService.currentUser!;
    final transactions = dataService.getTransactionsByUserId(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _TransactionCard(transaction: transactions[index]);
              },
            ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.approved:
        return AppTheme.accentColor;
      case TransactionStatus.pending:
        return AppTheme.warningColor;
      case TransactionStatus.rejected:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText() {
    switch (transaction.status) {
      case TransactionStatus.approved:
        return 'Approved';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    final dataService = Provider.of<DataService>(context, listen: false);
    final currentUser = dataService.currentUser!;
    final isInitiator = transaction.initiatorId == currentUser.id;
    final otherPartyName = isInitiator ? transaction.receiverName : transaction.initiatorName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_gas_station,
                    color: _getStatusColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherPartyName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (transaction.supplierCompanyName != null)
                        Text(
                          transaction.supplierCompanyName!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${transaction.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${transaction.amountLiters.toStringAsFixed(1)}L',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 16,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormat.format(transaction.completedAt ?? transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          if (transaction.status == TransactionStatus.approved)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _printReceipt(context),
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (transaction.status) {
      case TransactionStatus.approved:
        return Icons.check_circle;
      case TransactionStatus.pending:
        return Icons.pending;
      case TransactionStatus.rejected:
        return Icons.cancel;
    }
  }

  Future<void> _printReceipt(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'FUEL RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              pw.Text('Transaction ID: ${transaction.id}'),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateFormat('MMMM dd, yyyy - HH:mm').format(transaction.completedAt ?? transaction.createdAt)}'),
              pw.SizedBox(height: 20),
              
              if (transaction.supplierCompanyName != null) ...[
                pw.Text(
                  'Supplier:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(transaction.supplierCompanyName!),
                pw.SizedBox(height: 10),
              ],
              
              if (transaction.consumerCompanyName != null) ...[
                pw.Text(
                  'Consumer:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(transaction.consumerCompanyName!),
                pw.SizedBox(height: 10),
              ],
              
              pw.Text(
                'Driver: ${transaction.initiatorName}',
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Amount (Liters):'),
                  pw.Text(
                    '${transaction.amountLiters.toStringAsFixed(2)} L',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Price per Liter:'),
                  pw.Text(
                    '\$${transaction.pricePerLiter.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${transaction.totalPrice.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
