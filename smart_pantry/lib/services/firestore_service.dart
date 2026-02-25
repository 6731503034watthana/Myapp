import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smart_pantry/models/food_category.dart';
import 'package:smart_pantry/models/food_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  //  CATEGORIES
  // ============================================================

  Stream<List<FoodCategory>> getCategories(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FoodCategory.fromMap(doc.data())).toList());
  }

  Future<List<FoodCategory>> getCategoriesOnce(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();
    return snapshot.docs.map((doc) => FoodCategory.fromMap(doc.data())).toList();
  }

  Future<void> addCategory(String userId, FoodCategory category) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category.id)
        .set(category.toMap());
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

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

  Stream<List<Map<String, dynamic>>> getFoodItemsRaw(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addFoodItem(String userId, FoodItem item) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> updateFoodItem(String userId, String itemId, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .update(data);
  }

  Future<void> deleteFoodItem(String userId, String itemId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

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

  // ============================================================
  //  IMAGE UPLOAD  <-- ส่วนที่เพิ่มใหม่
  // ============================================================

  /// อัปโหลดรูปภาพไปยัง Firebase Storage
  Future<String> uploadImage(String userId, String itemId, File imageFile) async {
    final ref = _storage.ref().child('users/$userId/items/$itemId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  /// ลบรูปภาพ
  Future<void> deleteImage(String userId, String itemId) async {
    try {
      final ref = _storage.ref().child('users/$userId/items/$itemId.jpg');
      await ref.delete();
    } catch (_) {
      // ไม่มีรูปก็ไม่ต้องทำอะไร
    }
  }
}