import 'package:app_dcc_reports/domain/entities/chat.dart';
import 'package:app_dcc_reports/domain/entities/chat_kind.dart';
import 'package:app_dcc_reports/domain/entities/chat_message.dart';
import 'package:app_dcc_reports/domain/entities/comite.dart';
import 'package:app_dcc_reports/domain/repositories/chat_repository.dart';
import 'package:app_dcc_reports/domain/repositories/comite_repository.dart';
import 'package:app_dcc_reports/presentation/comite/comite_management_screen.dart';
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

void main() {
  testWidgets('lista los miembros y permite hacer delegado a uno (RF-5)', (
    tester,
  ) async {
    final comiteRepo = _FakeComiteRepository(_comite());
    final chatRepo = _FakeChatRepository(['leader-uid', 'volunteer-uid']);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ComiteRepository>.value(value: comiteRepo),
          Provider<ChatRepository>.value(value: chatRepo),
        ],
        child: MaterialApp(
          home: ComiteManagementScreen(
            comite: comiteRepo.comite,
            requesterId: 'leader-uid',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('leader-uid'), findsOneWidget);
    expect(find.text('volunteer-uid'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Hacer delegado').first);
    await tester.pumpAndSettle();

    expect(comiteRepo.lastDelegateId, isNotNull);
  });

  testWidgets('muestra quién es el delegado actual', (tester) async {
    final comiteRepo = _FakeComiteRepository(
      _comite(delegateId: 'volunteer-uid'),
    );
    final chatRepo = _FakeChatRepository(['leader-uid', 'volunteer-uid']);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ComiteRepository>.value(value: comiteRepo),
          Provider<ChatRepository>.value(value: chatRepo),
        ],
        child: MaterialApp(
          home: ComiteManagementScreen(
            comite: comiteRepo.comite,
            requesterId: 'leader-uid',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('volunteer-uid'), findsWidgets);
  });
}
