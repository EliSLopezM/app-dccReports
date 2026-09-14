import 'account_role.dart';

/// RF-5/RF-7/RF-8: único punto de encuentro por emergencia.
class MeetingPoint {
  final String reportId;
  final double latitude;
  final double longitude;
  final String setByUid;
  final AccountRole setByRole;
  final DateTime setAt;

  const MeetingPoint({
    required this.reportId,
    required this.latitude,
    required this.longitude,
    required this.setByUid,
    required this.setByRole,
    required this.setAt,
  });
}
