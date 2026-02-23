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
  final int quantity;
  final String unit;
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
    this.quantity = 1,
    this.unit = 'piece',
    this.notes,
    this.isConsumed = false,
    this.isDiscarded = false,
    this.consumedDate,
    this.discardedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.toMap(), 
      'emoji': emoji,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'isConsumed': isConsumed,
      'isDiscarded': isDiscarded,
      'consumedDate': consumedDate?.toIso8601String(),
      'discardedDate': discardedDate?.toIso8601String(),
    };
  }

  static FoodItem fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: FoodCategory.fromMap(map['category'] ?? {}),
      emoji: map['emoji'] ?? '📦',
      purchaseDate: DateTime.tryParse(map['purchaseDate'] ?? '') ?? DateTime.now(),
      expiryDate: DateTime.tryParse(map['expiryDate'] ?? '') ?? DateTime.now(),
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? 'piece',
      notes: map['notes'],
      isConsumed: map['isConsumed'] ?? false,
      isDiscarded: map['isDiscarded'] ?? false,
      consumedDate: map['consumedDate'] != null ? DateTime.tryParse(map['consumedDate']!) : null,
      discardedDate: map['discardedDate'] != null ? DateTime.tryParse(map['discardedDate']!) : null,
    );
  }

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