import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/bp_reading.dart';

// ─── Hive Box Provider ───────────────────────────────────────────────────────

final bpBoxProvider = Provider<Box<BpReading>>((ref) {
  return Hive.box<BpReading>('readings');
});

// ─── Date Filter State ───────────────────────────────────────────────────────

enum DateFilter { week, month, threeMonths, year, all }

final dateFilterProvider = StateProvider<DateFilter>((ref) => DateFilter.month);

// ─── All Readings Provider ───────────────────────────────────────────────────

final allReadingsProvider = Provider<List<BpReading>>((ref) {
  final box = ref.watch(bpBoxProvider);
  // Watch for changes
  ref.watch(readingsRebuildProvider);
  return box.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
});

// Notifier to trigger rebuilds when Hive data changes
final readingsRebuildProvider = StateProvider<int>((ref) => 0);

// ─── Filtered Readings Provider ──────────────────────────────────────────────

final filteredReadingsProvider = Provider<List<BpReading>>((ref) {
  final all = ref.watch(allReadingsProvider);
  final filter = ref.watch(dateFilterProvider);
  final now = DateTime.now();

  DateTime cutoff;
  switch (filter) {
    case DateFilter.week:
      cutoff = now.subtract(const Duration(days: 7));
      break;
    case DateFilter.month:
      cutoff = now.subtract(const Duration(days: 30));
      break;
    case DateFilter.threeMonths:
      cutoff = now.subtract(const Duration(days: 90));
      break;
    case DateFilter.year:
      cutoff = now.subtract(const Duration(days: 365));
      break;
    case DateFilter.all:
      return all;
  }

  return all.where((r) => r.timestamp.isAfter(cutoff)).toList();
});

// ─── Stats Provider ───────────────────────────────────────────────────────────

class BpStats {
  final double avgSystolic;
  final double avgDiastolic;
  final double? avgPulse;
  final int? minSystolic;
  final int? maxSystolic;
  final int? minDiastolic;
  final int? maxDiastolic;
  final int total;
  final Map<BpCategory, int> categoryDistribution;

  const BpStats({
    required this.avgSystolic,
    required this.avgDiastolic,
    this.avgPulse,
    this.minSystolic,
    this.maxSystolic,
    this.minDiastolic,
    this.maxDiastolic,
    required this.total,
    required this.categoryDistribution,
  });
}

final bpStatsProvider = Provider<BpStats?>((ref) {
  final readings = ref.watch(filteredReadingsProvider);
  if (readings.isEmpty) return null;

  final systolics = readings.map((r) => r.systolic).toList();
  final diastolics = readings.map((r) => r.diastolic).toList();
  final pulses = readings.where((r) => r.pulse != null).map((r) => r.pulse!).toList();

  final distribution = <BpCategory, int>{};
  for (final r in readings) {
    distribution[r.category] = (distribution[r.category] ?? 0) + 1;
  }

  return BpStats(
    avgSystolic: systolics.reduce((a, b) => a + b) / systolics.length,
    avgDiastolic: diastolics.reduce((a, b) => a + b) / diastolics.length,
    avgPulse: pulses.isEmpty
        ? null
        : pulses.reduce((a, b) => a + b) / pulses.length,
    minSystolic: systolics.reduce((a, b) => a < b ? a : b),
    maxSystolic: systolics.reduce((a, b) => a > b ? a : b),
    minDiastolic: diastolics.reduce((a, b) => a < b ? a : b),
    maxDiastolic: diastolics.reduce((a, b) => a > b ? a : b),
    total: readings.length,
    categoryDistribution: distribution,
  );
});

// ─── Most Recent Reading ──────────────────────────────────────────────────────

final latestReadingProvider = Provider<BpReading?>((ref) {
  final readings = ref.watch(allReadingsProvider);
  return readings.isEmpty ? null : readings.first;
});

// ─── Repository (actions) ─────────────────────────────────────────────────────

class BpRepository {
  final Box<BpReading> _box;
  final StateController<int> _rebuilder;

  BpRepository(this._box, this._rebuilder);

  Future<void> addReading(BpReading reading) async {
    await _box.add(reading);
    _rebuilder.state++;
  }

  Future<void> updateReading(int index, BpReading reading) async {
    await _box.putAt(index, reading);
    _rebuilder.state++;
  }

  Future<void> deleteReading(BpReading reading) async {
    await reading.delete();
    _rebuilder.state++;
  }

  Future<void> clearAll() async {
    await _box.clear();
    _rebuilder.state++;
  }
}

final bpRepositoryProvider = Provider<BpRepository>((ref) {
  final box = ref.watch(bpBoxProvider);
  final rebuilder = ref.read(readingsRebuildProvider.notifier);
  return BpRepository(box, rebuilder);
});
