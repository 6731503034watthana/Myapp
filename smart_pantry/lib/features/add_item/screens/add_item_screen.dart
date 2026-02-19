import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/food_category.dart';
import '../../../models/food_item.dart';
import '../../../providers/food_items_provider.dart';
import '../../../services/mock_data_service.dart';
import '../widgets/category_grid.dart';
import '../widgets/food_quick_select.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  FoodCategory? _selectedCategory;
  String? _selectedFoodName;
  String _selectedEmoji = '📦';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  final _quickFoods = MockDataService.getQuickSelectFoods();

  void _onCategorySelected(FoodCategory category) => setState(() => _selectedCategory = category);

  void _onFoodSelected(Map<String, dynamic> food) {
    setState(() {
      _selectedFoodName = food['name'] as String;
      _selectedEmoji = food['emoji'] as String;
      _selectedCategory = food['category'] as FoodCategory;
    });
  }

  void _changeDate(int days) => setState(() => _expiryDate = _expiryDate.add(Duration(days: days)));

  void _addItem() {
    if (_selectedFoodName == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category and food item', style: TextStyle(fontSize: 16)), backgroundColor: AppColors.warning));
      return;
    }
    final newItem = FoodItem(id: const Uuid().v4(), name: _selectedFoodName!, category: _selectedCategory!, emoji: _selectedEmoji, purchaseDate: DateTime.now(), expiryDate: _expiryDate);
    context.read<FoodItemsProvider>().addItem(newItem);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $_selectedFoodName added to pantry!', style: const TextStyle(fontSize: 16)), backgroundColor: AppColors.safe));
    setState(() { _selectedCategory = null; _selectedFoodName = null; _selectedEmoji = '📦'; _expiryDate = DateTime.now().add(const Duration(days: 7)); });
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(color: Colors.white, padding: const EdgeInsets.all(AppTheme.spacingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('➕ Add Item', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Select a category and food item', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            ])),
            const SizedBox(height: 8),
            _sectionTitle('Select Category'),
            const SizedBox(height: 8),
            CategoryGrid(selectedCategory: _selectedCategory, onCategorySelected: _onCategorySelected),
            const SizedBox(height: 20),
            _sectionTitle('Quick Select'),
            const SizedBox(height: 8),
            FoodQuickSelect(foods: _quickFoods, selectedFood: _selectedFoodName, onFoodSelected: _onFoodSelected),
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.cardRadius), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('📅 Set Expiry Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM dd, yyyy').format(_expiryDate), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ]),
                Row(children: [
                  _DateArrowButton(icon: Icons.chevron_left, onTap: () => _changeDate(-1)),
                  const SizedBox(width: 8),
                  _DateArrowButton(icon: Icons.chevron_right, onTap: () => _changeDate(1)),
                ]),
              ]),
            )),
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: double.infinity, height: AppTheme.minTouchTarget, child: ElevatedButton(
              onPressed: _addItem, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('✅ Add to Pantry', style: TextStyle(fontSize: 18, color: Colors.white)),
            ))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)));
}

class _DateArrowButton extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _DateArrowButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.primary, size: 24),
    ));
  }
}
