enum AccountRole { voluntario, funcionario, lider, liderFuncionario, admin }

extension AccountRoleX on AccountRole {
  /// RF-2/RF-3: solo funcionario y líder funcionario capturan datos de
  /// organización al registrarse.
  bool get requiresOrganization =>
      this == AccountRole.funcionario || this == AccountRole.liderFuncionario;

  /// RF-6/RF-7: quién puede aprobar/rechazar cuentas pendientes.
  bool get canReviewAccounts =>
      this == AccountRole.admin ||
      this == AccountRole.funcionario ||
      this == AccountRole.liderFuncionario;

  /// RF-7: solo Admin revisa cuentas de estos rangos.
  bool get isHighRank =>
      this == AccountRole.funcionario || this == AccountRole.liderFuncionario;
}

/// RF-7, centralizado para que data y presentation apliquen la misma
/// regla: solo Admin revisa cuentas de rango funcionario/líder
/// funcionario; el resto de revisores solo pueden con rangos normales.
bool canReview({
  required AccountRole reviewerRole,
  required AccountRole targetRole,
}) {
  if (!reviewerRole.canReviewAccounts) return false;
  if (targetRole.isHighRank) return reviewerRole == AccountRole.admin;
  return true;
}
