import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_pantry/models/food_item.dart';
import 'package:smart_pantry/models/food_category.dart';
import 'package:smart_pantry/services/firestore_service.dart';

class FoodItemsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<FoodItem> _items = [];
  bool _isLoading = false;
  FoodCategory? _selectedCategory;
  StreamSubscription? _subscription;
  String? _userId;
  List<FoodCategory> _categories = [];

  List<FoodItem> get items => _items;
  bool get isLoading => _isLoading;
  FoodCategory? get selectedCategory => _selectedCategory;

  List<FoodItem> get activeItems {
    final active = _items.where((i) => !i.isConsumed && !i.isDiscarded).toList();
    active.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return active;
  }

  int get safeCount => activeItems.where((i) => i.status == FoodStatus.safe).length;
  int get warningCount => activeItems.where((i) => i.status == FoodStatus.warning).length;
  int get expiredCount => activeItems.where((i) => i.status == FoodStatus.expired).length;

  List<FoodItem> get filteredItems {
    if (_selectedCategory == null) return activeItems;
    return activeItems.where((i) => i.category.id == _selectedCategory!.id).toList();
  }

  int getCategoryCount(FoodCategory category) {
    return activeItems.where((i) => i.category.id == category.id).length;
  }

  int get totalTracked => _items.length;
  int get totalConsumed => _items.where((i) => i.isConsumed).length;
  int get totalDiscarded => _items.where((i) => i.isDiscarded).length;

  void listenToItems(String userId, List<FoodCategory> categories) {
    _userId = userId;
    _categories = categories;
    _isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _firestoreService.getFoodItemsRaw(userId).listen((rawItems) {
      _items = rawItems.map((map) {
        final catId = map['categoryId'] as String? ?? '';
        FoodCategory category;
        try {
          category = _categories.firstWhere((c) => c.id == catId);
        } catch (_) {
          category = FoodCategory(id: catId, label: catId, emoji: '📦', color: const Color(0xFF9E9E9E));
        }
        return FoodItem.fromMap(map, category);
      }).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  void updateCategories(List<FoodCategory> categories) {
    _categories = categories;
    if (_userId != null) {
      final updatedItems = _items.map((item) {
        try {
          final cat = _categories.firstWhere((c) => c.id == item.category.id);
          return FoodItem(
            id: item.id, name: item.name, category: cat, emoji: item.emoji,
            purchaseDate: item.purchaseDate, expiryDate: item.expiryDate,
            quantity: item.quantity, unit: item.unit, notes: item.notes,
            imageUrl: item.imageUrl, isConsumed: item.isConsumed,
            isDiscarded: item.isDiscarded, consumedDate: item.consumedDate,
            discardedDate: item.discardedDate,
          );
        } catch (_) { return item; }
      }).toList();
      _items = updatedItems;
      notifyListeners();
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _items = [];
    _selectedCategory = null;
    notifyListeners();
  }

  // ===== Actions =====

  Future<void> addItem(FoodItem item, {File? imageFile}) async {
    if (_userId == null) return;

    String? imageUrl;
    if (imageFile != null) {
      try {
        imageUrl = await _firestoreService.uploadImage(_userId!, item.id, imageFile);
      } catch (_) {
        // Image upload failed — save item without image
      }
    }

    final itemToSave = FoodItem(
      id: item.id, name: item.name, category: item.category,
      emoji: item.emoji, purchaseDate: item.purchaseDate,
      expiryDate: item.expiryDate, quantity: item.quantity,
      unit: item.unit, notes: item.notes,
      imageUrl: imageUrl ?? item.imageUrl,
    );

    await _firestoreService.addFoodItem(_userId!, itemToSave);
  }

  Future<void> consumeItem(String id) async {
    if (_userId == null) return;
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isConsumed = true;
      _items[index].consumedDate = DateTime.now();
      notifyListeners();
      await _firestoreService.updateFoodItem(_userId!, id, {
        'isConsumed': true,
        'consumedDate': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> discardItem(String id) async {
    if (_userId == null) return;
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isDiscarded = true;
      _items[index].discardedDate = DateTime.now();
      notifyListeners();
      await _firestoreService.updateFoodItem(_userId!, id, {
        'isDiscarded': true,
        'discardedDate': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> updateQuantity(String id, int quantity, String unit) async {
    if (_userId == null) return;
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = _items[index];
      _items[index] = FoodItem(
        id: item.id, name: item.name, category: item.category,
        emoji: item.emoji, purchaseDate: item.purchaseDate,
        expiryDate: item.expiryDate, quantity: quantity,
        unit: unit, notes: item.notes, imageUrl: item.imageUrl,
        isConsumed: item.isConsumed, isDiscarded: item.isDiscarded,
        consumedDate: item.consumedDate, discardedDate: item.discardedDate,
      );
      notifyListeners();
      await _firestoreService.updateFoodItem(_userId!, id, {'quantity': quantity, 'unit': unit});
    }
  }

  Future<void> updateItemImage(String itemId, File imageFile) async {
    if (_userId == null) return;
    final imageUrl = await _firestoreService.uploadImage(_userId!, itemId, imageFile);
    await _firestoreService.updateFoodItem(_userId!, itemId, {'imageUrl': imageUrl});
  }

  Future<void> removeItem(String id) async {
    if (_userId == null) return;
    await _firestoreService.deleteFoodItem(_userId!, id);
    await _firestoreService.deleteImage(_userId!, id);
  }

  void setCategory(FoodCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> resetPantry() async {
    if (_userId == null) return;
    await _firestoreService.deleteAllFoodItems(_userId!);
    _items = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}