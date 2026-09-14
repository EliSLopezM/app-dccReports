import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/repositories/account_repository.dart';
import 'package:app_dcc_reports/presentation/panel/panel_accounts_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository(this.accounts);

  final List<Account> accounts;
  final List<String> approvedIds = [];

  @override
  Stream<List<Account>> watchAllAccounts() => Stream.value(accounts);

  @override
  Stream<List<Account>> watchPendingAccounts() =>
      Stream.value(accounts.where((a) => a.status == AccountStatus.pending).toList());

  @override
  Stream<Account?> watchAccount(String uid) {
    final matches = accounts.where((a) => a.id == uid);
    return Stream.value(matches.isEmpty ? null : matches.first);
  }

  @override
  Future<void> approve({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
  }) async {
    approvedIds.add(accountId);
  }

  @override
  Future<void> reject({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
    String? reason,
  }) async {}

  @override
  Future<void> setComite({required String uid, required String comiteId}) async {}
}

Account _pendingAccount({required String id, required AccountRole role}) {
  return Account(
    id: id,
    name: 'Cuenta $id',
    email: '$id@example.com',
    role: role,
    status: AccountStatus.pending,
    organization:
        role.requiresOrganization ? const OrganizationInfo(name: 'Comité X', address: 'Dir X') : null,
    createdAt: DateTime(2026, 9, 11),
  );
}

Future<void> _pumpPanel(
  WidgetTester tester,
  _FakeAccountRepository repo, {
  required AccountRole viewerRole,
}) {
  return tester.pumpWidget(
    Provider<AccountRepository>.value(
      value: repo,
      child: MaterialApp(
        home: PanelAccountsListScreen(viewerRole: viewerRole, viewerId: 'viewer-uid'),
      ),
    ),
  );
}

void main() {
  testWidgets(
      'Funcionario NO ve botones de aprobar/rechazar en una fila de otro funcionario (RF-7 UI)',
      (tester) async {
    final repo = _FakeAccountRepository([
      _pendingAccount(id: 'f1', role: AccountRole.funcionario),
    ]);

    await _pumpPanel(tester, repo, viewerRole: AccountRole.funcionario);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('Admin SÍ ve botones de aprobar/rechazar en una fila de funcionario', (tester) async {
    final repo = _FakeAccountRepository([
      _pendingAccount(id: 'f1', role: AccountRole.funcionario),
    ]);

    await _pumpPanel(tester, repo, viewerRole: AccountRole.admin);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('Funcionario SÍ ve y puede aprobar una fila de voluntario', (tester) async {
    final repo = _FakeAccountRepository([
      _pendingAccount(id: 'v1', role: AccountRole.voluntario),
    ]);

    await _pumpPanel(tester, repo, viewerRole: AccountRole.funcionario);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(repo.approvedIds, contains('v1'));
  });
}
