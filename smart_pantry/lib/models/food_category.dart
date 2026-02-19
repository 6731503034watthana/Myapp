import 'package:flutter/material.dart';
import 'package:smart_pantry/core/constants/app_colors.dart';

enum FoodCategory {
  vegetables('Vegetables', '🥦', AppColors.vegetables),
  meat('Meat', '🥩', AppColors.meat),
  dairy('Dairy', '🧀', AppColors.dairy),
  fruits('Fruits', '🍎', AppColors.fruits),
  dryGoods('Dry Goods', '🌾', AppColors.dryGoods),
  others('Others', '📦', AppColors.others);

  final String label;
  final String emoji;
  final Color color;

  const FoodCategory(this.label, this.emoji, this.color);
}
