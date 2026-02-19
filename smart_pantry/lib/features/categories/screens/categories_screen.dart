import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/food_category.dart';
import '../../../providers/food_items_provider.dart';
import '../../dashboard/widgets/food_item_card.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodItemsProvider>(
      builder: (context, provider, _) {
        final selectedCategory = provider.selectedCategory;
        return Scaffold(
          body: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(color: Colors.white, padding: const EdgeInsets.all(AppTheme.spacingMD), child: Row(children: [
                const Expanded(child: Text('📂 Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                if (selectedCategory != null)
                  GestureDetector(
                    onTap: () => provider.setCategory(null),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.expiredBackground, borderRadius: BorderRadius.circular(20)),
                      child: const Text('✕ Clear Filter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.expired))),
                  ),
              ])),
              if (selectedCategory == null)
                Expanded(child: GridView.count(
                  crossAxisCount: 2, padding: const EdgeInsets.all(16), mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.95,
                  children: FoodCategory.values.map((category) => CategoryCard(
                    category: category, itemCount: provider.getCategoryCount(category),
                    onTap: () => provider.setCategory(category),
                  )).toList(),
                ))
              else
                Expanded(child: Column(children: [
                  Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: selectedCategory.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Text(selectedCategory.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Text('${selectedCategory.label} (${provider.filteredItems.length} items)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: selectedCategory.color)),
                    ]),
                  ),
                  Expanded(
                    child: provider.filteredItems.isEmpty
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(selectedCategory.emoji, style: const TextStyle(fontSize: 50)),
                          const SizedBox(height: 12),
                          const Text('No items in this category', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                        ]))
                      : ListView.builder(
                          padding: const EdgeInsets.all(14), itemCount: provider.filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = provider.filteredItems[index];
                            return Padding(padding: const EdgeInsets.only(bottom: 10), child: FoodItemCard(item: item, onTap: () => context.push('${AppRoutes.itemDetail}/${item.id}')));
                          },
                        ),
                  ),
                ])),
            ]),
          ),
        );
      },
    );
  }
}
