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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

class _AppWithAuthListener extends StatefulWidget {
  const _AppWithAuthListener();
  @override
  State<_AppWithAuthListener> createState() => _AppWithAuthListenerState();
}

class _AppWithAuthListenerState extends State<_AppWithAuthListener> {
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final catProvider = context.read<CategoryProvider>();
      final itemsProvider = context.read<FoodItemsProvider>();

      if (user != null) {
        // เริ่ม listen categories ก่อน
        catProvider.listenToCategories(user.uid);

        // ถ้า categories โหลดแล้ว เรียก listenToItems ได้เลย
        if (catProvider.categories.isNotEmpty) {
          itemsProvider.listenToItems(user.uid, catProvider.categories);
        } else {
          // ถ้ายังไม่มี categories รอจน categories โหลดเสร็จ
          void onCategoriesReady() {
            if (catProvider.categories.isNotEmpty) {
              itemsProvider.listenToItems(user.uid, catProvider.categories);
              catProvider.removeListener(onCategoriesReady);
            }
          }

          catProvider.addListener(onCategoriesReady);
        }
      } else {
        // Logout -> หยุดฟัง
        catProvider.stopListening();
        itemsProvider.stopListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Pantry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.elderlyTheme,
      routerConfig: AppRouter.router,
    );
  }
}
