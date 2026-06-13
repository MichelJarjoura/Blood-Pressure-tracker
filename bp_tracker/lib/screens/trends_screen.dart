import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bp_reading.dart';
import '../providers/bp_provider.dart';
import '../theme/app_theme.dart';
import '../utils/bp_utils.dart';

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dateFilterProvider);
    final readings = ref.watch(filteredReadingsProvider);
    final stats = ref.watch(bpStatsProvider);

    // Reverse so oldest → newest left-to-right
    final chartData = readings.reversed.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header + filter row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trends',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DateFilterRow(
                      current: filter,
                      onChanged: (f) =>
                          ref.read(dateFilterProvider.notifier).state = f,
                    ),
                  ],
                ),
              ),
            ),

            if (readings.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No data for selected period',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else ...[
              // Line chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _BpLineChart(readings: chartData),
                ),
              ),

              // Stats cards
              if (stats != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _StatsGrid(stats: stats),
                  ),
                ),

              // Category distribution bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _CategoryDistribution(stats: stats),
                ),
              ),

              // Min/max range
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                  child: _MinMaxCard(stats: stats),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Date Filter Row ──────────────────────────────────────────────────────────

class _DateFilterRow extends StatelessWidget {
  final DateFilter current;
  final ValueChanged<DateFilter> onChanged;

  const _DateFilterRow({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const filters = [
      (DateFilter.week, '7D'),
      (DateFilter.month, '30D'),
      (DateFilter.threeMonths, '90D'),
      (DateFilter.year, '1Y'),
      (DateFilter.all, 'All'),
    ];

    return Row(
      children: filters.map((f) {
        final selected = current == f.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border),
              ),
              child: Text(
                f.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Line Chart ───────────────────────────────────────────────────────────────

class _BpLineChart extends StatelessWidget {
  final List<BpReading> readings;

  const _BpLineChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    final sysSpots = readings.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.systolic.toDouble());
    }).toList();

    final diaSpots = readings.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.diastolic.toDouble());
    }).toList();

    // Find y-axis range
    final allVals = readings
        .expand((r) => [r.systolic.toDouble(), r.diastolic.toDouble()])
        .toList();
    final minY = (allVals.reduce((a, b) => a < b ? a : b) - 10)
        .clamp(40.0, 200.0);
    final maxY = (allVals.reduce((a, b) => a > b ? a : b) + 10)
        .clamp(60.0, 240.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                const Text('BP Over Time',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                _LegendDot(color: AppTheme.primary, label: 'SYS'),
                const SizedBox(width: 12),
                _LegendDot(color: AppTheme.info, label: 'DIA'),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: AppTheme.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: readings.length <= 10,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= readings.length) {
                          return const SizedBox.shrink();
                        }
                        final d = readings[idx].timestamp;
                        return Text(
                          '${d.month}/${d.day}',
                          style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.textTertiary),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  // Systolic
                  LineChartBarData(
                    spots: sysSpots,
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: readings.length <= 15,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppTheme.primary,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withOpacity(0.08),
                    ),
                  ),
                  // Diastolic
                  LineChartBarData(
                    spots: diaSpots,
                    isCurved: true,
                    color: AppTheme.info,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: readings.length <= 15,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppTheme.info,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.info.withOpacity(0.05),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surfaceElevated,
                    getTooltipItems: (spots) => spots.map((s) {
                      final label = s.barIndex == 0 ? 'SYS' : 'DIA';
                      final color = s.barIndex == 0
                          ? AppTheme.primary
                          : AppTheme.info;
                      return LineTooltipItem(
                        '$label: ${s.y.toInt()}',
                        TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      );
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final BpStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        _GridCard(
            label: 'Avg Systolic',
            value: stats.avgSystolic.toStringAsFixed(1)),
        _GridCard(
            label: 'Avg Diastolic',
            value: stats.avgDiastolic.toStringAsFixed(1)),
        if (stats.avgPulse != null)
          _GridCard(
              label: 'Avg Pulse',
              value: '${stats.avgPulse!.toStringAsFixed(0)} bpm'),
        _GridCard(label: 'Total Readings', value: '${stats.total}'),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final String label;
  final String value;
  const _GridCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

// ─── Category distribution ────────────────────────────────────────────────────

class _CategoryDistribution extends StatelessWidget {
  final BpStats? stats;
  const _CategoryDistribution({this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null || stats!.total == 0) return const SizedBox.shrink();

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
          const Text('Category Breakdown',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          ...BpCategory.values.map((cat) {
            final count = stats!.categoryDistribution[cat] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            final pct = count / stats!.total;
            final color = categoryColor(cat);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(cat.label,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                      const Spacer(),
                      Text('$count (${(pct * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Min/Max card ─────────────────────────────────────────────────────────────

class _MinMaxCard extends StatelessWidget {
  final BpStats? stats;
  const _MinMaxCard({this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) return const SizedBox.shrink();

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
          const Text('Range',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RangeItem(
                    label: 'Min SYS',
                    value: '${stats!.minSystolic}',
                    color: AppTheme.good),
              ),
              Expanded(
                child: _RangeItem(
                    label: 'Max SYS',
                    value: '${stats!.maxSystolic}',
                    color: AppTheme.danger),
              ),
              Expanded(
                child: _RangeItem(
                    label: 'Min DIA',
                    value: '${stats!.minDiastolic}',
                    color: AppTheme.good),
              ),
              Expanded(
                child: _RangeItem(
                    label: 'Max DIA',
                    value: '${stats!.maxDiastolic}',
                    color: AppTheme.danger),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _RangeItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RangeItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textTertiary)),
        ],
      );
}
