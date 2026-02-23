import 'package:flutter/material.dart';
import 'package:smart_pantry/core/constants/app_theme.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.minTouchTarget,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.bodyTextSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
