import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
          appBar: AppBar(
            title: const Text('Item Detail'),
            leading: IconButton(icon: const Icon(Icons.arrow_back, size: 28), onPressed: () => context.pop()),
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              // Image or Emoji display
              _ItemImage(item: item, provider: provider),

              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: item.category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.category.emoji} ${item.category.label}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: item.category.color),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DetailCard(icon: '📅', label: 'Expiry Date', value: DateFormat('MMM dd, yyyy').format(item.expiryDate)),
                    const SizedBox(height: 10),
                    _DetailCard(icon: '⏳', label: 'Days Remaining', value: item.daysRemainingText, valueColor: item.status.color),
                    const SizedBox(height: 10),
                    _DetailCard(icon: '📦', label: 'Quantity', value: '${item.quantity} ${item.unit}'),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Text('Status: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      StatusBadge(status: item.status),
                    ]),
                    if (item.notes != null) ...[
                      const SizedBox(height: 16),
                      Text('📝 ${item.notes}', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                    ],
                    const SizedBox(height: 32),
                    ActionButton(
                      label: 'Consumed',
                      emoji: '🍽️',
                      color: AppColors.safe,
                      onPressed: () {
                        provider.consumeItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Marked as consumed!', style: TextStyle(fontSize: 16)), backgroundColor: AppColors.safe),
                        );
                        context.pop();
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: 'Discarded',
                      emoji: '🗑️',
                      color: AppColors.expired,
                      onPressed: () {
                        provider.discardItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🗑️ Marked as discarded', style: TextStyle(fontSize: 16)), backgroundColor: AppColors.expired),
                        );
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ===== Widget แสดงรูปภาพ + ปุ่ม Retake =====
class _ItemImage extends StatelessWidget {
  final FoodItem item;
  final FoodItemsProvider provider;
  const _ItemImage({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // รูปภาพหรือ emoji
        Container(
          width: double.infinity,
          height: 200,
          color: item.status.backgroundColor,
          child: item.imageUrl != null
              ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(child: Text(item.emoji, style: const TextStyle(fontSize: 100))))
              : Center(child: Text(item.emoji, style: const TextStyle(fontSize: 100))),
        ),
        // ปุ่ม Retake / Take Photo
        Positioned(
          bottom: 10,
          right: 10,
          child: Row(
            children: [
              _PhotoButton(
                icon: Icons.camera_alt,
                label: 'Retake',
                onTap: () => _retakePhoto(context, ImageSource.camera),
              ),
              const SizedBox(width: 8),
              _PhotoButton(
                icon: Icons.upload_file,
                label: 'Upload',
                onTap: () => _retakePhoto(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _retakePhoto(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source, imageQuality: 75);
    if (photo != null) {
      final file = File(photo.path);
      await provider.updateItemImage(item.id, file);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📷 Photo updated!', style: TextStyle(fontSize: 16)), backgroundColor: AppColors.safe),
        );
      }
    }
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PhotoButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailCard({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
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
