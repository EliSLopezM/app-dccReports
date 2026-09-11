import '../entities/account_role.dart';
import '../entities/organization_info.dart';
import '../exceptions.dart';

/// Sesión y alta de cuentas (RF-2, RF-9, RF-10). No expone `Account`
/// directamente — eso vive en `AccountRepository`, que lee/escribe el
/// documento `accounts/{uid}` una vez el uid de Auth existe.
abstract class AuthRepository {
  Stream<String?> watchCurrentUid();

  /// RF-2: crea el usuario en Auth y su cuenta en estado pendiente.
  /// Lanza [DuplicateAccountException] si el correo/teléfono ya existe.
  Future<String> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    required AccountRole role,
    required List<String> activeCourseIds,
    OrganizationInfo? organization,
  });

  /// RF-9/RF-10: [identifier] puede ser correo o teléfono. Lanza
  /// [InvalidCredentialsException] si no coinciden.
  Future<void> login({required String identifier, required String password});

  Future<void> logout();
}
