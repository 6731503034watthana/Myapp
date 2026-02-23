import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smart_pantry/config/router.dart';
import 'package:smart_pantry/core/constants/app_theme.dart';
import 'package:smart_pantry/providers/food_items_provider.dart';
import 'package:smart_pantry/providers/auth_provider.dart' as app;
import 'package:smart_pantry/providers/category_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartPantryApp());
}

class SmartPantryApp extends StatelessWidget {
  const SmartPantryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app.AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => FoodItemsProvider()),
      ],
      child: const _AppWithAuthListener(),
    );
  }
}

/// Widget ที่ฟัง auth state แล้ว start/stop Firestore listeners
class _AppWithAuthListener extends StatefulWidget {
  const _AppWithAuthListener();
  @override
  State<_AppWithAuthListener> createState() => _AppWithAuthListenerState();
}

class _AppWithAuthListenerState extends State<_AppWithAuthListener> {
  @override
  void initState() {
    super.initState();
    // ฟัง Firebase Auth state เพื่อ start/stop listeners
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final catProvider = context.read<CategoryProvider>();
      final itemsProvider = context.read<FoodItemsProvider>();

      if (user != null) {
        // Login แล้ว -> เริ่มฟัง categories & items
        catProvider.listenToCategories(user.uid);

        // ต้องรอ categories โหลดก่อนแล้วค่อย listen items
        // ใช้ addListener เพื่อรอ categories พร้อม
        void listener() {
          if (catProvider.categories.isNotEmpty) {
            itemsProvider.listenToItems(user.uid, catProvider.categories);
            catProvider.removeListener(listener);
          }
        }
        catProvider.addListener(listener);

        // กรณี categories อาจจะว่าง (user ใหม่ยังไม่มี) ให้ listen items เลย
        Future.delayed(const Duration(seconds: 2), () {
          if (itemsProvider.items.isEmpty && !itemsProvider.isLoading) {
            itemsProvider.listenToItems(user.uid, catProvider.categories);
          }
        });
      } else {
        // Logout -> หยุดฟัง
        catProvider.stopListening();
        itemsProvider.stopListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // อัปเดต items เมื่อ categories เปลี่ยน
    final categories = context.watch<CategoryProvider>().categories;
    final itemsProvider = context.read<FoodItemsProvider>();
    if (categories.isNotEmpty) {
      // ส่ง categories ล่าสุดให้ items provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        itemsProvider.updateCategories(categories);
      });
    }

    return MaterialApp.router(
      title: 'Smart Pantry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.elderlyTheme,
      routerConfig: AppRouter.router,
    );
  }
}
