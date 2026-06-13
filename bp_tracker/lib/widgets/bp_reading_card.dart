import 'package:flutter/material.dart';
import '../models/bp_reading.dart';
import '../theme/app_theme.dart';
import '../utils/bp_utils.dart';

class BpReadingCard extends StatelessWidget {
  final BpReading reading;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool compact;

  const BpReadingCard({
    super.key,
    required this.reading,
    this.onTap,
    this.onDelete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(reading.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(compact ? 14 : 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Category indicator
            Container(
              width: 4,
              height: compact ? 40 : 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            // BP values
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${reading.systolic}',
                        style: TextStyle(
                          fontSize: compact ? 22 : 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1,
                        ),
                      ),
                      Text(
                        '/',
                        style: TextStyle(
                          fontSize: compact ? 16 : 20,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        '${reading.diastolic}',
                        style: TextStyle(
                          fontSize: compact ? 22 : 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'mmHg',
                        style: TextStyle(
                          fontSize: compact ? 11 : 12,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reading.category.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (reading.pulse != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.favorite_rounded,
                                size: 11,
                                color: AppTheme.primary.withOpacity(0.7)),
                            const SizedBox(width: 3),
                            Text(
                              '${reading.pulse} bpm',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Timestamp + delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTimestamp(reading.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
                if (reading.note != null && reading.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const Icon(Icons.notes_rounded,
                      size: 14, color: AppTheme.textTertiary),
                ],
                if (onDelete != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: AppTheme.textTertiary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Large hero gauge shown on dashboard ─────────────────────────────────────

class BpHeroGauge extends StatelessWidget {
  final BpReading reading;

  const BpHeroGauge({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(reading.category);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${reading.systolic}',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '/',
                  style: TextStyle(
                    fontSize: 40,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Text(
                '${reading.diastolic}',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'mmHg',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
              letterSpacing: 2,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoryIcon(reading.category), color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  reading.category.label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (reading.pulse != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_rounded,
                    size: 14, color: AppTheme.primary.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  '${reading.pulse} bpm',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            formatFullDate(reading.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
