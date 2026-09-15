import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/finish_type.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/entities/participation_status.dart';
import 'package:app_dcc_reports/domain/entities/profile_stats.dart';
import 'package:flutter_test/flutter_test.dart';

Participation _finished({
  required Duration serviceTime,
  FinishType finishType = FinishType.completed,
}) {
  final goingAt = DateTime(2026, 9, 14, 10);
  final arrivedAt = goingAt.add(const Duration(minutes: 10));
  final finishedAt = arrivedAt.add(serviceTime);
  return Participation(
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
    finishType: finishType,
    difficultyLevel: DifficultyLevel.media,
    photoUrl: finishType == FinishType.completed ? 'https://example.com/a.jpg' : null,
    reason: finishType == FinishType.withdrawn ? 'Emergencia familiar' : null,
  );
}

void main() {
  group('ProfileStats.from (RF-1)', () {
    test('sin participaciones, todo en cero', () {
      final stats = ProfileStats.from(const []);

      expect(stats.totalParticipations, 0);
      expect(stats.totalServiceTime, Duration.zero);
    });

    test('suma tiempos y cuenta completed y withdrawn por igual', () {
      final participations = [
        _finished(serviceTime: const Duration(hours: 1)),
        _finished(serviceTime: const Duration(hours: 2), finishType: FinishType.withdrawn),
      ];

      final stats = ProfileStats.from(participations);

      expect(stats.totalParticipations, 2);
      expect(stats.totalServiceTime, const Duration(hours: 3));
    });
  });

  group('unlockedAchievements (RF-2)', () {
    test('sin participaciones, sin insignias', () {
      expect(unlockedAchievements(const ProfileStats(totalParticipations: 0, totalServiceTime: Duration.zero)),
          isEmpty);
    });

    test('1 participación desbloquea "Primeros pasos" solamente', () {
      final unlocked = unlockedAchievements(
        const ProfileStats(totalParticipations: 1, totalServiceTime: Duration.zero),
      );

      expect(unlocked.map((a) => a.id), ['primeros_pasos']);
    });

    test('5 participaciones desbloquea "Primeros pasos" y "Comprometido"', () {
      final unlocked = unlockedAchievements(
        const ProfileStats(totalParticipations: 5, totalServiceTime: Duration.zero),
      );

      expect(unlocked.map((a) => a.id), ['primeros_pasos', 'comprometido']);
    });

    test('20 participaciones desbloquea también "Veterano"', () {
      final unlocked = unlockedAchievements(
        const ProfileStats(totalParticipations: 20, totalServiceTime: Duration.zero),
      );

      expect(unlocked.map((a) => a.id), ['primeros_pasos', 'comprometido', 'veterano']);
    });

    test('100 horas de servicio desbloquea la insignia de horas', () {
      final unlocked = unlockedAchievements(
        const ProfileStats(totalParticipations: 0, totalServiceTime: Duration(hours: 100)),
      );

      expect(unlocked.map((a) => a.id), ['cien_horas']);
    });
  });
}
