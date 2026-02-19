import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label; final String emoji; final double percentage; final Color color;
  const StatBar({super.key, required this.label, required this.emoji, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
      SizedBox(width: 90, child: Text('$emoji $label', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF555555)))),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 28, decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(14)),
        child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: (percentage / 100).clamp(0.0, 1.0),
          child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]), borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 10),
            child: Text('${percentage.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
      )),
    ]));
  }
}
