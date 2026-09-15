import 'account_role.dart';
import 'difficulty_level.dart';
import 'finish_type.dart';
import 'participation_status.dart';

/// RF-1 a RF-11: participación de una cuenta en una emergencia.
class Participation {
  final String reportId;
  final String accountId;
  final String accountName;
  final AccountRole accountRole;

  /// RF-3 (spec 006): guardados al tocar "Ir" para listar el historial
  /// de una cuenta sin volver a consultar cada reporte.
  final String reportTitle;
  final String emergencyTypeId;

  final ParticipationStatus status;
  final DateTime goingAt;
  final DateTime? arrivedAt;
  final DateTime? finishedAt;
  final FinishType? finishType;
  final DifficultyLevel? difficultyLevel;
  final String? photoUrl;
  final String? reason;
  final DateTime? ambulanceRequestedAt;

  Participation({
    required this.reportId,
    required this.accountId,
    required this.accountName,
    required this.accountRole,
    required this.reportTitle,
    required this.emergencyTypeId,
    required this.status,
    required this.goingAt,
    this.arrivedAt,
    this.finishedAt,
    this.finishType,
    this.difficultyLevel,
    this.photoUrl,
    this.reason,
    this.ambulanceRequestedAt,
  }) : assert(
         status != ParticipationStatus.going ||
             (arrivedAt == null && finishedAt == null),
         '"going" no debe tener arrivedAt ni finishedAt',
       ),
       assert(
         status != ParticipationStatus.arrived ||
             (arrivedAt != null && finishedAt == null),
         '"arrived" requiere arrivedAt y no debe tener finishedAt',
       ),
       assert(
         status != ParticipationStatus.finished ||
             (arrivedAt != null &&
                 finishedAt != null &&
                 finishType != null &&
                 difficultyLevel != null),
         '"finished" requiere arrivedAt, finishedAt, finishType y difficultyLevel (RF-10)',
       ),
       assert(
         finishType != FinishType.completed || photoUrl != null,
         'finishType "completed" requiere photoUrl (RF-10)',
       ),
       assert(
         finishType != FinishType.withdrawn || reason != null,
         'finishType "withdrawn" requiere reason (RF-10)',
       );

  /// RF-11: tiempo desde que aceptó hasta que llegó.
  Duration? get timeToArrive => arrivedAt?.difference(goingAt);

  /// RF-11: tiempo desde que llegó hasta que finalizó.
  Duration? get timeAtEmergency => (arrivedAt != null && finishedAt != null)
      ? finishedAt!.difference(arrivedAt!)
      : null;
}
