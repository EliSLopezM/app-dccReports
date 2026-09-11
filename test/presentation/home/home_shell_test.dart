import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/repositories/account_repository.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
import 'package:app_dcc_reports/presentation/home/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login({required String identifier, required String password}) async {}

  @override
  Future<String> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    required AccountRole role,
    required List<String> activeCourseIds,
    OrganizationInfo? organization,
  }) async =>
      'fake-uid';

  @override
  Future<void> logout() async {}

  @override
  Stream<String?> watchCurrentUid() => const Stream.empty();
}

class _FakeAccountRepository implements AccountRepository {
  @override
  Stream<List<Account>> watchAllAccounts() => Stream.value(const []);

  @override
  Stream<List<Account>> watchPendingAccounts() => Stream.value(const []);

  @override
  Stream<Account?> watchAccount(String uid) => Stream.value(null);

  @override
  Future<void> approve({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
  }) async {}

  @override
  Future<void> reject({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
    String? reason,
  }) async {}
}

Account _account({required AccountRole role}) {
  return Account(
    id: 'uid-1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: role,
    status: AccountStatus.approved,
    organization:
        role.requiresOrganization ? const OrganizationInfo(name: 'Comité X', address: 'Dir X') : null,
    createdAt: DateTime(2026, 9, 11),
  );
}

Future<void> _pumpHome(WidgetTester tester, AccountRole role) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _FakeAuthRepository()),
        Provider<AccountRepository>.value(value: _FakeAccountRepository()),
      ],
      child: MaterialApp(home: HomeShell(account: _account(role: role))),
    ),
  );
}

void main() {
  testWidgets('voluntario NO ve acceso al panel', (tester) async {
    await _pumpHome(tester, AccountRole.voluntario);

    expect(find.byKey(const Key('panel-access')), findsNothing);
  });

  testWidgets('lider NO ve acceso al panel', (tester) async {
    await _pumpHome(tester, AccountRole.lider);

    expect(find.byKey(const Key('panel-access')), findsNothing);
  });

  testWidgets('funcionario SÍ ve acceso al panel', (tester) async {
    await _pumpHome(tester, AccountRole.funcionario);

    expect(find.byKey(const Key('panel-access')), findsOneWidget);
  });

  testWidgets('admin SÍ ve acceso al panel', (tester) async {
    await _pumpHome(tester, AccountRole.admin);

    expect(find.byKey(const Key('panel-access')), findsOneWidget);
  });
}
