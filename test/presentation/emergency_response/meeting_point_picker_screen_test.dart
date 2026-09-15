import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/meeting_point.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:app_dcc_reports/domain/repositories/location_repository.dart';
import 'package:app_dcc_reports/domain/repositories/participation_repository.dart';
import 'package:app_dcc_reports/presentation/emergency_response/meeting_point_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository({this.result});

  final ({double latitude, double longitude})? result;

  @override
  Future<({double latitude, double longitude})?> getCurrentLocation() async =>
      result;
}

class _FakeParticipationRepository implements ParticipationRepository {
  _FakeParticipationRepository({this.shouldBlock = false});

  final bool shouldBlock;
  double? lastLatitude;
  double? lastLongitude;

  @override
  Future<void> setMeetingPoint({
    required String reportId,
    required String requesterId,
    required AccountRole requesterRole,
    required double latitude,
    required double longitude,
  }) async {
    if (shouldBlock) throw MeetingPointBlockedException();
    lastLatitude = latitude;
    lastLongitude = longitude;
  }

  @override
  Future<void> goTo({
    required String reportId,
    required String accountId,
    required String accountName,
    required AccountRole accountRole,
    required String reportTitle,
    required String emergencyTypeId,
  }) async {}

  @override
  Future<void> arrive({
    required String reportId,
    required String accountId,
  }) async {}

  @override
  Future<void> requestAmbulance({
    required String reportId,
    required String accountId,
  }) async {}

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
  }) => const Stream.empty();

  @override
  Stream<List<Participation>> watchParticipations(String reportId) =>
      const Stream.empty();

  @override
  Stream<List<Participation>> watchParticipationsForAccount(String accountId) =>
      const Stream.empty();

  @override
  Stream<MeetingPoint?> watchMeetingPoint(String reportId) =>
      const Stream.empty();
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeParticipationRepository participationRepo,
  ({double latitude, double longitude})? location,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ParticipationRepository>.value(value: participationRepo),
        Provider<LocationRepository>.value(
          value: _FakeLocationRepository(result: location),
        ),
      ],
      child: const MaterialApp(
        home: MeetingPointPickerScreen(
          reportId: 'report-1',
          requesterId: 'uid-1',
          requesterRole: AccountRole.voluntario,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('confirmar manda la ubicación sugerida al repositorio (RF-5)', (
    tester,
  ) async {
    final repo = _FakeParticipationRepository();
    await _pumpScreen(
      tester,
      participationRepo: repo,
      location: (latitude: 4.6, longitude: -74.1),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirm-meeting-point-button')));
    await tester.pumpAndSettle();

    expect(repo.lastLatitude, 4.6);
    expect(repo.lastLongitude, -74.1);
  });

  testWidgets('sin ubicación disponible, el botón queda deshabilitado', (
    tester,
  ) async {
    final repo = _FakeParticipationRepository();
    await _pumpScreen(tester, participationRepo: repo, location: null);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('no-location-message')), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('confirm-meeting-point-button')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'si el repositorio bloquea, muestra un mensaje en vez de crashear',
    (tester) async {
      final repo = _FakeParticipationRepository(shouldBlock: true);
      await _pumpScreen(
        tester,
        participationRepo: repo,
        location: (latitude: 4.6, longitude: -74.1),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm-meeting-point-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('meeting-point-error')), findsOneWidget);
    },
  );
}
