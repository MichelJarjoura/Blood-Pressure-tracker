import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bp_reading.dart';
import '../providers/bp_provider.dart';
import '../theme/app_theme.dart';
import '../utils/bp_utils.dart';

class AddReadingSheet extends ConsumerStatefulWidget {
  final BpReading? existing; // non-null = edit mode

  const AddReadingSheet({super.key, this.existing});

  @override
  ConsumerState<AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends ConsumerState<AddReadingSheet> {
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _selectedArm;
  String? _selectedPosition;
  DateTime _timestamp = DateTime.now();
  bool _saving = false;

  // Live preview
  int get _sys => int.tryParse(_systolicCtrl.text) ?? 0;
  int get _dia => int.tryParse(_diastolicCtrl.text) ?? 0;

  BpCategory? get _previewCategory {
    if (_sys == 0 || _dia == 0) return null;
    final r = BpReading(
        systolic: _sys, diastolic: _dia, timestamp: _timestamp);
    return r.category;
  }

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _systolicCtrl.text = e.systolic.toString();
      _diastolicCtrl.text = e.diastolic.toString();
      _pulseCtrl.text = e.pulse?.toString() ?? '';
      _noteCtrl.text = e.note ?? '';
      _selectedArm = e.arm;
      _selectedPosition = e.bodyPosition;
      _timestamp = e.timestamp;
    }
    _systolicCtrl.addListener(() => setState(() {}));
    _diastolicCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _pulseCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sys = int.tryParse(_systolicCtrl.text);
    final dia = int.tryParse(_diastolicCtrl.text);
    if (sys == null || dia == null) return;
    if (sys < 50 || sys > 300 || dia < 30 || dia > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid BP values')),
      );
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(bpRepositoryProvider);
    final reading = BpReading(
      systolic: sys,
      diastolic: dia,
      pulse: int.tryParse(_pulseCtrl.text),
      timestamp: _timestamp,
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
      arm: _selectedArm,
      bodyPosition: _selectedPosition,
    );

    if (widget.existing != null) {
      final box = ref.read(bpBoxProvider);
      final idx = box.values.toList().indexOf(widget.existing!);
      if (idx >= 0) await repo.updateReading(idx, reading);
    } else {
      await repo.addReading(reading);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() {
      _timestamp = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = _previewCategory;
    final catColor = cat != null ? categoryColor(cat) : AppTheme.textTertiary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.existing != null ? 'Edit Reading' : 'New Reading',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Live category preview
            if (cat != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: catColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(categoryIcon(cat), color: catColor, size: 18),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.label,
                            style: TextStyle(
                                color: catColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        Text(cat.description,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    )
                  ],
                ),
              ),

            // Systolic / Diastolic
            Row(
              children: [
                Expanded(
                  child: _BpField(
                    controller: _systolicCtrl,
                    label: 'Systolic',
                    hint: '120',
                    suffix: 'SYS',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BpField(
                    controller: _diastolicCtrl,
                    label: 'Diastolic',
                    hint: '80',
                    suffix: 'DIA',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pulse
            _BpField(
              controller: _pulseCtrl,
              label: 'Pulse (optional)',
              hint: '72',
              suffix: 'BPM',
            ),
            const SizedBox(height: 12),

            // Arm selector
            _SectionLabel('Arm'),
            const SizedBox(height: 8),
            Row(
              children: [
                _ChoiceChip(
                    label: 'Left',
                    selected: _selectedArm == 'left',
                    onTap: () =>
                        setState(() => _selectedArm = _selectedArm == 'left' ? null : 'left')),
                const SizedBox(width: 8),
                _ChoiceChip(
                    label: 'Right',
                    selected: _selectedArm == 'right',
                    onTap: () => setState(
                        () => _selectedArm = _selectedArm == 'right' ? null : 'right')),
              ],
            ),
            const SizedBox(height: 12),

            // Position selector
            _SectionLabel('Body Position'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Sitting', 'Lying', 'Standing'].map((p) {
                final key = p.toLowerCase();
                return _ChoiceChip(
                  label: p,
                  selected: _selectedPosition == key,
                  onTap: () => setState(() =>
                      _selectedPosition = _selectedPosition == key ? null : key),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Note
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. After exercise, stressed…',
              ),
            ),
            const SizedBox(height: 12),

            // Date/time picker
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      formatFullDate(_timestamp),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppTheme.textTertiary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(widget.existing != null
                        ? 'Update Reading'
                        : 'Save Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BpField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String suffix;

  const _BpField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        suffixStyle: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textTertiary,
            letterSpacing: 0.5),
      );
}
