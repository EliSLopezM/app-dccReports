import '../entities/account.dart';
import '../entities/account_role.dart';
import '../exceptions.dart';

/// Lectura y revisión de cuentas (RF-6 a RF-12).
abstract class AccountRepository {
  Stream<Account?> watchAccount(String uid);

  /// RF-11: para el panel — todas las cuentas, cualquier estado.
  Stream<List<Account>> watchAllAccounts();

  /// RF-4/RF-6: cola de cuentas por revisar.
  Stream<List<Account>> watchPendingAccounts();

  /// RF-6/RF-7: aprueba [accountId]. Lanza
  /// [InsufficientReviewPermissionException] si [reviewerRole] no puede
  /// revisar el rango de esa cuenta.
  Future<void> approve({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
  });

  /// RF-7/RF-8: rechaza [accountId]. Misma restricción que [approve].
  Future<void> reject({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
    String? reason,
  });

  /// RF-1/RF-2 (spec 004): fija el comité de una cuenta ya creada — el
  /// registro no conoce el comité hasta después de crear la cuenta
  /// (funcionario/líder funcionario) o antes (voluntario/líder, que
  /// eligen uno existente).
  Future<void> setComite({required String uid, required String comiteId});
}
