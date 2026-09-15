import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/content_kind.dart';
import 'package:app_dcc_reports/domain/entities/content_post.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/emergency_report.dart';
import 'package:app_dcc_reports/domain/entities/meeting_point.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/repositories/account_repository.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
import 'package:app_dcc_reports/domain/repositories/content_repository.dart';
import 'package:app_dcc_reports/domain/repositories/emergency_report_repository.dart';
import 'package:app_dcc_reports/domain/repositories/participation_repository.dart';
import 'package:app_dcc_reports/presentation/content/capacitate_screen.dart';
import 'package:app_dcc_reports/presentation/content/content_list_screen.dart';
import 'package:app_dcc_reports/presentation/home/home_shell.dart';
import 'package:app_dcc_reports/presentation/legal/legal_screen.dart';
import 'package:app_dcc_reports/presentation/panel/account_detail_screen.dart';
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

  @override
  Future<void> setComite({required String uid, required String comiteId}) async {}
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

class _FakeParticipationRepository implements ParticipationRepository {
  @override
  Stream<List<Participation>> watchParticipationsForAccount(String accountId) =>
      Stream.value(const []);

  @override
  Future<void> goTo({
    required String reportId,
    required String accountId,
    required String accountName,
    required AccountRole accountRole,
    required String reportTitle,
    required String emergencyTypeId,
  }) async {}

  @override
  Future<void> arrive({required String reportId, required String accountId}) async {}

  @override
  Future<void> requestAmbulance({required String reportId, required String accountId}) async {}

  @override
  Future<void> finishCompleted({
    required String reportId,
    required String accountId,
    required String localPhotoPath,
    required DifficultyLevel difficultyLevel,
  }) async {}

  @override
  Future<void> finishWithdrawn({
    required String reportId,
    required String accountId,
    required String reason,
    required DifficultyLevel difficultyLevel,
  }) async {}

  @override
  Stream<Participation?> watchMyParticipation({
    required String reportId,
    required String accountId,
  }) =>
      const Stream.empty();

  @override
  Stream<List<Participation>> watchParticipations(String reportId) => const Stream.empty();

  @override
  Stream<MeetingPoint?> watchMeetingPoint(String reportId) => const Stream.empty();

  @override
  Future<void> setMeetingPoint({
    required String reportId,
    required String requesterId,
    required AccountRole requesterRole,
    required double latitude,
    required double longitude,
  }) async {}
}

class _FakeContentRepository implements ContentRepository {
  @override
  Stream<List<ContentPost>> watchPosts(ContentKind kind) => Stream.value(const []);

  @override
  Future<String> create({
    required ContentKind kind,
    required String authorId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
  }) async =>
      'id';

  @override
  Future<void> update({
    required String postId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
    bool removePhoto = false,
  }) async {}

  @override
  Future<void> delete({required String postId, required AccountRole authorRole}) async {}
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
        Provider<EmergencyReportRepository>.value(value: _FakeEmergencyReportRepository()),
        Provider<ParticipationRepository>.value(value: _FakeParticipationRepository()),
        Provider<ContentRepository>.value(value: _FakeContentRepository()),
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

  testWidgets('cualquier cuenta aprobada ve el acceso al mapa (spec 003)', (tester) async {
    await _pumpHome(tester, AccountRole.voluntario);

    expect(find.byKey(const Key('map-access')), findsOneWidget);
  });

  testWidgets('cualquier cuenta aprobada ve "Mi perfil" y navega a su propio detalle (spec 006, RF-5)',
      (tester) async {
    await _pumpHome(tester, AccountRole.voluntario);

    expect(find.byKey(const Key('profile-access')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-access')));
    await tester.pumpAndSettle();

    expect(find.byType(AccountDetailScreen), findsOneWidget);
    expect(find.text('Jane Doe'), findsWidgets);
  });

  testWidgets('Noticias, Capacítate y Prepárate navegan a sus pantallas reales (spec 007)',
      (tester) async {
    await _pumpHome(tester, AccountRole.voluntario);

    await tester.tap(find.byKey(const Key('news-access')));
    await tester.pumpAndSettle();
    expect(find.byType(ContentListScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('preparate-access')));
    await tester.pumpAndSettle();
    expect(find.byType(ContentListScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('capacitate-access')));
    await tester.pumpAndSettle();
    expect(find.byType(CapacitateScreen), findsOneWidget);
  });

  testWidgets('cualquier cuenta aprobada ve "Legal" y navega a la pantalla real (spec 008, RF-3)',
      (tester) async {
    await _pumpHome(tester, AccountRole.voluntario);

    expect(find.byKey(const Key('legal-access')), findsOneWidget);

    await tester.tap(find.byKey(const Key('legal-access')));
    await tester.pumpAndSettle();

    expect(find.byType(LegalScreen), findsOneWidget);
  });
}
