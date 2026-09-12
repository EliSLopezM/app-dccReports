import 'package:app_dcc_reports/presentation/map/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sin API key configurada, muestra el placeholder (RF-7)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MapView(
          center: (latitude: 4.65, longitude: -74.06),
          markers: [],
          mapsConfigured: false,
        ),
      ),
    );

    expect(find.textContaining('El mapa se activará'), findsOneWidget);
  });
}
