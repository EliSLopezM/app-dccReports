/// RF-10: credenciales incorrectas en login.
class InvalidCredentialsException implements Exception {}

/// Caso límite de spec.md: registro con un correo/teléfono ya existente.
class DuplicateAccountException implements Exception {}

/// RF-7: un Funcionario/Líder funcionario intentó aprobar o rechazar una
/// cuenta de rango funcionario/liderFuncionario — solo Admin puede.
class InsufficientReviewPermissionException implements Exception {}

class AccountNotFoundException implements Exception {}

class AuthUnexpectedException implements Exception {
  AuthUnexpectedException([this.message = 'Ocurrió un error inesperado.']);

  final String message;
}
