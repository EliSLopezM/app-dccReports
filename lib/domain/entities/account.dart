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

  /// RF-1/RF-2 (spec 004): comité al que pertenece — fundado (funcionario/
  /// líder funcionario) o elegido (voluntario/líder) al registrarse. Null
  /// si aún no existía ninguno para elegir.
  final String? comiteId;

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
    this.comiteId,
  })  : assert(
          email != null || phone != null,
          'Account requiere email o teléfono',
        ),
        assert(
          role.requiresOrganization == (organization != null),
          'organization solo se define para funcionario/liderFuncionario (RF-3)',
        );
}
