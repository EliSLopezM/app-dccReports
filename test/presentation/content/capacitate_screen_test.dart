import 'package:app_dcc_reports/presentation/content/capacitate_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('con URL configurada, tocar "Postúlate" abre el formulario (RF-5)', (tester) async {
    final launched = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: CapacitateScreen(
          formUrl: 'https://forms.gle/ejemplo',
          launchUrl: (uri) async {
            launched.add(uri);
            return true;
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('capacitate-apply-button')), findsOneWidget);
    expect(find.byKey(const Key('capacitate-unavailable-message')), findsNothing);

    await tester.tap(find.byKey(const Key('capacitate-apply-button')));
    await tester.pumpAndSettle();

    expect(launched, [Uri.parse('https://forms.gle/ejemplo')]);
  });

  testWidgets('sin URL configurada, muestra el mensaje de no disponible (RF-6)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CapacitateScreen(formUrl: '', launchUrl: (_) async => true)),
    );
    await tester.pump();

    expect(find.byKey(const Key('capacitate-unavailable-message')), findsOneWidget);
    expect(find.byKey(const Key('capacitate-apply-button')), findsNothing);
  });
}
