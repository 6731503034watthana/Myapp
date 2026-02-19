import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// เพิ่มบรรทัดนี้ครับ เพื่อให้รู้จัก .color และ .backgroundColor
import '../../../models/food_item.dart'; 
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/food_items_provider.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodItemsProvider>(
      builder: (context, provider, _) {
        final item = provider.items.where((i) => i.id == itemId).firstOrNull;
        if (item == null) {
          return Scaffold(appBar: AppBar(title: const Text('Not Found')), body: const Center(child: Text('Item not found.')));
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Item Detail'), leading: IconButton(icon: const Icon(Icons.arrow_back, size: 28), onPressed: () => context.pop())),
          body: SingleChildScrollView(child: Column(children: [
            // ตรงนี้จะไม่แดงแล้วครับ
            Container(width: double.infinity, height: 200, color: item.status.backgroundColor, child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 100)))),
            Padding(padding: const EdgeInsets.all(AppTheme.spacingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: item.category.color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('${item.category.emoji} ${item.category.label}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: item.category.color))),
              const SizedBox(height: 20),
              _DetailCard(icon: '📅', label: 'Expiry Date', value: DateFormat('MMM dd, yyyy').format(item.expiryDate)),
              const SizedBox(height: 10),
              // ตรงนี้ก็จะไม่แดงแล้ว
              _DetailCard(icon: '⏳', label: 'Days Remaining', value: item.daysRemainingText, valueColor: item.status.color),
              const SizedBox(height: 10),
              _DetailCard(icon: '📦', label: 'Quantity', value: '${item.quantity} ${item.unit}'),
              const SizedBox(height: 10),
              Row(children: [const Text('Status: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), StatusBadge(status: item.status)]),
              if (item.notes != null) ...[const SizedBox(height: 16), Text('📝 ${item.notes}', style: TextStyle(fontSize: 15, color: Colors.grey[600]))],
              const SizedBox(height: 32),
              ActionButton(label: 'Consumed', emoji: '🍽️', color: AppColors.safe, onPressed: () {
                provider.consumeItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Marked as consumed!', style: TextStyle(fontSize: 16)), backgroundColor: AppColors.safe));
                context.pop();
              }),
              const SizedBox(height: 12),
              ActionButton(label: 'Discarded', emoji: '🗑️', color: AppColors.expired, onPressed: () {
                provider.discardItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Marked as discarded', style: TextStyle(fontSize: 16)), backgroundColor: AppColors.expired));
                context.pop();
              }),
            ])),
          ])),
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String icon; final String label; final String value; final Color? valueColor;
  const _DetailCard({required this.icon, required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[500])),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary)),
        ]),
      ]),
    );
  }
}