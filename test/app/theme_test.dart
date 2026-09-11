import 'package:app_dcc_reports/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el tema usa la paleta institucional DCC (RF-1)', (tester) async {
    late ColorScheme colorScheme;
    late ButtonStyle? buttonStyle;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildDccTheme(),
        home: Builder(
          builder: (context) {
            colorScheme = Theme.of(context).colorScheme;
            buttonStyle = Theme.of(context).elevatedButtonTheme.style;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );

    expect(colorScheme.primary, DccColors.blue);
    expect(colorScheme.secondary, DccColors.orange);
    expect(colorScheme.surface, DccColors.white);
    expect(
      buttonStyle?.backgroundColor?.resolve({}),
      DccColors.orange,
    );
  });
}
