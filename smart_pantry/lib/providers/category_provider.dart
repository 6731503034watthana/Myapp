import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_pantry/models/food_category.dart';
import 'package:smart_pantry/services/firestore_service.dart';

class CategoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<FoodCategory> _categories = [];
  StreamSubscription? _subscription;
  String? _userId;

  List<FoodCategory> get categories => _categories;

  /// เริ่มฟัง categories จาก Firestore
  void listenToCategories(String userId) {
    _userId = userId;
    _subscription?.cancel();
    _subscription = _firestoreService.getCategories(userId).listen((cats) {
      _categories = cats;
      notifyListeners();
    });
  }

  /// หยุดฟัง
  void stopListening() {
    _subscription?.cancel();
    _categories = [];
    notifyListeners();
  }

  /// เพิ่ม category ใหม่
  Future<void> addCategory(String label, String emoji, Color color) async {
    if (_userId == null) return;
    final id = const Uuid().v4();
    final category = FoodCategory(id: id, label: label, emoji: emoji, color: color);
    await _firestoreService.addCategory(_userId!, category);
  }

  /// ลบ category
  Future<void> deleteCategory(String categoryId) async {
    if (_userId == null) return;
    await _firestoreService.deleteCategory(_userId!, categoryId);
  }

  /// หา category จาก id
  FoodCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// สร้าง default categories สำหรับ user ใหม่
  Future<void> initDefaults(String userId) async {
    await _firestoreService.initDefaultCategories(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
