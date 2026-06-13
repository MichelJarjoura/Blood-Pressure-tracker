import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bp_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(allReadingsProvider).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // App info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _Section(
                  title: 'About',
                  children: [
                    _SettingsTile(
                      icon: Icons.favorite_rounded,
                      iconColor: AppTheme.primary,
                      title: 'BP Tracker',
                      subtitle: 'Version 1.0.0',
                      trailing: const SizedBox.shrink(),
                    ),
                    _SettingsTile(
                      icon: Icons.analytics_outlined,
                      iconColor: AppTheme.info,
                      title: 'Total Readings',
                      subtitle: 'Stored on this device',
                      trailing: Text(
                        '$total',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BP Guidelines
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _Section(
                  title: 'BP Guidelines',
                  children: [
                    _GuideRow(AppTheme.info, 'Low', '< 90/60 mmHg'),
                    _GuideRow(AppTheme.good, 'Normal', '< 120/80 mmHg'),
                    _GuideRow(AppTheme.warning, 'Elevated',
                        'SYS 120–129 & DIA < 80'),
                    _GuideRow(const Color(0xFFFF6B35), 'High Stage 1',
                        'SYS 130–139 or DIA 80–89'),
                    _GuideRow(AppTheme.danger, 'High Stage 2',
                        'SYS ≥ 140 or DIA ≥ 90'),
                    _GuideRow(const Color(0xFFFF2D55), 'Hypertensive Crisis',
                        'SYS > 180 or DIA > 120'),
                  ],
                ),
              ),
            ),

            // Danger zone
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                child: _Section(
                  title: 'Data',
                  children: [
                    _SettingsTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: AppTheme.danger,
                      title: 'Clear All Data',
                      subtitle: 'Permanently delete all readings',
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textTertiary),
                      onTap: () => _confirmClear(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will permanently delete all blood pressure readings. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bpRepositoryProvider).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All readings deleted'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      const Divider(
                          height: 1,
                          indent: 52,
                          color: AppTheme.border),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      );
}

class _GuideRow extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  const _GuideRow(this.color, this.label, this.range);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(range,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textTertiary)),
          ],
        ),
      );
}
