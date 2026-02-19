import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_theme.dart';
import '../../../providers/food_items_provider.dart';
import '../widgets/food_item_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FoodItemsProvider>();
      if (provider.items.isEmpty) provider.loadMockData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FoodItemsProvider>(
        builder: (context, provider, _) {
          final items = provider.activeItems;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryDark]),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMD),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('🏠 My Pantry', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('${items.length} items tracked · Sorted by expiry date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
                      ]),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white, padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    _SummaryChip(count: provider.safeCount, label: 'Safe', color: AppColors.safe, bgColor: AppColors.safeBackground),
                    const SizedBox(width: 8),
                    _SummaryChip(count: provider.warningCount, label: 'Warning', color: AppColors.warning, bgColor: AppColors.warningBackground),
                    const SizedBox(width: 8),
                    _SummaryChip(count: provider.expiredCount, label: 'Expired', color: AppColors.expired, bgColor: AppColors.expiredBackground),
                  ]),
                ),
              ),
              if (items.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('🛒', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 16),
                    Text('Your pantry is empty!\nTap + to add items', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                  ])),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(14),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Padding(padding: const EdgeInsets.only(bottom: 10), child: FoodItemCard(item: item, onTap: () => context.push('${AppRoutes.itemDetail}/${item.id}')));
                    },
                    childCount: items.length,
                  )),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addItem),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int count; final String label; final Color color; final Color bgColor;
  const _SummaryChip({required this.count, required this.label, required this.color, required this.bgColor});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}
