import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _showScanner = false;
  
  // Fixed price per liter in DZD (you can adjust this)
  final double _pricePerLiter = 65.0; // DZD per liter

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _calculatedLiters {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return null;
    return amount / _pricePerLiter;
  }

  void _proceedToScanner() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _showScanner = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return _QRScannerView(
        amountDZD: double.parse(_amountController.text),
        pricePerLiter: _pricePerLiter,
        onBack: () => setState(() => _showScanner = false),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.gradientBoxDecoration(),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.local_gas_station,
                        size: 64,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Enter Transaction Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount to Fuel',
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'DZD',
                    helperText: 'Enter the amount in Algerian Dinar',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                
                if (_calculatedLiters != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You will receive',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_calculatedLiters!.toStringAsFixed(2)} L',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Price per liter',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_pricePerLiter DZD/L',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _proceedToScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text(
                      'Proceed to Scan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'You will scan the QR code of the person you are transacting with',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QRScannerView extends StatefulWidget {
  final double amountDZD;
  final double pricePerLiter;
  final VoidCallback onBack;

  const _QRScannerView({
    required this.amountDZD,
    required this.pricePerLiter,
    required this.onBack,
  });

  @override
  State<_QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<_QRScannerView> {
  MobileScannerController? controller;
  bool _isProcessing = false;

  double get liters => widget.amountDZD / widget.pricePerLiter;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String? code) async {
    if (code == null || _isProcessing) return;
    
    setState(() => _isProcessing = true);

    try {
      final data = jsonDecode(code);
      final scannedUserId = data['userId'] as String;
      
      final dataService = Provider.of<DataService>(context, listen: false);
      final currentUser = dataService.currentUser!;
      final scannedUser = dataService.getUserById(scannedUserId);
      
      if (scannedUser == null) {
        throw Exception('User not found');
      }
      
      if (scannedUser.id == currentUser.id) {
        throw Exception('Cannot transact with yourself');
      }

      // Create transaction
      final currentCompany = dataService.getCompanyByUserId(currentUser.id);
      final scannedCompany = dataService.getCompanyByUserId(scannedUser.id);
      final currentDriver = dataService.getDriverByUserId(currentUser.id);
      final scannedDriver = dataService.getDriverByUserId(scannedUser.id);

      String? supplierCompanyId;
      String? supplierCompanyName;
      String? consumerCompanyId;
      String? consumerCompanyName;

      // Determine supplier and consumer
      if (currentUser.role == UserRole.supplierCompany) {
        supplierCompanyId = currentCompany?.id;
        supplierCompanyName = currentCompany?.name;
        if (scannedUser.role == UserRole.consumerCompany) {
          consumerCompanyId = scannedCompany?.id;
          consumerCompanyName = scannedCompany?.name;
        } else if (scannedUser.role == UserRole.driver) {
          consumerCompanyId = scannedDriver?.consumerCompanyId;
          consumerCompanyName = scannedDriver?.consumerCompanyName;
        }
      } else if (scannedUser.role == UserRole.supplierCompany) {
        supplierCompanyId = scannedCompany?.id;
        supplierCompanyName = scannedCompany?.name;
        if (currentUser.role == UserRole.consumerCompany) {
          consumerCompanyId = currentCompany?.id;
          consumerCompanyName = currentCompany?.name;
        } else if (currentUser.role == UserRole.driver) {
          consumerCompanyId = currentDriver?.consumerCompanyId;
          consumerCompanyName = currentDriver?.consumerCompanyName;
        }
      }

      final transaction = TransactionModel(
        id: dataService.generateId(),
        initiatorId: currentUser.id,
        initiatorName: currentUser.name,
        receiverId: scannedUser.id,
        receiverName: scannedUser.name,
        supplierCompanyId: supplierCompanyId,
        supplierCompanyName: supplierCompanyName,
        consumerCompanyId: consumerCompanyId,
        consumerCompanyName: consumerCompanyName,
        amountLiters: liters,
        pricePerLiter: widget.pricePerLiter,
        totalPrice: widget.amountDZD,
        amountDZD: widget.amountDZD,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
      );

      await dataService.createTransaction(transaction);

      if (!mounted) return;
      
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction request sent to ${scannedUser.name}'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (!_isProcessing && barcode.rawValue != null) {
                    _processQRCode(barcode.rawValue);
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black87,
              child: Center(
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Position QR code within frame',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.amountDZD.toStringAsFixed(2)} DZD ≈ ${liters.toStringAsFixed(2)}L',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
