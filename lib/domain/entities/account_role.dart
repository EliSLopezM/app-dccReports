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
}
