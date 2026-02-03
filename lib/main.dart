import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataService()..initialize(),
      child: MaterialApp(
        title: 'Oil & Fuel Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        // Show loading while initializing
        if (dataService.currentUser == null) {
          return FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 500)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // Check if user is logged in after initialization
              if (dataService.currentUser != null) {
                return const HomeNavigator();
              }
              
              return const LoginScreen();
            },
          );
        }
        
        return const HomeNavigator();
      },
    );
  }
}
