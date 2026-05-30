import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../sales_history_providers.dart';

class SalesFilterBar extends ConsumerWidget {
  const SalesFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(salesDateRangeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final search = TextField(
              onChanged: (value) {
                ref.read(salesSearchQueryProvider.notifier).state = value;
              },
              decoration: const InputDecoration(
                hintText: 'Search by receipt number',
                prefixIcon: Icon(Icons.search),
              ),
            );
            final dateButton = OutlinedButton.icon(
              onPressed: () => _pickDateRange(context, ref),
              icon: const Icon(Icons.date_range_outlined),
              label: Text(_dateRangeLabel(range)),
            );
            final clearButton = IconButton(
              tooltip: 'Clear date filter',
              onPressed: range == null
                  ? null
                  : () =>
                        ref.read(salesDateRangeProvider.notifier).state = null,
              icon: const Icon(Icons.close),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  search,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: dateButton),
                      clearButton,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 12),
                dateButton,
                clearButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final current = ref.read(salesDateRangeProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: current,
    );

    if (range != null) {
      ref.read(salesDateRangeProvider.notifier).state = range;
    }
  }

  String _dateRangeLabel(DateTimeRange? range) {
    if (range == null) {
      return 'Filter by date';
    }

    final formatter = DateFormat.MMMd();
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }
}
