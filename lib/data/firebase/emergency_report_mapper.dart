import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/report_status.dart';
import '../../domain/entities/reporter_evidence.dart';

const reportsCollection = 'reports';

Map<String, dynamic> newReportToFirestore({
  required String title,
  required String address,
  required String emergencyTypeId,
  required List<String> photoUrls,
  String? reporterName,
  String? reporterPhone,
  required String deviceId,
}) {
  return {
    'title': title,
    'address': address,
    'emergencyTypeId': emergencyTypeId,
    'photoUrls': photoUrls,
    'status': ReportStatus.pending.name,
    'reporterName': reporterName,
    'reporterPhone': reporterPhone,
    'deviceId': deviceId,
    'createdAt': FieldValue.serverTimestamp(),
    'reviewedBy': null,
    'reviewedAt': null,
  };
}

EmergencyReport reportFromFirestore(String id, Map<String, dynamic> data) {
  return EmergencyReport(
    id: id,
    title: data['title'] as String,
    address: data['address'] as String,
    emergencyTypeId: data['emergencyTypeId'] as String,
    photoUrls: List<String>.from(data['photoUrls'] as List? ?? const []),
    status: ReportStatus.values.byName(data['status'] as String),
    reporterEvidence: ReporterEvidence(
      name: data['reporterName'] as String?,
      phone: data['reporterPhone'] as String?,
      deviceId: data['deviceId'] as String,
    ),
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    reviewedBy: data['reviewedBy'] as String?,
    reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
  );
}
