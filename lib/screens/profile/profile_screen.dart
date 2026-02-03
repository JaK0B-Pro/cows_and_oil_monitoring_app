import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final currentUser = dataService.currentUser!;
    final company = dataService.getCompanyByUserId(currentUser.id);
    final driver = dataService.getDriverByUserId(currentUser.id);

    final qrData = jsonEncode({
      'userId': currentUser.id,
      'name': currentUser.name,
      'email': currentUser.email,
      'role': currentUser.role.toString(),
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: AppTheme.gradientBoxDecoration(borderRadius: 0),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          currentUser.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentUser.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // QR Code Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      children: [
                        Text(
                          'Your QR Code',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Show this to others for transactions',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getRoleText(currentUser.role),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Profile Information
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          icon: Icons.badge,
                          label: 'Role',
                          value: _getRoleText(currentUser.role),
                        ),
                        if (currentUser.phoneNumber != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            icon: Icons.phone,
                            label: 'Phone',
                            value: currentUser.phoneNumber!,
                          ),
                        ],
                        if (currentUser.dateOfBirth != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            icon: Icons.cake,
                            label: 'Date of Birth',
                            value: DateFormat('MMMM dd, yyyy').format(currentUser.dateOfBirth!),
                          ),
                        ],
                        if (company != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            icon: Icons.business,
                            label: 'Company',
                            value: company.name,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            icon: Icons.location_on,
                            label: 'Address',
                            value: company.address,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            icon: Icons.phone_in_talk,
                            label: 'Company Phone',
                            value: company.phoneNumber,
                          ),
                          if (company.taxId != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              icon: Icons.receipt_long,
                              label: 'Tax ID',
                              value: company.taxId!,
                            ),
                          ],
                        ],
                        if (driver != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            icon: Icons.business,
                            label: 'Company',
                            value: driver.consumerCompanyName,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            icon: Icons.credit_card,
                            label: 'License',
                            value: driver.licenseNumber,
                          ),
                          if (driver.vehicleNumber != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              icon: Icons.directions_car,
                              label: 'Vehicle',
                              value: driver.vehicleNumber!,
                            ),
                          ],
                          if (driver.truckModel != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              icon: Icons.local_shipping,
                              label: 'Truck Model',
                              value: driver.truckModel!,
                            ),
                          ],
                          if (driver.licensePlate != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              icon: Icons.pin,
                              label: 'License Plate',
                              value: driver.licensePlate!,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.supplierCompany:
        return 'Supplier Company';
      case UserRole.consumerCompany:
        return 'Consumer Company';
      case UserRole.driver:
        return 'Driver';
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
