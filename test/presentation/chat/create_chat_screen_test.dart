import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/chat.dart';
import 'package:app_dcc_reports/domain/entities/chat_kind.dart';
import 'package:app_dcc_reports/domain/entities/chat_message.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:app_dcc_reports/domain/repositories/account_repository.dart';
import 'package:app_dcc_reports/domain/repositories/chat_repository.dart';
import 'package:app_dcc_reports/presentation/chat/create_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.myCreatedChats = const [], this.rejectCreate = false});

  List<Chat> myCreatedChats;
  final bool rejectCreate;
  String? lastCreatedName;
  String? lastDeletedChatId;
  String? lastAddedMemberUid;

  @override
  Stream<List<Chat>> watchMyChats(String uid) => Stream.value(myCreatedChats);

  @override
  Future<String> createCustomChat({
    required String name,
    required String createdBy,
    required List<String> initialMemberIds,
  }) async {
    if (rejectCreate) throw ChatLimitExceededException();
    lastCreatedName = name;
    return 'new-chat-id';
  }

  @override
  Future<void> deleteChat({required String chatId, required String requesterId}) async {
    lastDeletedChatId = chatId;
  }

  @override
  Future<void> addMember({
    required String chatId,
    required String requesterId,
    required String newMemberUid,
  }) async {
    lastAddedMemberUid = newMemberUid;
  }

  @override
  Future<void> ensureComiteMembership({required String comiteId, required String uid}) async {}

  @override
  Future<void> joinDepartmentChat(String uid) async {}

  @override
  Stream<Chat?> watchChat(String chatId) => Stream.value(null);

  @override
  Stream<Chat?> watchChatByComite(String comiteId) => Stream.value(null);

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {}

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) => Stream.value(const []);
}

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository(this.accounts);

  final List<Account> accounts;

  @override
  Stream<List<Account>> watchAllAccounts() => Stream.value(accounts);

  @override
  Stream<Account?> watchAccount(String uid) => Stream.value(null);

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

Chat _customChat(String id, {List<String> memberIds = const []}) {
  return Chat(
    id: id,
    name: 'Grupo $id',
    kind: ChatKind.custom,
    memberIds: memberIds,
    createdBy: 'funcionario-uid',
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
  required _FakeChatRepository chatRepo,
  _FakeAccountRepository? accountRepo,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ChatRepository>.value(value: chatRepo),
        Provider<AccountRepository>.value(value: accountRepo ?? _FakeAccountRepository(const [])),
      ],
      child: const MaterialApp(home: CreateChatScreen(funcionarioId: 'funcionario-uid')),
    ),
  );
}

void main() {
  testWidgets('crear un chat lo manda al repositorio (RF-7)', (tester) async {
    final chatRepo = _FakeChatRepository();
    await _pumpScreen(tester, chatRepo: chatRepo);

    await tester.enterText(find.byKey(const Key('new-chat-name-field')), 'Grupo logística');
    await tester.tap(find.byKey(const Key('create-chat-button')));
    await tester.pumpAndSettle();

    expect(chatRepo.lastCreatedName, 'Grupo logística');
  });

  testWidgets('si ya tiene 5 activos, muestra el error de límite (RF-7)', (tester) async {
    final chatRepo = _FakeChatRepository(rejectCreate: true);
    await _pumpScreen(tester, chatRepo: chatRepo);

    await tester.enterText(find.byKey(const Key('new-chat-name-field')), 'Grupo 6');
    await tester.tap(find.byKey(const Key('create-chat-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('create-chat-error')), findsOneWidget);
  });

  testWidgets('lista los chats creados y permite eliminarlos (RF-8)', (tester) async {
    final chatRepo = _FakeChatRepository(myCreatedChats: [_customChat('1')]);
    await _pumpScreen(tester, chatRepo: chatRepo);
    await tester.pump();

    expect(find.text('Grupo 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(chatRepo.lastDeletedChatId, '1');
  });

  testWidgets('agregar miembro abre la lista de cuentas y agrega la elegida (RF-8)', (tester) async {
    final chatRepo = _FakeChatRepository(myCreatedChats: [_customChat('1')]);
    final accountRepo = _FakeAccountRepository([_account('uid-2', 'Jane Doe')]);
    await _pumpScreen(tester, chatRepo: chatRepo, accountRepo: accountRepo);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jane Doe'));
    await tester.pumpAndSettle();

    expect(chatRepo.lastAddedMemberUid, 'uid-2');
  });
}
