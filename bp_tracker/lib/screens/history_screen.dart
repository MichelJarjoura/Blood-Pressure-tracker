import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bp_reading.dart';
import '../providers/bp_provider.dart';
import '../theme/app_theme.dart';
import '../utils/bp_utils.dart';
import '../widgets/bp_reading_card.dart';
import 'add_reading_sheet.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _search = '';
  BpCategory? _filterCat;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allReadingsProvider);
    ref.watch(dateFilterProvider);

    // Apply search + category filter
    final displayed = all.where((r) {
      if (_filterCat != null && r.category != _filterCat) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!r.systolic.toString().contains(q) &&
            !r.diastolic.toString().contains(q) &&
            !(r.note?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${displayed.length} readings',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style:
                    const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search readings…',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppTheme.textTertiary, size: 20),
                ),
              ),
            ),

            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filterCat == null,
                    color: AppTheme.primary,
                    onTap: () => setState(() => _filterCat = null),
                  ),
                  const SizedBox(width: 8),
                  ...BpCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: cat.label,
                          selected: _filterCat == cat,
                          color: categoryColor(cat),
                          onTap: () => setState(() =>
                              _filterCat = _filterCat == cat ? null : cat),
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List
            Expanded(
              child: displayed.isEmpty
                  ? const Center(
                      child: Text(
                        'No readings found',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                      itemCount: displayed.length,
                      itemBuilder: (context, i) {
                        final r = displayed[i];
                        return Dismissible(
                          key: ValueKey(r.timestamp),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: AppTheme.danger),
                          ),
                          confirmDismiss: (_) async {
                            return await _confirmDelete(context);
                          },
                          onDismissed: (_) {
                            ref.read(bpRepositoryProvider).deleteReading(r);
                          },
                          child: BpReadingCard(
                            reading: r,
                            onTap: () => _openEdit(context, r),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: const Text('Delete Reading',
                style: TextStyle(color: AppTheme.textPrimary)),
            content: const Text('This reading will be permanently deleted.',
                style: TextStyle(color: AppTheme.textSecondary)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
  }

  void _openEdit(BuildContext context, BpReading r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReadingSheet(existing: r),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? color : AppTheme.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      );
}
