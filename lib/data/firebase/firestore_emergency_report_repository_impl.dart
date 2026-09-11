import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/report_status.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/emergency_report_repository.dart';
import 'emergency_report_mapper.dart';

/// Sube una foto local y devuelve su URL pública en Storage.
typedef ReportPhotoUploader = Future<String> Function(
  String reportId,
  String localPhotoPath,
  int index,
);

const _spamWindow = Duration(hours: 1);
const _spamLimit = 3;

class FirestoreEmergencyReportRepositoryImpl implements EmergencyReportRepository {
  FirestoreEmergencyReportRepositoryImpl(
    this._firestore, {
    ReportPhotoUploader? uploadPhoto,
    DateTime Function()? now,
    // ignore: prefer_initializing_formals
  })  : _uploadPhoto = uploadPhoto,
        _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final ReportPhotoUploader? _uploadPhoto;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection(reportsCollection);

  Future<void> _assertUnderSpamLimit(String deviceId) async {
    final cutoff = _now().subtract(_spamWindow);
    final recent = await _reports
        .where('deviceId', isEqualTo: deviceId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .get();
    if (recent.docs.length >= _spamLimit) {
      throw SpamLimitExceededException();
    }
  }

  @override
  Future<String> submit({
    required String title,
    required String address,
    required String emergencyTypeId,
    required List<String> localPhotoPaths,
    String? reporterName,
    String? reporterPhone,
    required String deviceId,
  }) async {
    if (title.trim().isEmpty || address.trim().isEmpty || emergencyTypeId.trim().isEmpty) {
      throw InvalidReportException('Falta título, dirección o tipo de emergencia.');
    }
    if (localPhotoPaths.length < 2) {
      throw InvalidReportException('Se requieren mínimo 2 fotos.');
    }

    await _assertUnderSpamLimit(deviceId);

    final doc = _reports.doc();
    final uploader = _uploadPhoto;
    final photoUrls = uploader == null
        ? localPhotoPaths
        : [
            for (var i = 0; i < localPhotoPaths.length; i++)
              await uploader(doc.id, localPhotoPaths[i], i),
          ];

    await doc.set({
      ...newReportToFirestore(
        title: title,
        address: address,
        emergencyTypeId: emergencyTypeId,
        photoUrls: photoUrls,
        reporterName: reporterName,
        reporterPhone: reporterPhone,
        deviceId: deviceId,
      ),
      // Reloj inyectable (en vez de FieldValue.serverTimestamp()) para que
      // la ventana antispam (RF-7) sea determinística en tests; en
      // producción _now es DateTime.now por defecto.
      'createdAt': Timestamp.fromDate(_now()),
    });
    return doc.id;
  }

  @override
  Stream<List<EmergencyReport>> watchAllReports() {
    return _reports.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => reportFromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Stream<List<EmergencyReport>> watchReportsByDevice(String deviceId) {
    return _reports.where('deviceId', isEqualTo: deviceId).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => reportFromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Stream<List<EmergencyReport>> watchReportsByPhone(String phone) {
    return _reports.where('reporterPhone', isEqualTo: phone).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => reportFromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Stream<List<EmergencyReport>> watchActiveReports({required DateTime since}) {
    return _reports
        .where('status', isEqualTo: ReportStatus.activa.name)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => reportFromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Future<void> updateStatus({
    required String reviewerId,
    required String reportId,
    required ReportStatus newStatus,
  }) async {
    await _reports.doc(reportId).update({
      'status': newStatus.name,
      'reviewedBy': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
