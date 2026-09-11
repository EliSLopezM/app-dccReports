import 'package:flutter_test/flutter_test.dart';
import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';

void main() {
  final createdAt = DateTime(2026, 9, 11);

  Account buildAccount({
    required AccountRole role,
    OrganizationInfo? organization,
  }) {
    return Account(
      id: 'uid-1',
      name: 'Jane Doe',
      email: 'jane@example.com',
      role: role,
      status: AccountStatus.pending,
      createdAt: createdAt,
      organization: organization,
    );
  }

  group('Account', () {
    for (final role in [AccountRole.voluntario, AccountRole.lider]) {
      test('$role se construye sin organization', () {
        final account = buildAccount(role: role);
        expect(account.organization, isNull);
      });
    }

    for (final role in [
      AccountRole.funcionario,
      AccountRole.liderFuncionario,
    ]) {
      test('$role se construye con organization (RF-2)', () {
        final account = buildAccount(
          role: role,
          organization: const OrganizationInfo(
            name: 'Comité Suba',
            address: 'Cra 1 # 2-3',
          ),
        );
        expect(account.organization, isNotNull);
      });

      test('$role sin organization lanza un assertion error (RF-3)', () {
        expect(() => buildAccount(role: role), throwsA(isA<AssertionError>()));
      });
    }

    test('voluntario/lider con organization lanza un assertion error (RF-3)', () {
      expect(
        () => buildAccount(
          role: AccountRole.voluntario,
          organization: const OrganizationInfo(name: 'X', address: 'Y'),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('admin se construye sin organization', () {
      final account = buildAccount(role: AccountRole.admin);
      expect(account.organization, isNull);
    });

    test('requiere email o teléfono', () {
      expect(
        () => Account(
          id: 'uid-2',
          name: 'No contact',
          role: AccountRole.voluntario,
          status: AccountStatus.pending,
          createdAt: createdAt,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
