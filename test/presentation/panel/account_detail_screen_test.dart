import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/finish_type.dart';
import 'package:app_dcc_reports/domain/entities/meeting_point.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/entities/participation_status.dart';
import 'package:app_dcc_reports/domain/repositories/participation_repository.dart';
import 'package:app_dcc_reports/presentation/panel/account_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeParticipationRepository implements ParticipationRepository {
  _FakeParticipationRepository({this.participations = const []});

  final List<Participation> participations;

  @override
  Stream<List<Participation>> watchParticipationsForAccount(String accountId) =>
      Stream.value(participations);

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

Account _buildAccount({
  required AccountRole role,
  OrganizationInfo? organization,
  List<String> activeCourseIds = const [],
}) {
  return Account(
    id: 'uid-1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: role,
    status: AccountStatus.pending,
    activeCourseIds: activeCourseIds,
    organization: organization,
    createdAt: DateTime(2026, 9, 11),
  );
}

Participation _finishedParticipation() {
  final goingAt = DateTime(2026, 9, 14, 10);
  final arrivedAt = goingAt.add(const Duration(minutes: 10));
  final finishedAt = arrivedAt.add(const Duration(hours: 2));
  return Participation(
    reportId: 'report-1',
    accountId: 'uid-1',
    accountName: 'Jane Doe',
    accountRole: AccountRole.voluntario,
    reportTitle: 'Incendio en bodega',
    emergencyTypeId: 'incendio',
    status: ParticipationStatus.finished,
    goingAt: goingAt,
    arrivedAt: arrivedAt,
    finishedAt: finishedAt,
    finishType: FinishType.completed,
    difficultyLevel: DifficultyLevel.media,
    photoUrl: 'https://example.com/finish.jpg',
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Account account, {
  List<Participation> participations = const [],
}) {
  return tester.pumpWidget(
    Provider<ParticipationRepository>.value(
      value: _FakeParticipationRepository(participations: participations),
      child: MaterialApp(home: AccountDetailScreen(account: account)),
    ),
  );
}

void main() {
  testWidgets('muestra rango, estado y cursos de un voluntario (RF-12)', (tester) async {
    final account = _buildAccount(
      role: AccountRole.voluntario,
      activeCourseIds: const ['primeros_auxilios'],
    );

    await _pumpScreen(tester, account);
    await tester.pump();

    expect(find.text('Voluntario'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.textContaining('Primeros auxilios'), findsOneWidget);
  });

  testWidgets('muestra organización solo si la cuenta es funcionario/líder funcionario (RF-12)',
      (tester) async {
    final account = _buildAccount(
      role: AccountRole.funcionario,
      organization: const OrganizationInfo(name: 'Comité Suba', address: 'Cra 1 # 2-3'),
    );

    await _pumpScreen(tester, account);
    await tester.pump();

    expect(find.text('Comité Suba'), findsOneWidget);
    expect(find.text('Cra 1 # 2-3'), findsOneWidget);
  });

  testWidgets('un voluntario no muestra sección de organización', (tester) async {
    final account = _buildAccount(role: AccountRole.voluntario);

    await _pumpScreen(tester, account);
    await tester.pump();

    expect(find.text('Organización'), findsNothing);
  });

  testWidgets('sin participaciones, muestra historial vacío sin insignias (spec 006, RF-1/RF-2)',
      (tester) async {
    final account = _buildAccount(role: AccountRole.voluntario);

    await _pumpScreen(tester, account);
    await tester.pump();

    expect(find.text('Todavía sin insignias.'), findsOneWidget);
    expect(find.text('Sin emergencias en el historial todavía.'), findsOneWidget);
  });

  testWidgets('con 1 participación finalizada, muestra la insignia y el historial (spec 006, RF-2/RF-4)',
      (tester) async {
    final account = _buildAccount(role: AccountRole.voluntario);

    await _pumpScreen(tester, account, participations: [_finishedParticipation()]);
    await tester.pump();

    expect(find.text('Primeros pasos'), findsOneWidget);
    expect(find.text('Incendio en bodega'), findsOneWidget);
    expect(find.textContaining('Incendio'), findsWidgets);
  });
}
