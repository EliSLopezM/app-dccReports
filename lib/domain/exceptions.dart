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

/// RF-3: un reporte con menos de 2 fotos, o sin título/dirección/tipo.
class InvalidReportException implements Exception {
  InvalidReportException(this.message);

  final String message;
}

/// RF-7: el mismo deviceId superó el límite de reportes por hora.
class SpamLimitExceededException implements Exception {}

/// RF-5 (spec 004): solo el líder de un comité puede asignar delegado.
class NotComiteLeaderException implements Exception {}

class ComiteNotFoundException implements Exception {}

/// RF-9 (spec 004): solo el funcionario creador administra su chat.
class NotChatOwnerException implements Exception {}

/// RF-7 (spec 004): el funcionario ya tiene 5 chats activos.
class ChatLimitExceededException implements Exception {}

/// RF-12 (spec 004): solo un miembro puede mandar/leer mensajes.
class NotChatMemberException implements Exception {}

/// RF-10 (spec 005): no se puede finalizar sin haber llegado antes.
class NotArrivedException implements Exception {}

/// RF-7/RF-8 (spec 005): un voluntario intentó poner/cambiar el punto de
/// encuentro sin permiso (ya hay uno de otra cuenta).
class MeetingPointBlockedException implements Exception {}
