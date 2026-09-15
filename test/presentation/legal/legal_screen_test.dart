import 'dart:async';
import 'dart:typed_data';

import 'package:app_dcc_reports/presentation/legal/legal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el título y el cuerpo del texto legal (RF-1)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LegalScreen(
          title: 'Título de prueba',
          body: 'Cuerpo de prueba',
          generatePdf: (title, body) async => Uint8List(0),
          sharePdf: (bytes, filename) async {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('legal-title')), findsOneWidget);
    expect(find.text('Título de prueba'), findsWidgets);
    expect(find.byKey(const Key('legal-body')), findsOneWidget);
    expect(find.text('Cuerpo de prueba'), findsOneWidget);
  });

  testWidgets('tocar "Descargar PDF" genera y comparte el PDF con el título/cuerpo correctos (RF-2)',
      (tester) async {
    String? generatedTitle;
    String? generatedBody;
    Uint8List? sharedBytes;
    String? sharedFilename;
    final fakeBytes = Uint8List.fromList([1, 2, 3]);

    await tester.pumpWidget(
      MaterialApp(
        home: LegalScreen(
          title: 'Título',
          body: 'Cuerpo',
          generatePdf: (title, body) async {
            generatedTitle = title;
            generatedBody = body;
            return fakeBytes;
          },
          sharePdf: (bytes, filename) async {
            sharedBytes = bytes;
            sharedFilename = filename;
          },
        ),
      ),
    );
    await tester.pump();

    final button = find.byKey(const Key('download-pdf-button'));
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(generatedTitle, 'Título');
    expect(generatedBody, 'Cuerpo');
    expect(sharedBytes, fakeBytes);
    expect(sharedFilename, 'politicas-y-terminos-dcc.pdf');
  });

  testWidgets('el botón se deshabilita mientras genera y vuelve a habilitarse al terminar', (tester) async {
    final completer = Completer<Uint8List>();
    await tester.pumpWidget(
      MaterialApp(
        home: LegalScreen(
          title: 'Título',
          body: 'Cuerpo',
          generatePdf: (title, body) => completer.future,
          sharePdf: (bytes, filename) async {},
        ),
      ),
    );
    await tester.pump();

    final button = find.byKey(const Key('download-pdf-button'));
    await tester.tap(button);
    await tester.pump();

    // generatePdf todavía no resuelve (completer pendiente): el botón
    // debe seguir deshabilitado en este frame intermedio.
    final buttonDuring = tester.widget<ElevatedButton>(button);
    expect(buttonDuring.onPressed, isNull);

    completer.complete(Uint8List(0));
    await tester.pumpAndSettle();

    final buttonAfter = tester.widget<ElevatedButton>(button);
    expect(buttonAfter.onPressed, isNotNull);
  });
}
