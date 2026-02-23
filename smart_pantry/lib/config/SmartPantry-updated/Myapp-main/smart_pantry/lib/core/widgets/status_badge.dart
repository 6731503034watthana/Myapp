import 'package:flutter/material.dart';
import 'package:smart_pantry/models/food_item.dart';
import 'package:smart_pantry/core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final FoodStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case FoodStatus.safe:
        return AppColors.safeBg;
      case FoodStatus.warning:
        return AppColors.warningBg;
      case FoodStatus.expired:
        return AppColors.expiredBg;
    }
  }

  Color get _textColor {
    switch (status) {
      case FoodStatus.safe:
        return AppColors.safe;
      case FoodStatus.warning:
        return AppColors.warning;
      case FoodStatus.expired:
        return AppColors.expired;
    }
  }

  String get _label {
    switch (status) {
      case FoodStatus.safe:
        return 'Safe';
      case FoodStatus.warning:
        return 'Warning';
      case FoodStatus.expired:
        return 'Expired';
    }
  }

  String get _icon {
    switch (status) {
      case FoodStatus.safe:
        return '✅';
      case FoodStatus.warning:
        return '⚠️';
      case FoodStatus.expired:
        return '❌';
    }
  }
}
