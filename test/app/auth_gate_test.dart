import 'package:app_dcc_reports/app/auth_gate.dart';
import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/repositories/account_repository.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
import 'package:app_dcc_reports/domain/repositories/emergency_report_repository.dart';
import 'package:app_dcc_reports/presentation/home/home_shell.dart';
import 'package:app_dcc_reports/presentation/login/login_screen.dart';
import 'package:app_dcc_reports/presentation/pending/pending_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.uid});

  final String? uid;

  @override
  Stream<String?> watchCurrentUid() => Stream.value(uid);

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
}

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository(this.account);

  final Account? account;

  @override
  Stream<Account?> watchAccount(String uid) => Stream.value(account);

  @override
  Stream<List<Account>> watchAllAccounts() => Stream.value(const []);

  @override
  Stream<List<Account>> watchPendingAccounts() => Stream.value(const []);

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

class _FakeEmergencyReportRepository implements EmergencyReportRepository {
  @override
  Stream<List<EmergencyReport>> watchActiveReports({required DateTime since}) =>
      Stream.value(const []);

  @override
  Future<String> submit({
    required String title,
    required String address,
    required String emergencyTypeId,
    required List<String> localPhotoPaths,
    String? reporterName,
    String? reporterPhone,
    required String deviceId,
    double? latitude,
    double? longitude,
  }) async =>
      'id';

  @override
  Stream<List<EmergencyReport>> watchAllReports() => Stream.value(const []);

  @override
  Stream<List<EmergencyReport>> watchReportsByDevice(String deviceId) => Stream.value(const []);

  @override
  Stream<List<EmergencyReport>> watchReportsByPhone(String phone) => Stream.value(const []);

  @override
  Future<void> updateStatus({
    required String reviewerId,
    required String reportId,
    required ReportStatus newStatus,
  }) async {}
}

Account _approvedAccount() {
  return Account(
    id: 'uid-1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: AccountRole.voluntario,
    status: AccountStatus.approved,
    createdAt: DateTime(2026, 9, 11),
  );
}

Account _pendingAccount() {
  return Account(
    id: 'uid-1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: AccountRole.voluntario,
    status: AccountStatus.pending,
    createdAt: DateTime(2026, 9, 11),
  );
}

Future<void> _pumpAuthGate(
  WidgetTester tester, {
  String? uid,
  Account? account,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _FakeAuthRepository(uid: uid)),
        Provider<AccountRepository>.value(value: _FakeAccountRepository(account)),
        Provider<EmergencyReportRepository>.value(value: _FakeEmergencyReportRepository()),
      ],
      child: const MaterialApp(home: AuthGate()),
    ),
  );
}

void main() {
  testWidgets('sin sesión muestra LoginScreen', (tester) async {
    await _pumpAuthGate(tester, uid: null);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('con sesión y cuenta pendiente muestra PendingApprovalScreen (RF-4)',
      (tester) async {
    await _pumpAuthGate(tester, uid: 'uid-1', account: _pendingAccount());
    await tester.pumpAndSettle();

    expect(find.byType(PendingApprovalScreen), findsOneWidget);
  });

  testWidgets('con sesión y cuenta aprobada muestra HomeShell', (tester) async {
    await _pumpAuthGate(tester, uid: 'uid-1', account: _approvedAccount());
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
  });
}
