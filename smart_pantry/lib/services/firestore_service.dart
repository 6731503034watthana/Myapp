import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_pantry/models/food_category.dart';
import 'package:smart_pantry/models/food_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  //  CATEGORIES
  // ============================================================

  /// ดึง categories ของ user
  Stream<List<FoodCategory>> getCategories(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FoodCategory.fromMap(doc.data())).toList());
  }

  /// ดึง categories แบบครั้งเดียว
  Future<List<FoodCategory>> getCategoriesOnce(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();
    return snapshot.docs.map((doc) => FoodCategory.fromMap(doc.data())).toList();
  }

  /// เพิ่ม category ใหม่
  Future<void> addCategory(String userId, FoodCategory category) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category.id)
        .set(category.toMap());
  }

  /// ลบ category
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  /// สร้าง default categories ให้ user ใหม่
  Future<void> initDefaultCategories(String userId) async {
    final existing = await getCategoriesOnce(userId);
    if (existing.isEmpty) {
      final batch = _db.batch();
      for (final cat in FoodCategory.defaults) {
        final ref = _db
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc(cat.id);
        batch.set(ref, cat.toMap());
      }
      await batch.commit();
    }
  }

  // ============================================================
  //  FOOD ITEMS
  // ============================================================

  /// ดึง food items ของ user (stream)
  Stream<List<Map<String, dynamic>>> getFoodItemsRaw(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// เพิ่ม food item
  Future<void> addFoodItem(String userId, FoodItem item) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .set(item.toMap());
  }

  /// อัปเดต food item
  Future<void> updateFoodItem(String userId, String itemId, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .update(data);
  }

  /// ลบ food item
  Future<void> deleteFoodItem(String userId, String itemId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  /// ลบ food items ทั้งหมด (Reset Pantry)
  Future<void> deleteAllFoodItems(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

}
