import 'package:smart_pantry/models/food_item.dart';
import 'package:smart_pantry/models/food_category.dart';
import 'package:smart_pantry/models/user.dart';

class MockDataService {
  static List<FoodItem> getFoodItems() {
    final now = DateTime.now();
    return [
      FoodItem(
        id: '1',
        name: 'Milk',
        category: FoodCategory.dairy,
        emoji: '🥛',
        purchaseDate: now.subtract(const Duration(days: 2)),
        expiryDate: now.add(const Duration(days: 5)),
        quantity: 1,
        unit: 'bottle',
        notes: 'Fresh milk from supermarket',
      ),
      FoodItem(
        id: '2',
        name: 'Eggs',
        category: FoodCategory.dairy,
        emoji: '🥚',
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 7)),
        quantity: 6,
        unit: 'pieces',
      ),
      FoodItem(
        id: '3',
        name: 'Bread',
        category: FoodCategory.dryGoods,
        emoji: '🍞',
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 2)),
        quantity: 1,
        unit: 'pack',
      ),
      FoodItem(
        id: '4',
        name: 'Spinach',
        category: FoodCategory.vegetables,
        emoji: '🥬',
        purchaseDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.subtract(const Duration(days: 1)),
        quantity: 1,
        unit: 'bag',
      ),
      FoodItem(
        id: '5',
        name: 'Chicken',
        category: FoodCategory.meat,
        emoji: '🍗',
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 4)),
        quantity: 1,
        unit: 'pack',
      ),
    ];
  }

  // เพิ่มฟังก์ชันนี้สำหรับหน้า Add Item (Quick Select)
  static List<Map<String, dynamic>> getQuickSelectFoods() {
    return [
      {'name': 'Milk', 'emoji': '🥛', 'category': FoodCategory.dairy},
      {'name': 'Eggs', 'emoji': '🥚', 'category': FoodCategory.dairy},
      {'name': 'Bread', 'emoji': '🍞', 'category': FoodCategory.dryGoods},
      {'name': 'Rice', 'emoji': '🍚', 'category': FoodCategory.dryGoods},
      {'name': 'Apple', 'emoji': '🍎', 'category': FoodCategory.fruits},
      {'name': 'Banana', 'emoji': '🍌', 'category': FoodCategory.fruits},
      {'name': 'Chicken', 'emoji': '🍗', 'category': FoodCategory.meat},
      {'name': 'Pork', 'emoji': '🥩', 'category': FoodCategory.meat},
      {'name': 'Cabbage', 'emoji': '🥬', 'category': FoodCategory.vegetables},
      {'name': 'Carrot', 'emoji': '🥕', 'category': FoodCategory.vegetables},
    ];
  }

  static User getMockUser() {
    return User(
      id: 'u-001',
      displayName: 'Auntie Somsri',
      email: 'somsri@example.com',
      preferences: UserPreferences(),
      statistics: UserStatistics(
        totalItemsAdded: 127,
        totalConsumed: 95,
        totalDiscarded: 32,
      ),
    );
  }
}