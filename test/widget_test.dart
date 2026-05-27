import 'package:flutter_test/flutter_test.dart';
import 'package:veresiyedefteri/app.dart';

void main() {
  testWidgets('App starts', (tester) async {
    await tester.pumpWidget(const VeresiyeDefteriApp());
    expect(find.text('Veresiye Defteri'), findsWidgets);
  });
}