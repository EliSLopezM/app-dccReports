import '../entities/chat.dart';
import '../entities/chat_message.dart';
import '../exceptions.dart';

/// RF-4, RF-6 a RF-12.
abstract class ChatRepository {
  /// RF-4: agrega [uid] al chat del comité [comiteId]. Idempotente.
  Future<void> ensureComiteMembership({required String comiteId, required String uid});

  /// RF-6: agrega [uid] al único chat de departamento (creándolo si
  /// hace falta).
  Future<void> joinDepartmentChat(String uid);

  /// RF-7: solo funcionario, hasta 5 chats **activos** a la vez. Lanza
  /// [ChatLimitExceededException] si se supera.
  Future<String> createCustomChat({
    required String name,
    required String createdBy,
    required List<String> initialMemberIds,
  });

  /// RF-8/RF-9: lanza [NotChatOwnerException] si [requesterId] no creó
  /// el chat.
  Future<void> deleteChat({required String chatId, required String requesterId});

  /// RF-8/RF-9: mismo criterio que [deleteChat].
  Future<void> addMember({
    required String chatId,
    required String requesterId,
    required String newMemberUid,
  });

  /// RF-10: chats de los que [uid] es miembro, de cualquier tipo.
  Stream<List<Chat>> watchMyChats(String uid);

  Stream<Chat?> watchChat(String chatId);

  /// RF-11/RF-12: lanza [NotChatMemberException] si [senderId] no es
  /// miembro de [chatId].
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  });

  Stream<List<ChatMessage>> watchMessages(String chatId);
}
