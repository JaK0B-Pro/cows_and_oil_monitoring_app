import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../models/driver_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class DriverManagementScreen extends StatelessWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final company = dataService.getCompanyByUserId(dataService.currentUser!.id);
    
    if (company == null) {
      return const Scaffold(
        body: Center(child: Text('Company not found')),
      );
    }

    final drivers = dataService.getDriversByCompanyId(company.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDriverDialog(context, company.id, company.name),
          ),
        ],
      ),
      body: drivers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No drivers added yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddDriverDialog(context, company.id, company.name),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Driver'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                return _DriverCard(driver: drivers[index]);
              },
            ),
    );
  }

  void _showAddDriverDialog(BuildContext context, String companyId, String companyName) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final licenseController = TextEditingController();
    final vehicleController = TextEditingController();
    final truckModelController = TextEditingController();
    final licensePlateController = TextEditingController();
    final limitController = TextEditingController(text: '1000');
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDOB;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Driver'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (!v!.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (v!.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone (Optional)',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: vehicleController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number (Optional)',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: truckModelController,
                  decoration: const InputDecoration(
                    labelText: 'Truck Model (Optional)',
                    prefixIcon: Icon(Icons.local_shipping),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(
                    labelText: 'License Plate (Optional)',
                    prefixIcon: Icon(Icons.pin),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: limitController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Limit (Liters)',
                    prefixIcon: Icon(Icons.local_gas_station),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(v!) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final dataService = Provider.of<DataService>(context, listen: false);
              
              // Check if email exists
              if (dataService.users.any((u) => u.email == emailController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email already exists'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              final userId = dataService.generateId();
              final driverId = dataService.generateId();

              // Create user account for driver
              final user = UserModel(
                id: userId,
                email: emailController.text.trim(),
                password: passwordController.text,
                role: UserRole.driver,
                name: nameController.text.trim(),
                phoneNumber: phoneController.text.trim().isEmpty 
                    ? null 
                    : phoneController.text.trim(),
                dateOfBirth: selectedDOB,
                companyId: companyId,
                createdAt: DateTime.now(),
              );

              // Create driver profile
              final driver = DriverModel(
                id: driverId,
                userId: userId,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phoneNumber: phoneController.text.trim().isEmpty 
                    ? null 
                    : phoneController.text.trim(),
                consumerCompanyId: companyId,
                consumerCompanyName: companyName,
                licenseNumber: licenseController.text.trim(),
                vehicleNumber: vehicleController.text.trim().isEmpty 
                    ? null 
                    : vehicleController.text.trim(),
                truckModel: truckModelController.text.trim().isEmpty 
                    ? null 
                    : truckModelController.text.trim(),
                licensePlate: licensePlateController.text.trim().isEmpty 
                    ? null 
                    : licensePlateController.text.trim(),
                monthlyLimit: double.parse(limitController.text),
                createdAt: DateTime.now(),
              );

              // Add user first
              await dataService.register(user, null);
              // Then add driver
              await dataService.addDriver(driver);

              if (!context.mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Driver added successfully'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverModel driver;

  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final percentage = (driver.totalLitersConsumed / driver.monthlyLimit * 100).clamp(0, 100);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: driver.isActive ? AppTheme.primaryColor : Colors.grey,
                child: Text(
                  driver.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (driver.vehicleNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            driver.vehicleNumber!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showDriverOptions(context, driver),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consumed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${driver.totalLitersConsumed.toStringAsFixed(1)}L',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Limit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${driver.monthlyLimit.toStringAsFixed(0)}L',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: driver.isActive 
                          ? AppTheme.accentColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      driver.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: driver.isActive ? AppTheme.accentColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 90 ? AppTheme.errorColor : AppTheme.accentColor,
              ),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            '${percentage.toStringAsFixed(1)}% used',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showDriverOptions(BuildContext context, DriverModel driver) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                driver.isActive ? Icons.block : Icons.check_circle,
                color: driver.isActive ? AppTheme.errorColor : AppTheme.accentColor,
              ),
              title: Text(driver.isActive ? 'Deactivate' : 'Activate'),
              onTap: () async {
                final dataService = Provider.of<DataService>(context, listen: false);
                await dataService.updateDriver(
                  driver.copyWith(isActive: !driver.isActive),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('Remove Driver'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Remove Driver'),
                    content: Text('Are you sure you want to remove ${driver.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true || !context.mounted) return;

                final dataService = Provider.of<DataService>(context, listen: false);
                await dataService.removeDriver(driver.id);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Driver removed'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
