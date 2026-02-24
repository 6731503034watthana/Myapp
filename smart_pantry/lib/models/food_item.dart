import 'package:flutter/material.dart';
import 'package:smart_pantry/core/constants/app_colors.dart';
import 'package:smart_pantry/models/food_category.dart';

enum FoodStatus { safe, warning, expired }

// --- ส่วนนี้คือพระเอกครับ ห้ามหาย! ---
extension FoodStatusExtension on FoodStatus {
  Color get color {
    switch (this) {
      case FoodStatus.safe: return AppColors.safe;
      case FoodStatus.warning: return AppColors.warning;
      case FoodStatus.expired: return AppColors.expired;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case FoodStatus.safe: return AppColors.safeBackground;
      case FoodStatus.warning: return AppColors.warningBackground;
      case FoodStatus.expired: return AppColors.expiredBackground;
    }
  }
}
// ------------------------------------

class FoodItem {
  final String id;
  final String name;
  final FoodCategory category;
  final String emoji;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double quantity;      // เปลี่ยนเป็น double เพื่อรองรับทศนิยม เช่น 1.5
  final String unit;
  final String? imagePath;    // เพิ่มตัวแปรสำหรับเก็บที่อยู่รูปภาพ (เผื่อไม่ได้ใส่รูป เลยให้เป็น null ได้)
  final String? notes;
  bool isConsumed;
  bool isDiscarded;
  DateTime? consumedDate;
  DateTime? discardedDate;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.purchaseDate,
    required this.expiryDate,
    this.quantity = 1.0,      // ค่าเริ่มต้นเป็น 1.0
    this.unit = 'ชิ้น',         // ค่าเริ่มต้นเป็น 'ชิ้น'
    this.imagePath,           // รับค่า imagePath
    this.notes,
    this.isConsumed = false,
    this.isDiscarded = false,
    this.consumedDate,
    this.discardedDate,
  });

  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;

  FoodStatus get status {
    if (daysRemaining > 3) return FoodStatus.safe;
    if (daysRemaining >= 0) return FoodStatus.warning;
    return FoodStatus.expired;
  }

  String get statusText {
    switch (status) {
      case FoodStatus.safe: return 'Safe';
      case FoodStatus.warning: return 'Warning';
      case FoodStatus.expired: return 'Expired';
    }
  }

  String get daysRemainingText {
    if (daysRemaining > 0) {
      return '$daysRemaining days left';
    } else if (daysRemaining == 0) {
      return 'Expires today!';
    } else {
      return '${daysRemaining.abs()} days ago';
    }
  }
}