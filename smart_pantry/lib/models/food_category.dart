import 'package:flutter/material.dart';
import 'package:smart_pantry/core/constants/app_colors.dart';

class FoodCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;

  const FoodCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });

  // สร้างค่า Default คงที่ให้เหมือนตอนเป็น Enum
  static const vegetables = FoodCategory(id: 'vegetables', label: 'Vegetables', emoji: '🥦', color: AppColors.vegetables);
  static const meat = FoodCategory(id: 'meat', label: 'Meat', emoji: '🥩', color: AppColors.meat);
  static const dairy = FoodCategory(id: 'dairy', label: 'Dairy', emoji: '🧀', color: AppColors.dairy);
  static const fruits = FoodCategory(id: 'fruits', label: 'Fruits', emoji: '🍎', color: AppColors.fruits);
  static const dryGoods = FoodCategory(id: 'dryGoods', label: 'Dry Goods', emoji: '🌾', color: AppColors.dryGoods);
  static const others = FoodCategory(id: 'others', label: 'Others', emoji: '📦', color: AppColors.others);

  static const List<FoodCategory> values = [vegetables, meat, dairy, fruits, dryGoods, others];
  static const List<FoodCategory> defaults = values;

  // สำหรับการแปลงข้อมูลลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'emoji': emoji,
      'color': color.value,
    };
  }

  // สำหรับการดึงข้อมูลจาก Firestore
  static FoodCategory fromMap(Map<String, dynamic> map) {
    return FoodCategory(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      emoji: map['emoji'] ?? '',
      color: Color(map['color'] ?? AppColors.others.value),
    );
  }

  // สำคัญ: เอาไว้เปรียบเทียบ Category ตอนใช้ Dropdown หรือ Grid
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}