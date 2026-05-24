import 'package:flutter_test/flutter_test.dart';
import 'package:ecorun/main.dart';

void main() {
  testWidgets('EcoRun app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoRunApp());
    expect(find.text('EcoRun'), findsWidgets);
  });
}
