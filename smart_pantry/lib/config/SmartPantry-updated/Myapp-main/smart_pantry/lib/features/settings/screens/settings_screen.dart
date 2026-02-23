import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/food_items_provider.dart';
import '../widgets/stat_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _expiryAlerts = true;
  bool _weeklySummary = true;
  bool _weeklyReport = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final displayName = authProvider.displayName;
    final email = authProvider.user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: const Text('⚙️ Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),

              // User info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(email, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) context.go(AppRoutes.login);
                        },
                        child: const Text('Logout', style: TextStyle(color: AppColors.expired, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),

              _sectionHeader('🔔', 'Notifications'),
              _toggleRow('Expiry Alerts', 'Notify 3 days before expiry', _expiryAlerts, (val) => setState(() => _expiryAlerts = val)),
              _toggleRow('Weekly Summary', 'Receive report every Monday', _weeklySummary, (val) => setState(() => _weeklySummary = val)),
              const Divider(height: 1, indent: 16, endIndent: 16),

              _sectionHeader('📊', 'My Stats'),
              Consumer<FoodItemsProvider>(
                builder: (context, provider, _) {
                  final consumed = provider.totalConsumed;
                  final discarded = provider.totalDiscarded;
                  final total = consumed + discarded;
                  final consumeRate = total > 0 ? (consumed / total) * 100 : 0.0;
                  final discardRate = total > 0 ? (discarded / total) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                      child: Column(
                        children: [
                          StatBar(label: 'Consumed', emoji: '🍽️', percentage: consumeRate, color: AppColors.safe),
                          StatBar(label: 'Discarded', emoji: '🗑️', percentage: discardRate, color: AppColors.expired),
                          const SizedBox(height: 8),
                          Text(
                            'Total: ${provider.totalTracked} · Consumed: $consumed · Discarded: $discarded',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, indent: 16, endIndent: 16),

              _sectionHeader('📋', 'Weekly Report'),
              _toggleRow('Enable Weekly Report', 'Sent to $email', _weeklyReport, (val) => setState(() => _weeklyReport = val)),

              // Reset Pantry button (ไม่มี confirm dialog)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: AppTheme.minTouchTarget,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<FoodItemsProvider>().resetPantry();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🗑️ Pantry has been reset', style: TextStyle(fontSize: 16))),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.expired,
                      side: const BorderSide(color: AppColors.expired, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
                    ),
                    child: const Text('🗑️ Reset Pantry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String icon, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
      );

  Widget _toggleRow(String label, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ]),
          ),
          Transform.scale(scale: 1.2, child: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.safe)),
        ]),
      ),
    );
  }
}
