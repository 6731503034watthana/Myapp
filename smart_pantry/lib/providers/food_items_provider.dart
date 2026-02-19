import 'package:flutter/material.dart';
import 'package:smart_pantry/models/food_item.dart';
import 'package:smart_pantry/models/food_category.dart';
import 'package:smart_pantry/services/mock_data_service.dart';

class FoodItemsProvider extends ChangeNotifier {
  List<FoodItem> _items = [];
  bool _isLoading = false;
  FoodCategory? _selectedCategory;

  // Basic Getters
  List<FoodItem> get items => _items;
  bool get isLoading => _isLoading;
  FoodCategory? get selectedCategory => _selectedCategory;

  // -- Getters สำหรับหน้า Dashboard --
  List<FoodItem> get activeItems {
    final active = _items.where((i) => !i.isConsumed && !i.isDiscarded).toList();
    active.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return active;
  }

  int get safeCount => activeItems.where((i) => i.status == FoodStatus.safe).length;
  int get warningCount => activeItems.where((i) => i.status == FoodStatus.warning).length;
  int get expiredCount => activeItems.where((i) => i.status == FoodStatus.expired).length;

  // -- Getters สำหรับหน้า Categories --
  List<FoodItem> get filteredItems {
    if (_selectedCategory == null) {
      return activeItems;
    }
    return activeItems.where((i) => i.category == _selectedCategory).toList();
  }

  int getCategoryCount(FoodCategory category) {
    return activeItems.where((i) => i.category == category).length;
  }

  // -- Getters สำหรับหน้า Settings (Stats) --
  int get totalTracked => _items.length;
  int get totalConsumed => _items.where((i) => i.isConsumed).length;
  int get totalDiscarded => _items.where((i) => i.isDiscarded).length;

  // -- Actions --

  void loadMockData() {
    _isLoading = true;
    notifyListeners();
    // Simulate delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _items = MockDataService.getFoodItems();
      _isLoading = false;
      notifyListeners();
    });
  }

  void addItem(FoodItem item) {
    _items.add(item);
    notifyListeners();
  }

  // ใช้ชื่อ consumeItem ให้ตรงกับ ItemDetailScreen
  void consumeItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isConsumed = true;
      _items[index].consumedDate = DateTime.now();
      notifyListeners();
    }
  }

  // ใช้ชื่อ discardItem ให้ตรงกับ ItemDetailScreen
  void discardItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isDiscarded = true;
      _items[index].discardedDate = DateTime.now();
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void setCategory(FoodCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ฟังก์ชันสำหรับปุ่ม Clear History ในหน้า Settings
  void clearHistory() {
    _items.removeWhere((item) => item.isConsumed || item.isDiscarded);
    notifyListeners();
  }
}