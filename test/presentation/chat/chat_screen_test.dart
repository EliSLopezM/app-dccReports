import 'package:app_dcc_reports/domain/entities/chat.dart';
import 'package:app_dcc_reports/domain/entities/chat_kind.dart';
import 'package:app_dcc_reports/domain/entities/chat_message.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:app_dcc_reports/domain/repositories/chat_repository.dart';
import 'package:app_dcc_reports/presentation/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.shouldRejectSend = false});

  final bool shouldRejectSend;
  String? lastText;
  String? lastSenderName;

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (shouldRejectSend) throw NotChatMemberException();
    lastText = text;
    lastSenderName = senderName;
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) => Stream.value(const []);

  @override
  Future<void> ensureComiteMembership({required String comiteId, required String uid}) async {}

  @override
  Future<void> joinDepartmentChat(String uid) async {}

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
  Stream<List<Chat>> watchMyChats(String uid) => Stream.value(const []);

  @override
  Stream<Chat?> watchChat(String chatId) => Stream.value(null);

  @override
  Stream<Chat?> watchChatByComite(String comiteId) => Stream.value(null);
}

Chat _chat() {
  return Chat(
    id: 'chat-1',
    name: 'Grupo de trabajo',
    kind: ChatKind.custom,
    memberIds: const ['uid-1'],
    createdBy: 'uid-1',
    createdAt: DateTime(2026, 9, 14),
  );
}

void main() {
  testWidgets('enviar un mensaje lo manda al repositorio (RF-11)', (tester) async {
    final repo = _FakeChatRepository();

    await tester.pumpWidget(
      Provider<ChatRepository>.value(
        value: repo,
        child: MaterialApp(home: ChatScreen(chat: _chat(), uid: 'uid-1', displayName: 'Jane')),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('message-field')), 'Hola equipo');
    await tester.tap(find.byKey(const Key('send-message-button')));
    await tester.pumpAndSettle();

    expect(repo.lastText, 'Hola equipo');
    expect(repo.lastSenderName, 'Jane');
  });

  testWidgets('si el repositorio rechaza el envío, muestra un mensaje de error (RF-12)',
      (tester) async {
    final repo = _FakeChatRepository(shouldRejectSend: true);

    await tester.pumpWidget(
      Provider<ChatRepository>.value(
        value: repo,
        child: MaterialApp(home: ChatScreen(chat: _chat(), uid: 'uid-1', displayName: 'Jane')),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('message-field')), 'Hola');
    await tester.tap(find.byKey(const Key('send-message-button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ya no eres miembro'), findsOneWidget);
  });
}
