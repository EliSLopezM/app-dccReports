import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/difficulty_level.dart';
import '../../domain/entities/finish_type.dart';
import '../../domain/entities/meeting_point.dart';
import '../../domain/entities/participation.dart';
import '../../domain/entities/participation_status.dart';

const participationsSubcollection = 'participations';
const meetingPointsCollection = 'meetingPoints';

Map<String, dynamic> newGoingParticipationToFirestore({
  required String accountId,
  required String accountName,
  required AccountRole accountRole,
  required String reportTitle,
  required String emergencyTypeId,
  required DateTime goingAt,
}) {
  return {
    'accountId': accountId,
    'accountName': accountName,
    'accountRole': accountRole.name,
    'reportTitle': reportTitle,
    'emergencyTypeId': emergencyTypeId,
    'status': ParticipationStatus.going.name,
    'goingAt': Timestamp.fromDate(goingAt),
    'arrivedAt': null,
    'finishedAt': null,
    'finishType': null,
    'difficultyLevel': null,
    'photoUrl': null,
    'reason': null,
    'ambulanceRequestedAt': null,
  };
}

Participation participationFromFirestore(
  String reportId,
  String accountId,
  Map<String, dynamic> data,
) {
  return Participation(
    reportId: reportId,
    accountId: accountId,
    accountName: data['accountName'] as String,
    accountRole: AccountRole.values.byName(data['accountRole'] as String),
    reportTitle: data['reportTitle'] as String,
    emergencyTypeId: data['emergencyTypeId'] as String,
    status: ParticipationStatus.values.byName(data['status'] as String),
    goingAt: (data['goingAt'] as Timestamp).toDate(),
    arrivedAt: (data['arrivedAt'] as Timestamp?)?.toDate(),
    finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
    finishType: (data['finishType'] as String?) == null
        ? null
        : FinishType.values.byName(data['finishType'] as String),
    difficultyLevel: (data['difficultyLevel'] as String?) == null
        ? null
        : DifficultyLevel.values.byName(data['difficultyLevel'] as String),
    photoUrl: data['photoUrl'] as String?,
    reason: data['reason'] as String?,
    ambulanceRequestedAt: (data['ambulanceRequestedAt'] as Timestamp?)?.toDate(),
  );
}

Map<String, dynamic> meetingPointToFirestore({
  required String setByUid,
  required AccountRole setByRole,
  required double latitude,
  required double longitude,
  required DateTime setAt,
}) {
  return {
    'latitude': latitude,
    'longitude': longitude,
    'setByUid': setByUid,
    'setByRole': setByRole.name,
    'setAt': Timestamp.fromDate(setAt),
  };
}

MeetingPoint meetingPointFromFirestore(String reportId, Map<String, dynamic> data) {
  return MeetingPoint(
    reportId: reportId,
    latitude: (data['latitude'] as num).toDouble(),
    longitude: (data['longitude'] as num).toDouble(),
    setByUid: data['setByUid'] as String,
    setByRole: AccountRole.values.byName(data['setByRole'] as String),
    setAt: (data['setAt'] as Timestamp).toDate(),
  );
}
