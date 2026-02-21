import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. เพิ่ม import ของ Firebase
import 'package:provider/provider.dart';
import 'package:smart_pantry/config/router.dart';
import 'package:smart_pantry/core/constants/app_theme.dart';
import 'package:smart_pantry/providers/food_items_provider.dart';
import 'package:smart_pantry/providers/auth_provider.dart';
import 'firebase_options.dart'; // 2. เพิ่ม import ไฟล์ตั้งค่า Firebase ที่ระบบสร้างให้

// 3. เปลี่ยนเป็น async เพื่อให้รอ Firebase โหลดเสร็จก่อน
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  // 4. สั่งเริ่มต้นการทำงานของ Firebase
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