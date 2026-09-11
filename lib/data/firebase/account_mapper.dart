import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/organization_info.dart';

const accountsCollection = 'accounts';

Map<String, dynamic> newAccountToFirestore({
  required String name,
  String? email,
  String? phone,
  required AccountRole role,
  required List<String> activeCourseIds,
  OrganizationInfo? organization,
}) {
  return {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role.name,
    'status': AccountStatus.pending.name,
    'activeCourseIds': activeCourseIds,
    'organization': organization == null
        ? null
        : {'name': organization.name, 'address': organization.address},
    'createdAt': FieldValue.serverTimestamp(),
    'reviewedBy': null,
    'reviewedAt': null,
  };
}

Account accountFromFirestore(String id, Map<String, dynamic> data) {
  final organizationData = data['organization'] as Map<String, dynamic>?;
  return Account(
    id: id,
    name: data['name'] as String,
    email: data['email'] as String?,
    phone: data['phone'] as String?,
    role: AccountRole.values.byName(data['role'] as String),
    status: AccountStatus.values.byName(data['status'] as String),
    activeCourseIds: List<String>.from(data['activeCourseIds'] as List? ?? const []),
    organization: organizationData == null
        ? null
        : OrganizationInfo(
            name: organizationData['name'] as String,
            address: organizationData['address'] as String,
          ),
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    reviewedBy: data['reviewedBy'] as String?,
    reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
  );
}
