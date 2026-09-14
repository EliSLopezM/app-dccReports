import 'report_status.dart';
import 'reporter_evidence.dart';

class EmergencyReport {
  final String id;
  final String title;
  final String address;
  final String emergencyTypeId;
  final List<String> photoUrls;
  final ReportStatus status;
  final ReporterEvidence reporterEvidence;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  /// RF-13/RF-14 (spec 002, Enmienda 1): null si no se pudo capturar la
  /// ubicación al enviar — ese reporte no aparece en el mapa (spec 003).
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  const EmergencyReport({
    required this.id,
    required this.title,
    required this.address,
    required this.emergencyTypeId,
    required this.photoUrls,
    required this.status,
    required this.reporterEvidence,
    required this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
    this.latitude,
    this.longitude,
  }) : assert(
         photoUrls.length >= 2,
         'Un reporte requiere mínimo 2 fotos (RF-2/RF-3)',
       );
}
