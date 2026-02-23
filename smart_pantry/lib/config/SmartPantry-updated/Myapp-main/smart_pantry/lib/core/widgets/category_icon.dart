import 'package:flutter/material.dart';
import 'package:smart_pantry/models/food_category.dart';
import 'package:smart_pantry/core/constants/app_theme.dart';

class CategoryIcon extends StatelessWidget {
  final FoodCategory category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryIcon({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [category.color, category.color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: category.color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(category.label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
