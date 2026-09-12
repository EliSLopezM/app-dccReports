import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/entities/reporter_evidence.dart';
import 'package:app_dcc_reports/domain/repositories/emergency_report_repository.dart';
import 'package:app_dcc_reports/presentation/notifications/active_reports_bell.dart';
import 'package:app_dcc_reports/presentation/notifications/active_reports_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeEmergencyReportRepository implements EmergencyReportRepository {
  _FakeEmergencyReportRepository(this.reports);

  final List<EmergencyReport> reports;

  @override
  Stream<List<EmergencyReport>> watchActiveReports({required DateTime since}) =>
      Stream.value(reports);

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
  Future<void> updateStatus({
    required String reviewerId,
    required String reportId,
    required ReportStatus newStatus,
  }) async {}
}

EmergencyReport _activeReport(String id) {
  return EmergencyReport(
    id: id,
    title: 'Emergencia $id',
    address: 'Dirección $id',
    emergencyTypeId: 'incendio',
    photoUrls: const ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
    status: ReportStatus.activa,
    reporterEvidence: const ReporterEvidence(deviceId: 'device-1'),
    createdAt: DateTime(2026, 9, 11),
  );
}

void main() {
  testWidgets('muestra el conteo correcto de activas (RF-5)', (tester) async {
    final repo = _FakeEmergencyReportRepository([_activeReport('r1'), _activeReport('r2')]);

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: MaterialApp(home: Scaffold(appBar: AppBar(actions: const [ActiveReportsBell()]))),
      ),
    );
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('tocar la campana abre la lista de activas (RF-6)', (tester) async {
    final repo = _FakeEmergencyReportRepository([_activeReport('r1')]);

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: MaterialApp(home: Scaffold(appBar: AppBar(actions: const [ActiveReportsBell()]))),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('active-reports-bell')));
    await tester.pumpAndSettle();

    expect(find.byType(ActiveReportsListScreen), findsOneWidget);
    expect(find.text('Emergencia r1'), findsOneWidget);
  });
}
