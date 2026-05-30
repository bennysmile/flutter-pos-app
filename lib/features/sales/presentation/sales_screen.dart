import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import 'sales_history_providers.dart';
import 'widgets/sales_filter_bar.dart';
import 'widgets/sales_history_list.dart';
import 'widgets/sales_total_card.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(filteredSalesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                children: [
                  SalesTotalCard(),
                  SizedBox(height: 12),
                  SalesFilterBar(),
                ],
              ),
            ),
            Expanded(
              child: sales.when(
                data: (items) {
                  return SalesHistoryList(
                    sales: items,
                    onOpenDetails: (sale) {
                      context.go(AppRoutes.receiptPath(sale.id));
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _SalesError(message: error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesError extends StatelessWidget {
  const _SalesError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
