import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/entities/reporter_evidence.dart';
import 'package:app_dcc_reports/domain/repositories/emergency_report_repository.dart';
import 'package:app_dcc_reports/presentation/panel/report_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeEmergencyReportRepository implements EmergencyReportRepository {
  ReportStatus? lastStatus;

  @override
  Future<String> submit({
    required String title,
    required String address,
    required String emergencyTypeId,
    required List<String> localPhotoPaths,
    String? reporterName,
    String? reporterPhone,
    required String deviceId,
    double? latitude,
    double? longitude,
  }) async =>
      'id';

  @override
  Stream<List<EmergencyReport>> watchAllReports() => Stream.value(const []);

  @override
  Stream<List<EmergencyReport>> watchReportsByDevice(String deviceId) => Stream.value(const []);

  @override
  Stream<List<EmergencyReport>> watchReportsByPhone(String phone) => Stream.value(const []);

  @override
  Stream<List<EmergencyReport>> watchActiveReports({required DateTime since}) =>
      Stream.value(const []);

  @override
  Future<void> updateStatus({
    required String reviewerId,
    required String reportId,
    required ReportStatus newStatus,
  }) async {
    lastStatus = newStatus;
  }
}

EmergencyReport _report({ReporterEvidence? evidence}) {
  return EmergencyReport(
    id: 'report-1',
    title: 'Incendio en bodega',
    address: 'Cra 68 # 24-10',
    emergencyTypeId: 'incendio',
    photoUrls: const ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
    status: ReportStatus.pending,
    reporterEvidence: evidence ??
        const ReporterEvidence(name: 'Jane Doe', phone: '3001234567', deviceId: 'device-123'),
    createdAt: DateTime(2026, 9, 11),
  );
}

void main() {
  testWidgets('muestra la evidencia del reportante (RF-8/RF-11)', (tester) async {
    final repo = _FakeEmergencyReportRepository();

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: MaterialApp(
          home: ReportDetailScreen(report: _report(), reviewerId: 'reviewer-1'),
        ),
      ),
    );

    expect(find.textContaining('Jane Doe'), findsOneWidget);
    expect(find.textContaining('3001234567'), findsOneWidget);
    expect(find.textContaining('device-123'), findsOneWidget);
  });

  testWidgets('tocar "Activa" llama a updateStatus con ese estado (RF-9)', (tester) async {
    final repo = _FakeEmergencyReportRepository();

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: MaterialApp(
          home: ReportDetailScreen(report: _report(), reviewerId: 'reviewer-1'),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Activa'));
    await tester.pumpAndSettle();

    expect(repo.lastStatus, ReportStatus.activa);
  });

  testWidgets('sin teléfono no muestra el botón de historial por teléfono', (tester) async {
    final repo = _FakeEmergencyReportRepository();

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: MaterialApp(
          home: ReportDetailScreen(
            report: _report(evidence: const ReporterEvidence(deviceId: 'device-123')),
            reviewerId: 'reviewer-1',
          ),
        ),
      ),
    );

    expect(find.text('Ver historial por teléfono'), findsNothing);
    expect(find.text('Ver historial por dispositivo'), findsOneWidget);
  });
}
