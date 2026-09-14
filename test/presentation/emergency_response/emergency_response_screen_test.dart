import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/finish_type.dart';
import 'package:app_dcc_reports/domain/entities/meeting_point.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/entities/participation_status.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/entities/reporter_evidence.dart';
import 'package:app_dcc_reports/domain/repositories/location_repository.dart';
import 'package:app_dcc_reports/domain/repositories/participation_repository.dart';
import 'package:app_dcc_reports/presentation/emergency_response/emergency_response_screen.dart';
import 'package:app_dcc_reports/presentation/emergency_response/meeting_point_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<({double latitude, double longitude})?> getCurrentLocation() async =>
      (latitude: 4.6, longitude: -74.1);
}

class _FakeParticipationRepository implements ParticipationRepository {
  _FakeParticipationRepository({this.myParticipation, this.meetingPoint});

  Participation? myParticipation;
  MeetingPoint? meetingPoint;
  bool goToCalled = false;
  bool arriveCalled = false;
  bool ambulanceCalled = false;

  @override
  Future<void> goTo({
    required String reportId,
    required String accountId,
    required String accountName,
    required AccountRole accountRole,
  }) async {
    goToCalled = true;
  }

  @override
  Future<void> arrive({required String reportId, required String accountId}) async {
    arriveCalled = true;
  }

  @override
  Future<void> requestAmbulance({required String reportId, required String accountId}) async {
    ambulanceCalled = true;
  }

  @override
  Future<void> finishCompleted({
    required String reportId,
    required String accountId,
    required String localPhotoPath,
    required DifficultyLevel difficultyLevel,
  }) async {}

  @override
  Future<void> finishWithdrawn({
    required String reportId,
    required String accountId,
    required String reason,
    required DifficultyLevel difficultyLevel,
  }) async {}

  @override
  Stream<Participation?> watchMyParticipation({
    required String reportId,
    required String accountId,
  }) =>
      Stream.value(myParticipation).asBroadcastStream();

  @override
  Stream<List<Participation>> watchParticipations(String reportId) =>
      Stream<List<Participation>>.value(const []).asBroadcastStream();

  @override
  Stream<MeetingPoint?> watchMeetingPoint(String reportId) => Stream.value(meetingPoint);

  @override
  Future<void> setMeetingPoint({
    required String reportId,
    required String requesterId,
    required AccountRole requesterRole,
    required double latitude,
    required double longitude,
  }) async {}
}

EmergencyReport _report() {
  return EmergencyReport(
    id: 'report-1',
    title: 'Incendio',
    address: 'Cra 68 # 24-10',
    emergencyTypeId: 'incendio',
    photoUrls: const ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
    status: ReportStatus.activa,
    reporterEvidence: const ReporterEvidence(deviceId: 'device-1'),
    createdAt: DateTime(2026, 9, 14),
  );
}

Participation _participation({required ParticipationStatus status}) {
  final arrivedAt = status != ParticipationStatus.going ? DateTime(2026, 9, 14, 10, 20) : null;
  final finished = status == ParticipationStatus.finished;
  return Participation(
    reportId: 'report-1',
    accountId: 'uid-1',
    accountName: 'Jane',
    accountRole: AccountRole.voluntario,
    status: status,
    goingAt: DateTime(2026, 9, 14, 10),
    arrivedAt: arrivedAt,
    finishedAt: finished ? DateTime(2026, 9, 14, 11) : null,
    finishType: finished ? FinishType.completed : null,
    difficultyLevel: finished ? DifficultyLevel.media : null,
    photoUrl: finished ? 'https://example.com/finish.jpg' : null,
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _FakeParticipationRepository repo, {
  List<Uri>? launchedUrls,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ParticipationRepository>.value(value: repo),
        Provider<LocationRepository>.value(value: _FakeLocationRepository()),
      ],
      child: MaterialApp(
        home: EmergencyResponseScreen(
          report: _report(),
          accountId: 'uid-1',
          accountName: 'Jane',
          accountRole: AccountRole.voluntario,
          launchUrl: (uri) async {
            launchedUrls?.add(uri);
            return true;
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('sin participación, muestra "Ir" y al tocarlo llama a goTo y abre direcciones (RF-1/RF-2)',
      (tester) async {
    final repo = _FakeParticipationRepository();
    final launched = <Uri>[];
    await _pumpScreen(tester, repo, launchedUrls: launched);
    await tester.pump();

    await tester.tap(find.byKey(const Key('go-button')));
    await tester.pumpAndSettle();

    expect(repo.goToCalled, isTrue);
    expect(launched, isNotEmpty);
  });

  testWidgets('con estado going, muestra "Ya llegué" y llama a arrive (RF-4)', (tester) async {
    final repo = _FakeParticipationRepository(
      myParticipation: _participation(status: ParticipationStatus.going),
    );
    await _pumpScreen(tester, repo);
    await tester.pump();

    await tester.tap(find.byKey(const Key('arrive-button')));
    await tester.pumpAndSettle();

    expect(repo.arriveCalled, isTrue);
  });

  testWidgets('pedir ambulancia llama al repositorio y abre tel:123 (RF-9)', (tester) async {
    final repo = _FakeParticipationRepository(
      myParticipation: _participation(status: ParticipationStatus.arrived),
    );
    final launched = <Uri>[];
    await _pumpScreen(tester, repo, launchedUrls: launched);
    await tester.pump();

    await tester.tap(find.byKey(const Key('ambulance-button')));
    await tester.pumpAndSettle();

    expect(repo.ambulanceCalled, isTrue);
    expect(launched.any((u) => u.scheme == 'tel' && u.path == '123'), isTrue);
  });

  testWidgets('con estado arrived, muestra el botón de finalizar', (tester) async {
    final repo = _FakeParticipationRepository(
      myParticipation: _participation(status: ParticipationStatus.arrived),
    );
    await _pumpScreen(tester, repo);
    await tester.pump();

    expect(find.byKey(const Key('finish-button')), findsOneWidget);
  });

  testWidgets('llegar sin punto de encuentro navega a ubicarlo (RF-5)', (tester) async {
    final repo = _FakeParticipationRepository(
      myParticipation: _participation(status: ParticipationStatus.going),
      meetingPoint: null,
    );
    await _pumpScreen(tester, repo);
    await tester.pump();

    await tester.tap(find.byKey(const Key('arrive-button')));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingPointPickerScreen), findsOneWidget);
  });

  testWidgets('llegar con un punto de encuentro ya puesto no navega (RF-6)', (tester) async {
    final repo = _FakeParticipationRepository(
      myParticipation: _participation(status: ParticipationStatus.going),
      meetingPoint: MeetingPoint(
        reportId: 'report-1',
        latitude: 4.6,
        longitude: -74.1,
        setByUid: 'other-uid',
        setByRole: AccountRole.funcionario,
        setAt: DateTime(2026, 9, 14),
      ),
    );
    await _pumpScreen(tester, repo);
    await tester.pump();

    await tester.tap(find.byKey(const Key('arrive-button')));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingPointPickerScreen), findsNothing);
  });

  testWidgets('con estado finished, no muestra ni ambulancia ni finalizar', (tester) async {
    final repo = _FakeParticipationRepository(
      myParticipation: _participation(status: ParticipationStatus.finished),
    );
    await _pumpScreen(tester, repo);
    await tester.pump();

    expect(find.byKey(const Key('ambulance-button')), findsNothing);
    expect(find.byKey(const Key('finish-button')), findsNothing);
  });
}
