import 'package:flutter/material.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../models/food_category.dart';

class CategoryGrid extends StatelessWidget {
  final FoodCategory? selectedCategory;
  final ValueChanged<FoodCategory> onCategorySelected;

  const CategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: FoodCategory.values.map((category) {
        return CategoryIcon(
          category: category,
          isSelected: selectedCategory == category,
          onTap: () => onCategorySelected(category),
        );
      }).toList(),
    );
  }
}