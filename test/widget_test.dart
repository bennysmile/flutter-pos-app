import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/app/app.dart';

void main() {
  testWidgets('shows the login route first', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SimplePosApp()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
