import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pantry/config/router.dart';
import 'package:smart_pantry/core/constants/app_theme.dart';
import 'package:smart_pantry/providers/food_items_provider.dart';
import 'package:smart_pantry/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartPantryApp());
}

class SmartPantryApp extends StatelessWidget {
  const SmartPantryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FoodItemsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Smart Pantry',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.elderlyTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
