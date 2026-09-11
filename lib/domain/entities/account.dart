import 'account_role.dart';
import 'account_status.dart';
import 'organization_info.dart';

class Account {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final AccountRole role;
  final AccountStatus status;
  final List<String> activeCourseIds;
  final OrganizationInfo? organization;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  Account({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    required this.status,
    this.activeCourseIds = const [],
    this.organization,
    required this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
  })  : assert(
          email != null || phone != null,
          'Account requiere email o teléfono',
        ),
        assert(
          role.requiresOrganization == (organization != null),
          'organization solo se define para funcionario/liderFuncionario (RF-3)',
        );
}
