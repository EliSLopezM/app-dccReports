import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/meeting_point.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/repositories/participation_repository.dart';
import 'package:app_dcc_reports/presentation/emergency_response/finish_participation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeParticipationRepository implements ParticipationRepository {
  String? lastLocalPhotoPath;
  DifficultyLevel? lastDifficultyLevel;
  String? lastReason;

  @override
  Future<void> finishCompleted({
    required String reportId,
    required String accountId,
    required String localPhotoPath,
    required DifficultyLevel difficultyLevel,
  }) async {
    lastLocalPhotoPath = localPhotoPath;
    lastDifficultyLevel = difficultyLevel;
  }

  @override
  Future<void> finishWithdrawn({
    required String reportId,
    required String accountId,
    required String reason,
    required DifficultyLevel difficultyLevel,
  }) async {
    lastReason = reason;
    lastDifficultyLevel = difficultyLevel;
  }

  @override
  Future<void> arrive({
    required String reportId,
    required String accountId,
  }) async {}

  @override
  Future<void> goTo({
    required String reportId,
    required String accountId,
    required String accountName,
    required dynamic accountRole,
    required String reportTitle,
    required String emergencyTypeId,
  }) async {}

  @override
  Future<void> requestAmbulance({
    required String reportId,
    required String accountId,
  }) async {}

  @override
  Future<void> setMeetingPoint({
    required String reportId,
    required String requesterId,
    required dynamic requesterRole,
    required double latitude,
    required double longitude,
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
  WidgetTester tester,
  _FakeParticipationRepository repo, {
  PickImage? pickImage,
}) {
  return tester.pumpWidget(
    Provider<ParticipationRepository>.value(
      value: repo,
      child: MaterialApp(
        home: FinishParticipationScreen(
          reportId: 'report-1',
          accountId: 'uid-1',
          pickImage: pickImage ?? (source) async => null,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('"Ya terminé" con foto manda finishCompleted (RF-10)', (
    tester,
  ) async {
    final repo = _FakeParticipationRepository();
    await _pumpScreen(
      tester,
      repo,
      pickImage: (source) async => '/tmp/finish.jpg',
    );

    await tester.tap(find.text('Agregar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
    await tester.pumpAndSettle();

    expect(repo.lastLocalPhotoPath, '/tmp/finish.jpg');
    expect(repo.lastDifficultyLevel, DifficultyLevel.media);
  });

  testWidgets('"Ya terminé" sin foto se bloquea', (tester) async {
    final repo = _FakeParticipationRepository();
    await _pumpScreen(tester, repo);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('finish-error')), findsOneWidget);
    expect(repo.lastLocalPhotoPath, isNull);
  });

  testWidgets('"Debo retirarme" con razón manda finishWithdrawn (RF-10)', (
    tester,
  ) async {
    final repo = _FakeParticipationRepository();
    await _pumpScreen(tester, repo);

    await tester.tap(find.text('Debo retirarme'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reason-field')),
      'Emergencia familiar',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
    await tester.pumpAndSettle();

    expect(repo.lastReason, 'Emergencia familiar');
  });

  testWidgets('"Debo retirarme" sin razón se bloquea', (tester) async {
    final repo = _FakeParticipationRepository();
    await _pumpScreen(tester, repo);

    await tester.tap(find.text('Debo retirarme'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('finish-error')), findsOneWidget);
    expect(repo.lastReason, isNull);
  });
}
