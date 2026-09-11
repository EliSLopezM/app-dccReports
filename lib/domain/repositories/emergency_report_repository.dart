import '../entities/emergency_report.dart';
import '../entities/report_status.dart';
import '../exceptions.dart';

/// Reporte público y su moderación (RF-2 a RF-12).
abstract class EmergencyReportRepository {
  /// RF-2/RF-3/RF-4/RF-5/RF-6: crea el reporte en estado pending. Lanza
  /// [InvalidReportException] si faltan datos, o [SpamLimitExceededException]
  /// si el deviceId superó el límite (RF-7).
  Future<String> submit({
    required String title,
    required String address,
    required String emergencyTypeId,
    required List<String> localPhotoPaths,
    String? reporterName,
    String? reporterPhone,
    required String deviceId,
  });

  /// RF-8: todos los reportes, para el panel.
  Stream<List<EmergencyReport>> watchAllReports();

  /// RF-12: historial de reportes de un mismo dispositivo.
  Stream<List<EmergencyReport>> watchReportsByDevice(String deviceId);

  /// RF-12: historial de reportes de un mismo teléfono.
  Stream<List<EmergencyReport>> watchReportsByPhone(String phone);

  /// RF-1 (spec 003): reportes "activa" creados desde [since] — fuente
  /// única para el mapa y la campana.
  Stream<List<EmergencyReport>> watchActiveReports({required DateTime since});

  /// RF-9/RF-10: cambia el estado de un reporte.
  Future<void> updateStatus({
    required String reviewerId,
    required String reportId,
    required ReportStatus newStatus,
  });
}
