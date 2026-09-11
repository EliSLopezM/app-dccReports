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
  }) : assert(photoUrls.length >= 2, 'Un reporte requiere mínimo 2 fotos (RF-2/RF-3)');
}
