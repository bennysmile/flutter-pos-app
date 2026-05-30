import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../reports_providers.dart';

class ReportDateFilter extends ConsumerWidget {
  const ReportDateFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reportsDateRangeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily sales summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rangeLabel(range),
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickDateRange(context, ref, range),
              icon: const Icon(Icons.date_range_outlined),
              label: const Text('Date Filter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange current,
  ) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: current,
    );

    if (range != null) {
      ref.read(reportsDateRangeProvider.notifier).state = range;
    }
  }

  String _rangeLabel(DateTimeRange range) {
    final formatter = DateFormat.yMMMd();
    if (_isSameDay(range.start, range.end)) {
      return formatter.format(range.start);
    }
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
