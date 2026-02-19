import 'package:flutter/material.dart';
import 'package:smart_pantry/core/constants/app_theme.dart';
import 'package:smart_pantry/models/food_category.dart';

class CategoryCard extends StatelessWidget {
  final FoodCategory category;
  final int itemCount;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.itemCount,
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
            colors: [
              category.color,
              category.color.withOpacity(0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              category.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Count: $itemCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
