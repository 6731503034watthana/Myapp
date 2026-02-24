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

  // ===== Default categories =====
  static const List<FoodCategory> defaults = [
    FoodCategory(id: 'vegetables', label: 'Vegetables', emoji: '🥦', color: AppColors.vegetables),
    FoodCategory(id: 'meat', label: 'Meat', emoji: '🥩', color: AppColors.meat),
    FoodCategory(id: 'dairy', label: 'Dairy', emoji: '🧀', color: AppColors.dairy),
    FoodCategory(id: 'fruits', label: 'Fruits', emoji: '🍎', color: AppColors.fruits),
    FoodCategory(id: 'dryGoods', label: 'Dry Goods', emoji: '🌾', color: AppColors.dryGoods),
  ];

  // ===== สีให้เลือกตอนสร้าง category ใหม่ =====
  static const List<Color> availableColors = [
    AppColors.vegetables,
    AppColors.meat,
    AppColors.dairy,
    AppColors.fruits,
    AppColors.dryGoods,
    AppColors.others,
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEC407A),
    Color(0xFF78909C),
  ];

  // ===== Emoji ให้เลือก =====
  static const List<String> availableEmojis = [
    '🥦', '🥩', '🧀', '🍎', '🌾', '📦',
    '🍗', '🐟', '🥬', '🍞', '🥛', '🌶️',
    '🍜', '🍰', '🥤', '🧊', '🍳', '🥫',
  ];

  // ===== Firestore conversion =====
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'emoji': emoji,
      'color': color.value,
    };
  }

  factory FoodCategory.fromMap(Map<String, dynamic> map) {
    return FoodCategory(
      id: map['id'] as String,
      label: map['label'] as String,
      emoji: map['emoji'] as String,
      color: Color(map['color'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
