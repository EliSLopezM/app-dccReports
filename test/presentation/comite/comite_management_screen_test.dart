import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/chat.dart';
import 'package:app_dcc_reports/domain/entities/chat_kind.dart';
import 'package:app_dcc_reports/domain/entities/chat_message.dart';
import 'package:app_dcc_reports/domain/entities/comite.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/meeting_point.dart';
import 'package:app_dcc_reports/domain/entities/participation.dart';
import 'package:app_dcc_reports/domain/repositories/account_repository.dart';
import 'package:app_dcc_reports/domain/repositories/chat_repository.dart';
import 'package:app_dcc_reports/domain/repositories/comite_repository.dart';
import 'package:app_dcc_reports/domain/repositories/participation_repository.dart';
import 'package:app_dcc_reports/presentation/comite/comite_management_screen.dart';
import 'package:app_dcc_reports/presentation/panel/account_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeComiteRepository implements ComiteRepository {
  _FakeComiteRepository(this.comite);

  Comite comite;
  String? lastDelegateId;

  @override
  Future<String> create({
    required String name,
    required String address,
    required String leaderId,
    double? latitude,
    double? longitude,
  }) async => 'id';

  @override
  Stream<Comite?> watchComite(String comiteId) => Stream.value(comite);

  @override
  Stream<List<Comite>> watchNearbyComites({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) => Stream.value(const []);

  @override
  Stream<List<Comite>> watchAllComites() => Stream.value([comite]);

  @override
  Future<void> setDelegate({
    required String comiteId,
    required String requesterId,
    required String delegateId,
  }) async {
    lastDelegateId = delegateId;
  }
}

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository(this.memberIds);

  final List<String> memberIds;

  @override
  Stream<Chat?> watchChatByComite(String comiteId) => Stream.value(
    Chat(
      id: 'chat-1',
      name: 'Comité Suba',
      kind: ChatKind.comite,
      comiteId: comiteId,
      memberIds: memberIds,
      createdAt: DateTime(2026, 9, 14),
    ),
  );

  @override
  Future<void> ensureComiteMembership({
    required String comiteId,
    required String uid,
  }) async {}

  @override
  Future<void> joinDepartmentChat(String uid) async {}

  @override
  Future<String> createCustomChat({
    required String name,
    required String createdBy,
    required List<String> initialMemberIds,
  }) async => 'id';

  @override
  Future<void> deleteChat({
    required String chatId,
    required String requesterId,
  }) async {}

  @override
  Future<void> addMember({
    required String chatId,
    required String requesterId,
    required String newMemberUid,
  }) async {}

  @override
  Stream<List<Chat>> watchMyChats(String uid) => Stream.value(const []);

  @override
  Stream<Chat?> watchChat(String chatId) => Stream.value(null);

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {}

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) =>
      Stream.value(const []);
}

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository(this.accountsById);

  final Map<String, Account> accountsById;

  @override
  Stream<Account?> watchAccount(String uid) => Stream.value(accountsById[uid]);

  @override
  Stream<List<Account>> watchAllAccounts() => Stream.value(accountsById.values.toList());

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

  @override
  Future<void> setComite({required String uid, required String comiteId}) async {}
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

Comite _comite({String? delegateId}) {
  return Comite(
    id: 'comite-1',
    name: 'Comité Suba',
    address: 'Cra 1 # 2-3',
    leaderId: 'leader-uid',
    delegateId: delegateId,
    createdAt: DateTime(2026, 9, 14),
  );
}

Account _account(String id, String name) {
  return Account(
    id: id,
    name: name,
    email: '$id@example.com',
    role: AccountRole.voluntario,
    status: AccountStatus.approved,
    createdAt: DateTime(2026, 9, 14),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeComiteRepository comiteRepo,
  required _FakeChatRepository chatRepo,
  required _FakeAccountRepository accountRepo,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ComiteRepository>.value(value: comiteRepo),
        Provider<ChatRepository>.value(value: chatRepo),
        Provider<AccountRepository>.value(value: accountRepo),
        Provider<ParticipationRepository>.value(value: _FakeParticipationRepository()),
      ],
      child: MaterialApp(
        home: ComiteManagementScreen(comite: comiteRepo.comite, requesterId: 'leader-uid'),
      ),
    ),
  );
}

void main() {
  testWidgets('lista los miembros con su nombre real y permite hacer delegado a uno (RF-5, spec 006 RF-6)',
      (tester) async {
    final comiteRepo = _FakeComiteRepository(_comite());
    final chatRepo = _FakeChatRepository(['leader-uid', 'volunteer-uid']);
    final accountRepo = _FakeAccountRepository({
      'leader-uid': _account('leader-uid', 'Jane Leader'),
      'volunteer-uid': _account('volunteer-uid', 'John Volunteer'),
    });

    await _pumpScreen(tester, comiteRepo: comiteRepo, chatRepo: chatRepo, accountRepo: accountRepo);
    await tester.pumpAndSettle();

    expect(find.text('Jane Leader'), findsOneWidget);
    expect(find.text('John Volunteer'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Hacer delegado').first);
    await tester.pumpAndSettle();

    expect(comiteRepo.lastDelegateId, isNotNull);
  });

  testWidgets('tocar un miembro navega a su perfil (spec 006, RF-6)', (tester) async {
    final comiteRepo = _FakeComiteRepository(_comite());
    final chatRepo = _FakeChatRepository(['leader-uid', 'volunteer-uid']);
    final accountRepo = _FakeAccountRepository({
      'leader-uid': _account('leader-uid', 'Jane Leader'),
      'volunteer-uid': _account('volunteer-uid', 'John Volunteer'),
    });

    await _pumpScreen(tester, comiteRepo: comiteRepo, chatRepo: chatRepo, accountRepo: accountRepo);
    await tester.pumpAndSettle();

    await tester.tap(find.text('John Volunteer'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountDetailScreen), findsOneWidget);
  });

  testWidgets('muestra quién es el delegado actual', (tester) async {
    final comiteRepo = _FakeComiteRepository(_comite(delegateId: 'volunteer-uid'));
    final chatRepo = _FakeChatRepository(['leader-uid', 'volunteer-uid']);
    final accountRepo = _FakeAccountRepository({
      'leader-uid': _account('leader-uid', 'Jane Leader'),
      'volunteer-uid': _account('volunteer-uid', 'John Volunteer'),
    });

    await _pumpScreen(tester, comiteRepo: comiteRepo, chatRepo: chatRepo, accountRepo: accountRepo);
    await tester.pump();

    expect(find.textContaining('volunteer-uid'), findsWidgets);
  });
}
