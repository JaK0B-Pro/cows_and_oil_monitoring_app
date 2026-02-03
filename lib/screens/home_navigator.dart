import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user_model.dart';
import 'supplier/supplier_dashboard.dart';
import 'consumer/consumer_dashboard.dart';
import 'driver/driver_dashboard.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final currentUser = dataService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    switch (currentUser.role) {
      case UserRole.supplierCompany:
        return const SupplierDashboard();
      case UserRole.consumerCompany:
        return const ConsumerDashboard();
      case UserRole.driver:
        return const DriverDashboard();
    }
  }
}
