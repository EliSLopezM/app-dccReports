import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/finish_type.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/entities/participation_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final goingAt = DateTime(2026, 9, 14, 10);
  final arrivedAt = DateTime(2026, 9, 14, 10, 20);
  final finishedAt = DateTime(2026, 9, 14, 11, 20);

  test(
    'una participación "going" se construye sin arrivedAt ni finishedAt (RF-1)',
    () {
      final participation = Participation(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
        status: ParticipationStatus.going,
        goingAt: goingAt,
      );

      expect(participation.arrivedAt, isNull);
    },
  );

  test('una participación "arrived" requiere arrivedAt (RF-4)', () {
    final participation = Participation(
      reportId: 'report-1',
      accountId: 'uid-1',
      accountName: 'Jane',
      accountRole: AccountRole.voluntario,
      reportTitle: 'Incendio',
      emergencyTypeId: 'incendio',
      status: ParticipationStatus.arrived,
      goingAt: goingAt,
      arrivedAt: arrivedAt,
    );

    expect(participation.timeToArrive, const Duration(minutes: 20));
  });

  test('finalizada como completed calcula los tiempos (RF-10/RF-11)', () {
    final participation = Participation(
      reportId: 'report-1',
      accountId: 'uid-1',
      accountName: 'Jane',
      accountRole: AccountRole.voluntario,
      reportTitle: 'Incendio',
      emergencyTypeId: 'incendio',
      status: ParticipationStatus.finished,
      goingAt: goingAt,
      arrivedAt: arrivedAt,
      finishedAt: finishedAt,
      finishType: FinishType.completed,
      difficultyLevel: DifficultyLevel.media,
      photoUrl: 'https://example.com/finish.jpg',
    );

    expect(participation.timeToArrive, const Duration(minutes: 20));
    expect(participation.timeAtEmergency, const Duration(hours: 1));
  });

  test(
    'finalizada como completed sin foto lanza un assertion error (RF-10)',
    () {
      expect(
        () => Participation(
          reportId: 'report-1',
          accountId: 'uid-1',
          accountName: 'Jane',
          accountRole: AccountRole.voluntario,
          reportTitle: 'Incendio',
          emergencyTypeId: 'incendio',
          status: ParticipationStatus.finished,
          goingAt: goingAt,
          arrivedAt: arrivedAt,
          finishedAt: finishedAt,
          finishType: FinishType.completed,
          difficultyLevel: DifficultyLevel.media,
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  test('finalizada como withdrawn requiere reason, no foto (RF-10)', () {
    final participation = Participation(
      reportId: 'report-1',
      accountId: 'uid-1',
      accountName: 'Jane',
      accountRole: AccountRole.voluntario,
      reportTitle: 'Incendio',
      emergencyTypeId: 'incendio',
      status: ParticipationStatus.finished,
      goingAt: goingAt,
      arrivedAt: arrivedAt,
      finishedAt: finishedAt,
      finishType: FinishType.withdrawn,
      difficultyLevel: DifficultyLevel.baja,
      reason: 'Me llamaron de urgencia a otro lado',
    );

    expect(participation.reason, isNotNull);
    expect(participation.photoUrl, isNull);
  });
}
