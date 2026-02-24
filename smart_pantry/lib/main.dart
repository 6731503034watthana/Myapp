import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // เพิ่ม import นี้
import 'package:smart_pantry/config/router.dart';
import 'package:smart_pantry/core/constants/app_theme.dart';
import 'package:smart_pantry/providers/food_items_provider.dart';
import 'package:smart_pantry/providers/auth_provider.dart';
// import 'firebase_options.dart'; // อย่าลืม import ไฟล์นี้หลังจากรัน flutterfire configure

void main() async {
  // เพิ่ม 2 บรรทัดนี้สำหรับ Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // ปลดคอมเมนต์เมื่อคอนฟิก Firebase แล้ว
  );
  
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