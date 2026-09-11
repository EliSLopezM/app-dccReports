import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/entities/reporter_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

EmergencyReport _buildReport({
  ReporterEvidence? evidence,
  List<String> photoUrls = const ['url1', 'url2'],
}) {
  return EmergencyReport(
    id: 'report-1',
    title: 'Incendio en bodega',
    address: 'Cra 68 # 24-10',
    emergencyTypeId: 'incendio',
    photoUrls: photoUrls,
    status: ReportStatus.pending,
    reporterEvidence: evidence ?? const ReporterEvidence(deviceId: 'device-123'),
    createdAt: DateTime(2026, 9, 11),
  );
}

void main() {
  test('un reporte válido con nombre y teléfono se construye (RF-2/RF-5)', () {
    final report = _buildReport(
      evidence: const ReporterEvidence(
        name: 'Jane Doe',
        phone: '3001234567',
        deviceId: 'device-123',
      ),
    );

    expect(report.reporterEvidence.name, 'Jane Doe');
    expect(report.reporterEvidence.phone, '3001234567');
  });

  test('un reporte sin nombre ni teléfono también es válido (RF-5)', () {
    final report = _buildReport();

    expect(report.reporterEvidence.name, isNull);
    expect(report.reporterEvidence.phone, isNull);
    expect(report.reporterEvidence.deviceId, 'device-123');
  });

  test('el estado inicial siempre es pending (RF-6)', () {
    final report = _buildReport();

    expect(report.status, ReportStatus.pending);
  });

  test('menos de 2 fotos lanza un assertion error (RF-2/RF-3)', () {
    expect(() => _buildReport(photoUrls: const ['url1']), throwsA(isA<AssertionError>()));
  });

  test('solo activa es visible en el mapa (RF-10)', () {
    expect(ReportStatus.activa.isVisibleOnMap, isTrue);
    for (final status in [
      ReportStatus.pending,
      ReportStatus.verdadera,
      ReportStatus.falsaControlada,
      ReportStatus.enDesarrollo,
    ]) {
      expect(status.isVisibleOnMap, isFalse);
    }
  });
}
