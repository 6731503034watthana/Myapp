import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FoodQuickSelect extends StatelessWidget {
  final List<Map<String, dynamic>> foods;
  final String? selectedFood;
  final ValueChanged<Map<String, dynamic>> onFoodSelected;

  const FoodQuickSelect({
    super.key,
    required this.foods,
    required this.selectedFood,
    required this.onFoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          final isSelected = selectedFood == food['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ActionChip(
              avatar: Text(food['emoji'] as String),
              label: Text(food['name'] as String),
              backgroundColor: isSelected ? AppColors.primaryLight : Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onPressed: () => onFoodSelected(food),
            ),
          );
        },
      ),
    );
  }
}