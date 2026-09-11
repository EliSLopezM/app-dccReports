import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/repositories/emergency_report_repository.dart';
import 'package:app_dcc_reports/presentation/report/public_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeEmergencyReportRepository implements EmergencyReportRepository {
  String? lastTitle;
  String? lastReporterName;
  String? lastReporterPhone;
  List<String>? lastPhotoPaths;

  @override
  Future<String> submit({
    required String title,
    required String address,
    required String emergencyTypeId,
    required List<String> localPhotoPaths,
    String? reporterName,
    String? reporterPhone,
    required String deviceId,
  }) async {
    lastTitle = title;
    lastReporterName = reporterName;
    lastReporterPhone = reporterPhone;
    lastPhotoPaths = localPhotoPaths;
    return 'fake-report-id';
  }

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

Future<void> _pumpScreen(
  WidgetTester tester,
  _FakeEmergencyReportRepository repo, {
  PickImage? pickImage,
}) {
  return tester.pumpWidget(
    Provider<EmergencyReportRepository>.value(
      value: repo,
      child: MaterialApp(
        home: PublicReportScreen(pickImage: pickImage ?? (source) async => null),
      ),
    ),
  );
}

Future<void> _addTwoPhotos(WidgetTester tester) async {
  await tester.tap(find.text('Agregar foto'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Elegir de la galería'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Agregar foto'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Elegir de la galería'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('envío válido con 2 fotos llega al repositorio y muestra confirmación (RF-1/RF-2)',
      (tester) async {
    final repo = _FakeEmergencyReportRepository();
    var callCount = 0;
    await _pumpScreen(
      tester,
      repo,
      pickImage: (source) async {
        callCount++;
        return '/tmp/photo$callCount.jpg';
      },
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Título del reporte'), 'Incendio');
    await tester.enterText(find.widgetWithText(TextFormField, 'Dirección'), 'Cra 68 # 24-10');
    await _addTwoPhotos(tester);

    final submitButton = find.widgetWithText(ElevatedButton, 'Enviar reporte', skipOffstage: false);
    await tester.dragUntilVisible(submitButton, find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repo.lastTitle, 'Incendio');
    expect(repo.lastPhotoPaths, hasLength(2));
    expect(find.byKey(const Key('report-submitted-message')), findsOneWidget);
  });

  testWidgets('con menos de 2 fotos se bloquea el envío (RF-3)', (tester) async {
    final repo = _FakeEmergencyReportRepository();
    await _pumpScreen(
      tester,
      repo,
      pickImage: (source) async => '/tmp/single.jpg',
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Título del reporte'), 'Incendio');
    await tester.enterText(find.widgetWithText(TextFormField, 'Dirección'), 'Cra 68 # 24-10');
    await tester.tap(find.text('Agregar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elegir de la galería'));
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(ElevatedButton, 'Enviar reporte', skipOffstage: false);
    await tester.dragUntilVisible(submitButton, find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('report-error'), skipOffstage: false), findsOneWidget);
    expect(repo.lastTitle, isNull);
  });

  testWidgets('campos vacíos bloquean el envío (RF-3)', (tester) async {
    final repo = _FakeEmergencyReportRepository();
    await _pumpScreen(tester, repo);

    final submitButton = find.widgetWithText(ElevatedButton, 'Enviar reporte', skipOffstage: false);
    await tester.dragUntilVisible(submitButton, find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repo.lastTitle, isNull);
  });

  testWidgets('sin nombre ni teléfono no bloquea el envío (RF-5)', (tester) async {
    final repo = _FakeEmergencyReportRepository();
    var callCount = 0;
    await _pumpScreen(
      tester,
      repo,
      pickImage: (source) async {
        callCount++;
        return '/tmp/photo$callCount.jpg';
      },
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Título del reporte'), 'Incendio');
    await tester.enterText(find.widgetWithText(TextFormField, 'Dirección'), 'Cra 68 # 24-10');
    await _addTwoPhotos(tester);

    final submitButton = find.widgetWithText(ElevatedButton, 'Enviar reporte', skipOffstage: false);
    await tester.dragUntilVisible(submitButton, find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repo.lastReporterName, isNull);
    expect(repo.lastReporterPhone, isNull);
    expect(find.byKey(const Key('report-submitted-message')), findsOneWidget);
  });
}
