import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bp_reading.dart';
import '../providers/bp_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bp_reading_card.dart';
import 'add_reading_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestReadingProvider);
    final stats = ref.watch(bpStatsProvider);
    final recent = ref.watch(allReadingsProvider).take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Text(
                          'Blood Pressure',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _AddButton(onTap: () => _openAddSheet(context)),
                  ],
                ),
              ),
            ),

            // ── Latest Reading Hero ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: latest == null
                    ? _EmptyState(onAdd: () => _openAddSheet(context))
                    : BpHeroGauge(reading: latest),
              ),
            ),

            // ── Quick Stats ──────────────────────────────────────────
            if (stats != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _StatTile(
                          label: 'Avg SYS',
                          value: stats.avgSystolic.toStringAsFixed(0)),
                      const SizedBox(width: 10),
                      _StatTile(
                          label: 'Avg DIA',
                          value: stats.avgDiastolic.toStringAsFixed(0)),
                      const SizedBox(width: 10),
                      if (stats.avgPulse != null)
                        _StatTile(
                            label: 'Avg Pulse',
                            value: '${stats.avgPulse!.toStringAsFixed(0)} bpm'),
                      if (stats.avgPulse == null)
                        _StatTile(label: 'Readings', value: '${stats.total}'),
                    ],
                  ),
                ),
              ),

            // ── BP Reference Guide ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _BpReferenceCard(),
              ),
            ),

            // ── Recent Readings ──────────────────────────────────────
            if (recent.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Recent Readings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final r = recent[i];
                      return BpReadingCard(
                        reading: r,
                        compact: true,
                        onTap: () => _openEditSheet(context, r),
                      );
                    },
                    childCount: recent.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddReadingSheet(),
    );
  }

  void _openEditSheet(BuildContext context, BpReading r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReadingSheet(existing: r),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      );
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: AppTheme.primary, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'No readings yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to log your first blood pressure reading.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Log First Reading'),
            ),
          ],
        ),
      );
}

class _BpReferenceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BP Reference',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          _refRow(AppTheme.info, 'Low', '< 90/60'),
          _refRow(AppTheme.good, 'Normal', '< 120/80'),
          _refRow(AppTheme.warning, 'Elevated', '120–129 / < 80'),
          _refRow(const Color(0xFFFF6B35), 'Stage 1', '130–139 / 80–89'),
          _refRow(AppTheme.danger, 'Stage 2', '≥ 140/90'),
          _refRow(const Color(0xFFFF2D55), 'Crisis', '> 180/120'),
        ],
      ),
    );
  }

  Widget _refRow(Color color, String label, String range) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(range,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                    fontFamily: 'monospace')),
          ],
        ),
      );
}
