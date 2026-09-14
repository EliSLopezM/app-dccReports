/// RF-11: mensaje de texto dentro de un chat.
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });
}
