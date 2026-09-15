import 'achievement.dart';
import 'participation.dart';
import 'participation_status.dart';

/// RF-1: estadísticas de servicio de una cuenta, calculadas a partir de
/// sus participaciones finalizadas — "completed" y "withdrawn" cuentan
/// igual (spec.md, "Casos límite").
class ProfileStats {
  final int totalParticipations;
  final Duration totalServiceTime;

  const ProfileStats({required this.totalParticipations, required this.totalServiceTime});

  factory ProfileStats.from(List<Participation> participations) {
    final finished = participations.where((p) => p.status == ParticipationStatus.finished);
    final totalServiceTime = finished.fold<Duration>(
      Duration.zero,
      (total, p) => total + (p.timeAtEmergency ?? Duration.zero),
    );
    return ProfileStats(
      totalParticipations: finished.length,
      totalServiceTime: totalServiceTime,
    );
  }
}

/// RF-2: insignias que ya desbloqueó una cuenta con estas [stats].
List<Achievement> unlockedAchievements(ProfileStats stats) {
  final unlocked = <Achievement>[];
  if (stats.totalParticipations >= 1) {
    unlocked.add(kAchievementCatalog.firstWhere((a) => a.id == 'primeros_pasos'));
  }
  if (stats.totalParticipations >= 5) {
    unlocked.add(kAchievementCatalog.firstWhere((a) => a.id == 'comprometido'));
  }
  if (stats.totalParticipations >= 20) {
    unlocked.add(kAchievementCatalog.firstWhere((a) => a.id == 'veterano'));
  }
  if (stats.totalServiceTime >= const Duration(hours: 100)) {
    unlocked.add(kAchievementCatalog.firstWhere((a) => a.id == 'cien_horas'));
  }
  return unlocked;
}
