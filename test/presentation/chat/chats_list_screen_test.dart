import 'package:app_dcc_reports/domain/entities/chat.dart';
import 'package:app_dcc_reports/domain/entities/chat_kind.dart';
import 'package:app_dcc_reports/domain/entities/chat_message.dart';
import 'package:app_dcc_reports/domain/repositories/chat_repository.dart';
import 'package:app_dcc_reports/presentation/chat/chat_screen.dart';
import 'package:app_dcc_reports/presentation/chat/chats_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.myChats = const []});

  final List<Chat> myChats;
  String? lastJoinedDepartmentUid;

  @override
  Future<void> joinDepartmentChat(String uid) async {
    lastJoinedDepartmentUid = uid;
  }

  @override
  Stream<List<Chat>> watchMyChats(String uid) => Stream.value(myChats);

  @override
  Future<void> ensureComiteMembership({required String comiteId, required String uid}) async {}

  @override
  Future<String> createCustomChat({
    required String name,
    required String createdBy,
    required List<String> initialMemberIds,
  }) async =>
      'id';

  @override
  Future<void> deleteChat({required String chatId, required String requesterId}) async {}

  @override
  Future<void> addMember({
    required String chatId,
    required String requesterId,
    required String newMemberUid,
  }) async {}

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

Chat _chat(String id, ChatKind kind) {
  return Chat(
    id: id,
    name: 'Chat $id',
    kind: kind,
    memberIds: const ['uid-1'],
    comiteId: kind == ChatKind.comite ? 'comite-1' : null,
    createdBy: kind == ChatKind.custom ? 'uid-1' : null,
    createdAt: DateTime(2026, 9, 14),
  );
}

void main() {
  testWidgets('lista mis chats (RF-10)', (tester) async {
    final repo = _FakeChatRepository(myChats: [_chat('1', ChatKind.comite)]);

    await tester.pumpWidget(
      Provider<ChatRepository>.value(
        value: repo,
        child: const MaterialApp(home: ChatsListScreen(uid: 'uid-1', displayName: 'Jane')),
      ),
    );
    await tester.pump();

    expect(find.text('Chat 1'), findsOneWidget);
  });

  testWidgets('sin buscar nada, no ofrece unirse al chat de departamento', (tester) async {
    final repo = _FakeChatRepository();

    await tester.pumpWidget(
      Provider<ChatRepository>.value(
        value: repo,
        child: const MaterialApp(home: ChatsListScreen(uid: 'uid-1', displayName: 'Jane')),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('join-department-chat')), findsNothing);
  });

  testWidgets('buscar "bogotá" ofrece unirse, y tocar Unirme llama al repositorio (RF-6)',
      (tester) async {
    final repo = _FakeChatRepository();

    await tester.pumpWidget(
      Provider<ChatRepository>.value(
        value: repo,
        child: const MaterialApp(home: ChatsListScreen(uid: 'uid-1', displayName: 'Jane')),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('chat-search-field')), 'bogotá');
    await tester.pump();

    expect(find.byKey(const Key('join-department-chat')), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Unirme'));
    await tester.pumpAndSettle();

    expect(repo.lastJoinedDepartmentUid, 'uid-1');
  });

  testWidgets('tocar un chat navega a ChatScreen', (tester) async {
    final repo = _FakeChatRepository(myChats: [_chat('1', ChatKind.custom)]);

    await tester.pumpWidget(
      Provider<ChatRepository>.value(
        value: repo,
        child: const MaterialApp(home: ChatsListScreen(uid: 'uid-1', displayName: 'Jane')),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Chat 1'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
  });
}
