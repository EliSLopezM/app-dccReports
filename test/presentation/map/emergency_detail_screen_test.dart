import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/entities/reporter_evidence.dart';
import 'package:app_dcc_reports/presentation/map/emergency_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

EmergencyReport _report({required String emergencyTypeId}) {
  return EmergencyReport(
    id: 'report-1',
    title: 'Emergencia',
    address: 'Cra 68 # 24-10',
    emergencyTypeId: emergencyTypeId,
    photoUrls: const ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
    status: ReportStatus.activa,
    reporterEvidence: const ReporterEvidence(deviceId: 'device-123'),
    createdAt: DateTime(2026, 9, 11),
  );
}

void main() {
  testWidgets('muestra las recomendaciones de incendio (RF-3/RF-4)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EmergencyDetailScreen(report: _report(emergencyTypeId: 'incendio'))),
    );

    expect(find.textContaining('Aléjate del fuego'), findsOneWidget);
  });

  testWidgets('muestra recomendaciones distintas para inundación (RF-4)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EmergencyDetailScreen(report: _report(emergencyTypeId: 'inundacion'))),
    );

    expect(find.textContaining('agua en movimiento'), findsOneWidget);
    expect(find.textContaining('Aléjate del fuego'), findsNothing);
  });
}
