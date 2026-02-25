import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  const FoodItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Image or Emoji
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: item.status.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                image: item.imageUrl != null
                    ? DecorationImage(
                        image: item.imageUrl!.startsWith('/')
                            ? FileImage(File(item.imageUrl!)) as ImageProvider
                            : NetworkImage(item.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.imageUrl == null
                  ? Center(child: Text(item.emoji, style: const TextStyle(fontSize: 36)))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${item.category.emoji} ${item.category.label}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  const SizedBox(height: 6),
                  StatusBadge(status: item.status),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item.daysRemaining}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: item.status.color)),
                Text(
                  item.daysRemaining >= 0 ? 'DAYS\nLEFT' : 'DAYS\nAGO',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey[500], height: 1.2),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
