import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/entities/reporter_evidence.dart';
import 'package:app_dcc_reports/domain/repositories/emergency_report_repository.dart';
import 'package:app_dcc_reports/presentation/map/emergency_detail_screen.dart';
import 'package:app_dcc_reports/presentation/map/map_screen.dart';
import 'package:app_dcc_reports/presentation/map/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeEmergencyReportRepository implements EmergencyReportRepository {
  _FakeEmergencyReportRepository(this.reports);

  final List<EmergencyReport> reports;
  final List<DateTime> sinceCalls = [];

  @override
  Stream<List<EmergencyReport>> watchActiveReports({required DateTime since}) {
    sinceCalls.add(since);
    return Stream.value(reports);
  }

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

EmergencyReport _activeReport({double? latitude, double? longitude}) {
  return EmergencyReport(
    id: 'report-1',
    title: 'Incendio',
    address: 'Cra 68 # 24-10',
    emergencyTypeId: 'incendio',
    photoUrls: const ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
    status: ReportStatus.activa,
    reporterEvidence: const ReporterEvidence(deviceId: 'device-1'),
    createdAt: DateTime(2026, 9, 11),
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  testWidgets('sin reportes activos, muestra el estado vacío', (tester) async {
    final repo = _FakeEmergencyReportRepository(const []);

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: const MaterialApp(home: MapScreen()),
      ),
    );

    expect(find.byKey(const Key('map-empty-state')), findsOneWidget);
  });

  testWidgets('con un reporte con ubicación, arma un marcador (RF-1)', (tester) async {
    final repo = _FakeEmergencyReportRepository([_activeReport(latitude: 4.6, longitude: -74.1)]);

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: const MaterialApp(home: MapScreen()),
      ),
    );
    await tester.pump();

    final mapView = tester.widget<MapView>(find.byType(MapView));
    expect(mapView.markers, hasLength(1));
    expect(mapView.markers.single.id, 'report-1');
  });

  testWidgets('un reporte sin ubicación no genera marcador', (tester) async {
    final repo = _FakeEmergencyReportRepository([_activeReport()]);

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: const MaterialApp(home: MapScreen()),
      ),
    );
    await tester.pump();

    final mapView = tester.widget<MapView>(find.byType(MapView));
    expect(mapView.markers, isEmpty);
  });

  testWidgets('tocar el marcador navega al detalle con recomendaciones (RF-3)', (tester) async {
    final repo = _FakeEmergencyReportRepository([_activeReport(latitude: 4.6, longitude: -74.1)]);

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: const MaterialApp(home: MapScreen()),
      ),
    );
    await tester.pump();

    final mapView = tester.widget<MapView>(find.byType(MapView));
    mapView.markers.single.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(EmergencyDetailScreen), findsOneWidget);
  });

  testWidgets('cambiar el filtro de fecha vuelve a consultar con un rango distinto (RF-2)',
      (tester) async {
    final repo = _FakeEmergencyReportRepository(const []);

    await tester.pumpWidget(
      Provider<EmergencyReportRepository>.value(
        value: repo,
        child: const MaterialApp(home: MapScreen()),
      ),
    );

    final firstSince = repo.sinceCalls.single;

    await tester.tap(find.byKey(const Key('date-filter-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Último año'));
    await tester.pumpAndSettle();

    expect(repo.sinceCalls.length, 2);
    expect(repo.sinceCalls.last.isBefore(firstSince), isTrue);
  });
}
