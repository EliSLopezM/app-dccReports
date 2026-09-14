import 'package:app_dcc_reports/data/firebase/firestore_chat_repository_impl.dart';
import 'package:app_dcc_reports/data/firebase/firestore_comite_repository_impl.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ensureComiteMembership (T6, RF-4)', () {
    test('agrega el uid al chat del comité, idempotente', () async {
      final firestore = FakeFirebaseFirestore();
      final comiteRepo = FirestoreComiteRepositoryImpl(firestore);
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final comiteId = await comiteRepo.create(
        name: 'Comité Suba',
        address: 'Cra 1 # 2-3',
        leaderId: 'leader-uid',
      );

      await chatRepo.ensureComiteMembership(comiteId: comiteId, uid: 'volunteer-uid');
      await chatRepo.ensureComiteMembership(comiteId: comiteId, uid: 'volunteer-uid');

      final chats = await chatRepo.watchMyChats('volunteer-uid').first;
      expect(chats, hasLength(1));
      expect(chats.single.memberIds, ['volunteer-uid']);
    });
  });

  group('watchChatByComite (RF-5)', () {
    test('encuentra el chat del comité y lista sus miembros', () async {
      final firestore = FakeFirebaseFirestore();
      final comiteRepo = FirestoreComiteRepositoryImpl(firestore);
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final comiteId = await comiteRepo.create(
        name: 'Comité Suba',
        address: 'Cra 1 # 2-3',
        leaderId: 'leader-uid',
      );
      await chatRepo.ensureComiteMembership(comiteId: comiteId, uid: 'leader-uid');
      await chatRepo.ensureComiteMembership(comiteId: comiteId, uid: 'volunteer-uid');

      final chat = await chatRepo.watchChatByComite(comiteId).first;

      expect(chat, isNotNull);
      expect(chat!.memberIds, containsAll(['leader-uid', 'volunteer-uid']));
    });
  });

  group('joinDepartmentChat (T7, RF-6)', () {
    test('crea el chat de departamento la primera vez y agrega al uid', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);

      await chatRepo.joinDepartmentChat('uid-1');

      final chats = await chatRepo.watchMyChats('uid-1').first;
      expect(chats, hasLength(1));
      expect(chats.single.name, 'DCC Bogotá');
    });

    test('un segundo uid se une al mismo chat ya existente', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      await chatRepo.joinDepartmentChat('uid-1');

      await chatRepo.joinDepartmentChat('uid-2');

      final chatsForUid2 = await chatRepo.watchMyChats('uid-2').first;
      expect(chatsForUid2, hasLength(1));
      expect(chatsForUid2.single.memberIds, containsAll(['uid-1', 'uid-2']));
    });
  });

  group('createCustomChat (T8, RF-7)', () {
    test('5 chats seguidos pasan, el 6to se bloquea', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);

      for (var i = 0; i < 5; i++) {
        await chatRepo.createCustomChat(
          name: 'Grupo $i',
          createdBy: 'funcionario-uid',
          initialMemberIds: const [],
        );
      }

      expect(
        () => chatRepo.createCustomChat(
          name: 'Grupo 6',
          createdBy: 'funcionario-uid',
          initialMemberIds: const [],
        ),
        throwsA(isA<ChatLimitExceededException>()),
      );
    });
  });

  group('deleteChat / addMember (T9, RF-8/RF-9)', () {
    test('el creador elimina un chat y libera cupo para crear otro', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final ids = <String>[];
      for (var i = 0; i < 5; i++) {
        ids.add(await chatRepo.createCustomChat(
          name: 'Grupo $i',
          createdBy: 'funcionario-uid',
          initialMemberIds: const [],
        ));
      }

      await chatRepo.deleteChat(chatId: ids.first, requesterId: 'funcionario-uid');

      await expectLater(
        chatRepo.createCustomChat(
          name: 'Grupo nuevo',
          createdBy: 'funcionario-uid',
          initialMemberIds: const [],
        ),
        completes,
      );
    });

    test('el creador agrega un miembro', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final chatId = await chatRepo.createCustomChat(
        name: 'Grupo',
        createdBy: 'funcionario-uid',
        initialMemberIds: const [],
      );

      await chatRepo.addMember(
        chatId: chatId,
        requesterId: 'funcionario-uid',
        newMemberUid: 'volunteer-uid',
      );

      final chat = await chatRepo.watchChat(chatId).first;
      expect(chat!.memberIds, contains('volunteer-uid'));
    });

    test('alguien que no es el creador no puede eliminar ni agregar (RF-9)', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final chatId = await chatRepo.createCustomChat(
        name: 'Grupo',
        createdBy: 'funcionario-uid',
        initialMemberIds: const [],
      );

      expect(
        () => chatRepo.deleteChat(chatId: chatId, requesterId: 'someone-else'),
        throwsA(isA<NotChatOwnerException>()),
      );
      expect(
        () => chatRepo.addMember(
          chatId: chatId,
          requesterId: 'someone-else',
          newMemberUid: 'volunteer-uid',
        ),
        throwsA(isA<NotChatOwnerException>()),
      );
    });
  });

  group('watchMyChats (T10, RF-10)', () {
    test('trae solo los chats donde el uid es miembro, de los 3 tipos', () async {
      final firestore = FakeFirebaseFirestore();
      final comiteRepo = FirestoreComiteRepositoryImpl(firestore);
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final comiteId = await comiteRepo.create(
        name: 'Comité Suba',
        address: 'Cra 1 # 2-3',
        leaderId: 'other-leader',
      );
      await chatRepo.ensureComiteMembership(comiteId: comiteId, uid: 'uid-1');
      await chatRepo.joinDepartmentChat('uid-1');
      await chatRepo.createCustomChat(
        name: 'Grupo custom',
        createdBy: 'uid-1',
        initialMemberIds: const [],
      );
      // Un chat ajeno donde uid-1 no participa.
      await chatRepo.createCustomChat(
        name: 'Grupo ajeno',
        createdBy: 'other-uid',
        initialMemberIds: const [],
      );

      final chats = await chatRepo.watchMyChats('uid-1').first;

      expect(chats, hasLength(3));
    });
  });

  group('sendMessage / watchMessages (T11, RF-11/RF-12)', () {
    test('un miembro manda un mensaje y aparece en watchMessages', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final chatId = await chatRepo.createCustomChat(
        name: 'Grupo',
        createdBy: 'funcionario-uid',
        initialMemberIds: const [],
      );

      await chatRepo.sendMessage(
        chatId: chatId,
        senderId: 'funcionario-uid',
        senderName: 'Jane',
        text: 'Hola equipo',
      );

      final messages = await chatRepo.watchMessages(chatId).first;
      expect(messages, hasLength(1));
      expect(messages.single.text, 'Hola equipo');
    });

    test('un no miembro no puede mandar mensajes (RF-12)', () async {
      final firestore = FakeFirebaseFirestore();
      final chatRepo = FirestoreChatRepositoryImpl(firestore);
      final chatId = await chatRepo.createCustomChat(
        name: 'Grupo',
        createdBy: 'funcionario-uid',
        initialMemberIds: const [],
      );

      expect(
        () => chatRepo.sendMessage(
          chatId: chatId,
          senderId: 'intruder-uid',
          senderName: 'Intruso',
          text: 'Hola',
        ),
        throwsA(isA<NotChatMemberException>()),
      );
    });
  });
}
