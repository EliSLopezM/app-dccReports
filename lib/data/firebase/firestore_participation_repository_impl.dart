import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/difficulty_level.dart';
import '../../domain/entities/finish_type.dart';
import '../../domain/entities/meeting_point.dart';
import '../../domain/entities/participation.dart';
import '../../domain/entities/participation_status.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/participation_repository.dart';
import 'emergency_report_mapper.dart' show reportsCollection;
import 'participation_mapper.dart';

/// Sube la foto de finalización (RF-10) y devuelve su URL pública.
typedef ParticipationPhotoUploader = Future<String> Function(
  String reportId,
  String accountId,
  String localPhotoPath,
);

class FirestoreParticipationRepositoryImpl implements ParticipationRepository {
  FirestoreParticipationRepositoryImpl(
    this._firestore, {
    ParticipationPhotoUploader? uploadPhoto,
    DateTime Function()? now,
    // ignore: prefer_initializing_formals
  })  : _uploadPhoto = uploadPhoto,
        _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final ParticipationPhotoUploader? _uploadPhoto;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> _participations(String reportId) => _firestore
      .collection(reportsCollection)
      .doc(reportId)
      .collection(participationsSubcollection);

  DocumentReference<Map<String, dynamic>> _meetingPoint(String reportId) =>
      _firestore.collection(meetingPointsCollection).doc(reportId);

  @override
  Future<void> goTo({
    required String reportId,
    required String accountId,
    required String accountName,
    required AccountRole accountRole,
    required String reportTitle,
    required String emergencyTypeId,
  }) async {
    final doc = _participations(reportId).doc(accountId);
    final existing = await doc.get();
    if (existing.exists) return; // RF caso límite: "Ir" dos veces no duplica.
    await doc.set(
      newGoingParticipationToFirestore(
        accountId: accountId,
        accountName: accountName,
        accountRole: accountRole,
        reportTitle: reportTitle,
        emergencyTypeId: emergencyTypeId,
        goingAt: _now(),
      ),
    );
  }

  @override
  Future<void> arrive({required String reportId, required String accountId}) async {
    await _participations(reportId).doc(accountId).update({
      'status': ParticipationStatus.arrived.name,
      'arrivedAt': Timestamp.fromDate(_now()),
    });
  }

  @override
  Future<void> requestAmbulance({required String reportId, required String accountId}) async {
    await _participations(reportId).doc(accountId).update({
      'ambulanceRequestedAt': Timestamp.fromDate(_now()),
    });
  }

  Future<void> _finish({
    required String reportId,
    required String accountId,
    required FinishType finishType,
    required DifficultyLevel difficultyLevel,
    String? photoUrl,
    String? reason,
  }) async {
    final doc = _participations(reportId).doc(accountId);
    final snapshot = await doc.get();
    if (!snapshot.exists || snapshot.data()!['status'] != ParticipationStatus.arrived.name) {
      throw NotArrivedException();
    }
    await doc.update({
      'status': ParticipationStatus.finished.name,
      'finishedAt': Timestamp.fromDate(_now()),
      'finishType': finishType.name,
      'difficultyLevel': difficultyLevel.name,
      'photoUrl': photoUrl,
      'reason': reason,
    });
  }

  @override
  Future<void> finishCompleted({
    required String reportId,
    required String accountId,
    required String localPhotoPath,
    required DifficultyLevel difficultyLevel,
  }) async {
    final uploader = _uploadPhoto;
    final photoUrl =
        uploader == null ? localPhotoPath : await uploader(reportId, accountId, localPhotoPath);
    await _finish(
      reportId: reportId,
      accountId: accountId,
      finishType: FinishType.completed,
      difficultyLevel: difficultyLevel,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<void> finishWithdrawn({
    required String reportId,
    required String accountId,
    required String reason,
    required DifficultyLevel difficultyLevel,
  }) {
    return _finish(
      reportId: reportId,
      accountId: accountId,
      finishType: FinishType.withdrawn,
      difficultyLevel: difficultyLevel,
      reason: reason,
    );
  }

  @override
  Stream<Participation?> watchMyParticipation({
    required String reportId,
    required String accountId,
  }) {
    return _participations(reportId).doc(accountId).snapshots().map(
          (doc) => doc.exists ? participationFromFirestore(reportId, doc.id, doc.data()!) : null,
        );
  }

  @override
  Stream<List<Participation>> watchParticipations(String reportId) {
    return _participations(reportId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => participationFromFirestore(reportId, doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<Participation>> watchParticipationsForAccount(String accountId) {
    return _firestore
        .collectionGroup(participationsSubcollection)
        .where('accountId', isEqualTo: accountId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            // reports/{reportId}/participations/{accountId}
            final reportId = doc.reference.parent.parent!.id;
            return participationFromFirestore(reportId, doc.id, doc.data());
          }).toList(),
        );
  }

  @override
  Stream<MeetingPoint?> watchMeetingPoint(String reportId) {
    return _meetingPoint(reportId).snapshots().map(
          (doc) => doc.exists ? meetingPointFromFirestore(reportId, doc.data()!) : null,
        );
  }

  @override
  Future<void> setMeetingPoint({
    required String reportId,
    required String requesterId,
    required AccountRole requesterRole,
    required double latitude,
    required double longitude,
  }) async {
    final doc = _meetingPoint(reportId);
    if (!requesterRole.isEmergencyLeadership) {
      final existing = await doc.get();
      if (existing.exists && existing.data()!['setByUid'] != requesterId) {
        throw MeetingPointBlockedException();
      }
    }
    await doc.set(
      meetingPointToFirestore(
        setByUid: requesterId,
        setByRole: requesterRole,
        latitude: latitude,
        longitude: longitude,
        setAt: _now(),
      ),
    );
  }
}
