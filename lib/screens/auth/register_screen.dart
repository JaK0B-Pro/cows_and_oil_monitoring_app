import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../models/user_model.dart';
import '../../models/company_model.dart';
import '../../models/driver_model.dart';
import '../../theme/app_theme.dart';
import '../home_navigator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Company fields
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _taxIdController = TextEditingController();
  
  // Driver fields
  final _licenseNumberController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _truckModelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  
  DateTime? _selectedDateOfBirth;
  
  UserRole _selectedRole = UserRole.driver;
  CompanyType _selectedCompanyType = CompanyType.supplier;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _taxIdController.dispose();
    _licenseNumberController.dispose();
    _vehicleNumberController.dispose();
    _truckModelController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dataService = Provider.of<DataService>(context, listen: false);
    final userId = dataService.generateId();
    
    final user = UserModel(
      id: userId,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: _selectedDateOfBirth,
      createdAt: DateTime.now(),
    );

    CompanyModel? company;
    
    if (_selectedRole == UserRole.supplierCompany || _selectedRole == UserRole.consumerCompany) {
      final companyType = _selectedRole == UserRole.supplierCompany 
          ? CompanyType.supplier 
          : CompanyType.consumer;
      
      company = CompanyModel(
        id: dataService.generateId(),
        name: _companyNameController.text.trim(),
        type: companyType,
        userId: userId,
        address: _companyAddressController.text.trim(),
        phoneNumber: _companyPhoneController.text.trim(),
        taxId: _taxIdController.text.trim().isEmpty ? null : _taxIdController.text.trim(),
        balanceMoney: 0,
        balanceLiters: companyType == CompanyType.supplier ? 10000 : 0, // Initial inventory for suppliers
        createdAt: DateTime.now(),
      );
    }

    final success = await dataService.register(user, company);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeNavigator()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already exists'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Role Selection
                Text(
                  'Account Type',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                _buildRoleCard(
                  role: UserRole.supplierCompany,
                  icon: Icons.store,
                  title: 'Supplier Company',
                  subtitle: 'Sell fuel to drivers and companies',
                ),
                const SizedBox(height: 12),
                
                _buildRoleCard(
                  role: UserRole.consumerCompany,
                  icon: Icons.business,
                  title: 'Consumer Company',
                  subtitle: 'Manage drivers and fuel consumption',
                ),
                const SizedBox(height: 12),
                
                _buildRoleCard(
                  role: UserRole.driver,
                  icon: Icons.person,
                  title: 'Driver',
                  subtitle: 'Individual fuel tracking',
                ),
                
                const SizedBox(height: 32),
                
                // Basic Information
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 16),
                
                // Date of Birth Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDateOfBirth = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (Optional)',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    child: Text(
                      _selectedDateOfBirth == null
                          ? 'Select date'
                          : DateFormat('MMMM dd, yyyy').format(_selectedDateOfBirth!),
                      style: TextStyle(
                        color: _selectedDateOfBirth == null ? Colors.grey : null,
                      ),
                    ),
                  ),
                ),
                
                // Company Information (for companies)
                if (_selectedRole != UserRole.driver) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Company Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _companyAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _companyPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Company Phone',
                      prefixIcon: Icon(Icons.phone_in_talk),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company phone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _taxIdController,
                    decoration: const InputDecoration(
                      labelText: 'Tax ID (Optional)',
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                  ),
                ],
                
                // Driver Information (for drivers)
                if (_selectedRole == UserRole.driver) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Driver Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _licenseNumberController,
                    decoration: const InputDecoration(
                      labelText: 'License Number',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter license number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Number (Optional)',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _truckModelController,
                    decoration: const InputDecoration(
                      labelText: 'Truck Model (Optional)',
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _licensePlateController,
                    decoration: const InputDecoration(
                      labelText: 'License Plate (Optional)',
                      prefixIcon: Icon(Icons.pin),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Register Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;
    
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
