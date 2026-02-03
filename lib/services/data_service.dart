import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/company_model.dart';
import '../models/driver_model.dart';
import '../models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class DataService extends ChangeNotifier {
  static const String _usersKey = 'users';
  static const String _companiesKey = 'companies';
  static const String _driversKey = 'drivers';
  static const String _transactionsKey = 'transactions';
  static const String _currentUserKey = 'currentUser';

  final Uuid _uuid = const Uuid();
  
  List<UserModel> _users = [];
  List<CompanyModel> _companies = [];
  List<DriverModel> _drivers = [];
  List<TransactionModel> _transactions = [];
  UserModel? _currentUser;

  List<UserModel> get users => _users;
  List<CompanyModel> get companies => _companies;
  List<DriverModel> get drivers => _drivers;
  List<TransactionModel> get transactions => _transactions;
  UserModel? get currentUser => _currentUser;

  Future<void> initialize() async {
    await loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load users
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> usersList = jsonDecode(usersJson);
      _users = usersList.map((json) => UserModel.fromJson(json)).toList();
    }
    
    // Load companies
    final companiesJson = prefs.getString(_companiesKey);
    if (companiesJson != null) {
      final List<dynamic> companiesList = jsonDecode(companiesJson);
      _companies = companiesList.map((json) => CompanyModel.fromJson(json)).toList();
    }
    
    // Load drivers
    final driversJson = prefs.getString(_driversKey);
    if (driversJson != null) {
      final List<dynamic> driversList = jsonDecode(driversJson);
      _drivers = driversList.map((json) => DriverModel.fromJson(json)).toList();
    }
    
    // Load transactions
    final transactionsJson = prefs.getString(_transactionsKey);
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsJson);
      _transactions = transactionsList.map((json) => TransactionModel.fromJson(json)).toList();
    }
    
    // Load current user
    final currentUserJson = prefs.getString(_currentUserKey);
    if (currentUserJson != null) {
      _currentUser = UserModel.fromJson(jsonDecode(currentUserJson));
    }
    
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_usersKey, jsonEncode(_users.map((u) => u.toJson()).toList()));
    await prefs.setString(_companiesKey, jsonEncode(_companies.map((c) => c.toJson()).toList()));
    await prefs.setString(_driversKey, jsonEncode(_drivers.map((d) => d.toJson()).toList()));
    await prefs.setString(_transactionsKey, jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    
    if (_currentUser != null) {
      await prefs.setString(_currentUserKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  // Authentication
  Future<bool> login(String email, String password) async {
    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
      _currentUser = user;
      await saveData();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(UserModel user, CompanyModel? company) async {
    try {
      // Check if email exists
      if (_users.any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
        return false;
      }
      
      _users.add(user);
      
      if (company != null) {
        _companies.add(company);
      }
      
      _currentUser = user;
      await saveData();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    notifyListeners();
  }

  // Company operations
  CompanyModel? getCompanyByUserId(String userId) {
    try {
      return _companies.firstWhere((c) => c.userId == userId);
    } catch (e) {
      return null;
    }
  }

  CompanyModel? getCompanyById(String companyId) {
    try {
      return _companies.firstWhere((c) => c.id == companyId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCompany(CompanyModel company) async {
    final index = _companies.indexWhere((c) => c.id == company.id);
    if (index != -1) {
      _companies[index] = company;
      await saveData();
      notifyListeners();
    }
  }

  // Driver operations
  Future<void> addDriver(DriverModel driver) async {
    _drivers.add(driver);
    
    // Add driver ID to company
    final company = getCompanyById(driver.consumerCompanyId);
    if (company != null) {
      final updatedCompany = company.copyWith(
        driverIds: [...company.driverIds, driver.id],
      );
      await updateCompany(updatedCompany);
    }
    
    await saveData();
    notifyListeners();
  }

  Future<void> removeDriver(String driverId) async {
    final driver = _drivers.firstWhere((d) => d.id == driverId);
    _drivers.removeWhere((d) => d.id == driverId);
    
    // Remove driver ID from company
    final company = getCompanyById(driver.consumerCompanyId);
    if (company != null) {
      final updatedCompany = company.copyWith(
        driverIds: company.driverIds.where((id) => id != driverId).toList(),
      );
      await updateCompany(updatedCompany);
    }
    
    await saveData();
    notifyListeners();
  }

  Future<void> updateDriver(DriverModel driver) async {
    final index = _drivers.indexWhere((d) => d.id == driver.id);
    if (index != -1) {
      _drivers[index] = driver;
      await saveData();
      notifyListeners();
    }
  }

  List<DriverModel> getDriversByCompanyId(String companyId) {
    return _drivers.where((d) => d.consumerCompanyId == companyId).toList();
  }

  DriverModel? getDriverByUserId(String userId) {
    try {
      return _drivers.firstWhere((d) => d.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Transaction operations
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    await saveData();
    notifyListeners();
    return transaction;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      
      // If approved, update balances
      if (transaction.status == TransactionStatus.approved && 
          _transactions[index].status != TransactionStatus.approved) {
        await _processApprovedTransaction(transaction);
      }
      
      await saveData();
      notifyListeners();
    }
  }

  Future<void> _processApprovedTransaction(TransactionModel transaction) async {
    // Update supplier company balance
    if (transaction.supplierCompanyId != null) {
      final supplierCompany = getCompanyById(transaction.supplierCompanyId!);
      if (supplierCompany != null) {
        final updatedSupplier = supplierCompany.copyWith(
          balanceMoney: supplierCompany.balanceMoney + transaction.totalPrice,
          balanceLiters: supplierCompany.balanceLiters - transaction.amountLiters,
        );
        await updateCompany(updatedSupplier);
      }
    }
    
    // Update consumer company balance
    if (transaction.consumerCompanyId != null) {
      final consumerCompany = getCompanyById(transaction.consumerCompanyId!);
      if (consumerCompany != null) {
        final updatedConsumer = consumerCompany.copyWith(
          balanceLiters: consumerCompany.balanceLiters + transaction.amountLiters,
        );
        await updateCompany(updatedConsumer);
      }
    }
    
    // Update driver consumption
    final driver = _drivers.cast<DriverModel?>().firstWhere(
      (d) => d?.userId == transaction.initiatorId,
      orElse: () => null,
    );
    
    if (driver != null) {
      final updatedDriver = driver.copyWith(
        totalLitersConsumed: driver.totalLitersConsumed + transaction.amountLiters,
      );
      await updateDriver(updatedDriver);
    }
  }

  List<TransactionModel> getTransactionsByUserId(String userId) {
    return _transactions.where(
      (t) => t.initiatorId == userId || t.receiverId == userId,
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TransactionModel> getTransactionsByCompanyId(String companyId) {
    return _transactions.where(
      (t) => t.supplierCompanyId == companyId || t.consumerCompanyId == companyId,
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TransactionModel> getPendingTransactionsForUser(String userId) {
    return _transactions.where(
      (t) => t.receiverId == userId && t.status == TransactionStatus.pending,
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // User operations
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  String generateId() {
    return _uuid.v4();
  }
}
