import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_kind.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_mapper.dart';

const _departmentChatId = 'dept-bogota';
const _departmentChatName = 'DCC Bogotá';
const _customChatLimit = 5;

class FirestoreChatRepositoryImpl implements ChatRepository {
  FirestoreChatRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _chats => _firestore.collection(chatsCollection);

  @override
  Future<void> ensureComiteMembership({required String comiteId, required String uid}) async {
    final query = await _chats
        .where('comiteId', isEqualTo: comiteId)
        .where('kind', isEqualTo: ChatKind.comite.name)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return;
    await query.docs.single.reference.update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Future<void> joinDepartmentChat(String uid) async {
    final doc = _chats.doc(_departmentChatId);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set(
        newChatToFirestore(name: _departmentChatName, kind: ChatKind.department, memberIds: [uid]),
      );
    } else {
      await doc.update({
        'memberIds': FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Future<String> createCustomChat({
    required String name,
    required String createdBy,
    required List<String> initialMemberIds,
  }) async {
    final active =
        await _chats.where('kind', isEqualTo: ChatKind.custom.name).where('createdBy', isEqualTo: createdBy).get();
    if (active.docs.length >= _customChatLimit) {
      throw ChatLimitExceededException();
    }

    final doc = _chats.doc();
    await doc.set(
      newChatToFirestore(
        name: name,
        kind: ChatKind.custom,
        memberIds: {createdBy, ...initialMemberIds}.toList(),
        createdBy: createdBy,
      ),
    );
    return doc.id;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _assertOwner(
    String chatId,
    String requesterId,
  ) async {
    final doc = await _chats.doc(chatId).get();
    if (!doc.exists || doc.data()!['createdBy'] != requesterId) {
      throw NotChatOwnerException();
    }
    return doc;
  }

  @override
  Future<void> deleteChat({required String chatId, required String requesterId}) async {
    await _assertOwner(chatId, requesterId);
    await _chats.doc(chatId).delete();
  }

  @override
  Future<void> addMember({
    required String chatId,
    required String requesterId,
    required String newMemberUid,
  }) async {
    await _assertOwner(chatId, requesterId);
    await _chats.doc(chatId).update({
      'memberIds': FieldValue.arrayUnion([newMemberUid]),
    });
  }

  @override
  Stream<List<Chat>> watchMyChats(String uid) {
    return _chats.where('memberIds', arrayContains: uid).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => chatFromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Stream<Chat?> watchChat(String chatId) {
    return _chats.doc(chatId).snapshots().map(
          (doc) => doc.exists ? chatFromFirestore(doc.id, doc.data()!) : null,
        );
  }

  @override
  Stream<Chat?> watchChatByComite(String comiteId) {
    return _chats
        .where('comiteId', isEqualTo: comiteId)
        .where('kind', isEqualTo: ChatKind.comite.name)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty ? null : chatFromFirestore(
              snapshot.docs.single.id,
              snapshot.docs.single.data(),
            ));
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final chatDoc = await _chats.doc(chatId).get();
    final memberIds = List<String>.from(chatDoc.data()?['memberIds'] as List? ?? const []);
    if (!chatDoc.exists || !memberIds.contains(senderId)) {
      throw NotChatMemberException();
    }
    await _chats.doc(chatId).collection(messagesSubcollection).add(
          newMessageToFirestore(senderId: senderId, senderName: senderName, text: text),
        );
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chats.doc(chatId).collection(messagesSubcollection).orderBy('sentAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => chatMessageFromFirestore(chatId, doc.id, doc.data()))
              .toList(),
        );
  }
}
