import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/chat_repository.dart';

/// RF-11/RF-12: mensajería en tiempo real dentro de un chat.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat, required this.uid, required this.displayName});

  final Chat chat;
  final String uid;
  final String displayName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  String? _errorMessage;
  late final Stream<List<ChatMessage>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = context.read<ChatRepository>().watchMessages(widget.chat.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final repository = context.read<ChatRepository>();
    _messageController.clear();
    try {
      await repository.sendMessage(
        chatId: widget.chat.id,
        senderId: widget.uid,
        senderName: widget.displayName,
        text: text,
      );
    } on NotChatMemberException {
      setState(() => _errorMessage = 'Ya no eres miembro de este chat.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.name)),
      body: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? const [];
                if (messages.isEmpty) {
                  return const Center(child: Text('Sin mensajes todavía.'));
                }
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.senderName),
                      subtitle: Text(message.text),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('message-field'),
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: 'Escribe un mensaje'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  key: const Key('send-message-button'),
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
