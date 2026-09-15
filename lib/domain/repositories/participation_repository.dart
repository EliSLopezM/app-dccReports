import '../entities/account_role.dart';
import '../entities/difficulty_level.dart';
import '../entities/meeting_point.dart';
import '../entities/participation.dart';
import '../exceptions.dart';

/// RF-1 a RF-11: ciclo de vida de la participación de una cuenta en una
/// emergencia, y el punto de encuentro asociado.
abstract class ParticipationRepository {
  /// RF-1: idempotente — llamarlo dos veces no duplica la participación.
  /// RF-3 (spec 006): [reportTitle]/[emergencyTypeId] quedan guardados
  /// en la participación para el historial de perfil.
  Future<void> goTo({
    required String reportId,
    required String accountId,
    required String accountName,
    required AccountRole accountRole,
    required String reportTitle,
    required String emergencyTypeId,
  });

  /// RF-4.
  Future<void> arrive({required String reportId, required String accountId});

  /// RF-9: solo registra la solicitud; la UI abre el marcador telefónico.
  Future<void> requestAmbulance({
    required String reportId,
    required String accountId,
  });

  /// RF-10/RF-11: sube [localPhotoPath] (mismo patrón que los reportes,
  /// spec 002) y lanza [NotArrivedException] si no había llegado.
  Future<void> finishCompleted({
    required String reportId,
    required String accountId,
    required String localPhotoPath,
    required DifficultyLevel difficultyLevel,
  });

  /// RF-10/RF-11: mismo criterio que [finishCompleted].
  Future<void> finishWithdrawn({
    required String reportId,
    required String accountId,
    required String reason,
    required DifficultyLevel difficultyLevel,
  });

  Stream<Participation?> watchMyParticipation({
    required String reportId,
    required String accountId,
  });

  Stream<List<Participation>> watchParticipations(String reportId);

  /// RF-4 (spec 006): historial de una cuenta a través de todos los
  /// reportes.
  Stream<List<Participation>> watchParticipationsForAccount(String accountId);

  Stream<MeetingPoint?> watchMeetingPoint(String reportId);

  /// RF-7/RF-8: lanza [MeetingPointBlockedException] si un voluntario
  /// intenta poner/cambiar el punto existiendo uno de otra cuenta.
  Future<void> setMeetingPoint({
    required String reportId,
    required String requesterId,
    required AccountRole requesterRole,
    required double latitude,
    required double longitude,
  });
}
