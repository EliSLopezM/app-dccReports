import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_kind.dart';
import '../../domain/entities/chat_message.dart';

const chatsCollection = 'chats';
const messagesSubcollection = 'messages';

Map<String, dynamic> newChatToFirestore({
  required String name,
  required ChatKind kind,
  List<String> memberIds = const [],
  String? comiteId,
  String? createdBy,
}) {
  return {
    'name': name,
    'kind': kind.name,
    'memberIds': memberIds,
    'comiteId': comiteId,
    'createdBy': createdBy,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

Chat chatFromFirestore(String id, Map<String, dynamic> data) {
  return Chat(
    id: id,
    name: data['name'] as String,
    kind: ChatKind.values.byName(data['kind'] as String),
    memberIds: List<String>.from(data['memberIds'] as List? ?? const []),
    comiteId: data['comiteId'] as String?,
    createdBy: data['createdBy'] as String?,
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

Map<String, dynamic> newMessageToFirestore({
  required String senderId,
  required String senderName,
  required String text,
}) {
  return {
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'sentAt': FieldValue.serverTimestamp(),
  };
}

ChatMessage chatMessageFromFirestore(
  String chatId,
  String id,
  Map<String, dynamic> data,
) {
  return ChatMessage(
    id: id,
    chatId: chatId,
    senderId: data['senderId'] as String,
    senderName: data['senderName'] as String,
    text: data['text'] as String,
    sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
