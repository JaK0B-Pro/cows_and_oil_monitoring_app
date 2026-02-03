import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../models/company_model.dart';
import '../../models/transaction_model.dart';
import '../profile/profile_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../transactions/new_transaction_screen.dart';
import '../transactions/pending_requests_screen.dart';
import '../reports/monthly_expenses_screen.dart';
import 'customer_companies_screen.dart';
import 'package:intl/intl.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardHome(),
      const TransactionListScreen(),
      const PendingRequestsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NewTransactionScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final company = dataService.getCompanyByUserId(dataService.currentUser!.id);
    
    if (company == null) {
      return const Scaffold(
        body: Center(child: Text('Company not found')),
      );
    }

    final transactions = dataService.getTransactionsByCompanyId(company.id);
    final approvedTransactions = transactions
        .where((t) => t.status == TransactionStatus.approved)
        .toList();
    
    final todayTransactions = approvedTransactions.where((t) {
      final now = DateTime.now();
      return t.completedAt != null &&
          t.completedAt!.year == now.year &&
          t.completedAt!.month == now.month &&
          t.completedAt!.day == now.day;
    }).toList();

    final todayRevenue = todayTransactions.fold<double>(
      0,
      (sum, t) => sum + t.totalPrice,
    );
    
    final todayLiters = todayTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amountLiters,
    );

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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          company.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Supplier Company',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceCard(
                          context: context,
                          title: 'Total Revenue',
                          value: '\$${company.balanceMoney.toStringAsFixed(2)}',
                          icon: FontAwesomeIcons.dollarSign,
                          gradient: AppTheme.primaryGradient,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBalanceCard(
                          context: context,
                          title: 'Fuel Stock',
                          value: '${company.balanceLiters.toStringAsFixed(1)}L',
                          icon: FontAwesomeIcons.gasPump,
                          gradient: AppTheme.successGradient,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Today's Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          title: "Today's Revenue",
                          value: '\$${todayRevenue.toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          title: 'Today\'s Liters',
                          value: '${todayLiters.toStringAsFixed(1)}L',
                          icon: Icons.local_gas_station,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerCompaniesScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.business),
                          label: const Text('Customers'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MonthlyExpensesScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Reports'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to transactions tab
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (approvedTransactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: AppTheme.cardDecoration(),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...approvedTransactions.take(5).map((transaction) {
                      return _buildTransactionCard(context, transaction);
                    }),
                  
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.gradientBoxDecoration(gradient: gradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel transaction) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.initiatorName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    if (transaction.consumerCompanyName != null)
                      Text(
                        transaction.consumerCompanyName!,
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
                      color: AppTheme.accentColor,
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
          const SizedBox(height: 8),
          Text(
            dateFormat.format(transaction.completedAt ?? transaction.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
