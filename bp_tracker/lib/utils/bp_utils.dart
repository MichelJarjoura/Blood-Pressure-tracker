import 'package:flutter/material.dart';
import '../models/bp_reading.dart';
import '../theme/app_theme.dart';

Color categoryColor(BpCategory cat) {
  switch (cat) {
    case BpCategory.low:
      return AppTheme.info;
    case BpCategory.normal:
      return AppTheme.good;
    case BpCategory.elevated:
      return AppTheme.warning;
    case BpCategory.highStage1:
      return const Color(0xFFFF6B35);
    case BpCategory.highStage2:
      return AppTheme.danger;
    case BpCategory.crisis:
      return const Color(0xFFFF2D55);
  }
}

IconData categoryIcon(BpCategory cat) {
  switch (cat) {
    case BpCategory.low:
      return Icons.arrow_downward_rounded;
    case BpCategory.normal:
      return Icons.check_circle_rounded;
    case BpCategory.elevated:
      return Icons.arrow_upward_rounded;
    case BpCategory.highStage1:
      return Icons.warning_amber_rounded;
    case BpCategory.highStage2:
      return Icons.warning_rounded;
    case BpCategory.crisis:
      return Icons.emergency_rounded;
  }
}

String formatBp(BpReading r) => '${r.systolic}/${r.diastolic}';

String formatTimestamp(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  return '${dt.day}/${dt.month}/${dt.year}';
}

String formatFullDate(DateTime dt) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  final min = dt.minute.toString().padLeft(2, '0');
  return '${months[dt.month]} ${dt.day}, ${dt.year}  $hour:$min $amPm';
}
