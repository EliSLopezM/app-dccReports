import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_kind.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_screen.dart';

const _departmentChatName = 'DCC Bogotá';

const _kindLabels = {
  ChatKind.comite: 'Comité',
  ChatKind.department: 'Departamento',
  ChatKind.custom: 'Personalizado',
};

/// RF-10: mis chats. RF-6: buscar y unirse al chat de departamento.
class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key, required this.uid, required this.displayName});

  final String uid;
  final String displayName;

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final _searchController = TextEditingController();
  late final Stream<List<Chat>> _myChatsStream;

  @override
  void initState() {
    super.initState();
    _myChatsStream = context.read<ChatRepository>().watchMyChats(widget.uid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final showDepartmentJoin =
        query.isNotEmpty && _departmentChatName.toLowerCase().contains(query);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('chat-search-field'),
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar chats (ej. DCC Bogotá)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (showDepartmentJoin)
            ListTile(
              key: const Key('join-department-chat'),
              leading: const Icon(Icons.groups),
              title: const Text(_departmentChatName),
              trailing: ElevatedButton(
                onPressed: () async {
                  await context.read<ChatRepository>().joinDepartmentChat(widget.uid);
                },
                child: const Text('Unirme'),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: _myChatsStream,
              builder: (context, snapshot) {
                final chats = snapshot.data ?? const [];
                if (chats.isEmpty) {
                  return const Center(child: Text('Todavía no perteneces a ningún chat.'));
                }
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      title: Text(chat.name),
                      subtitle: Text(_kindLabels[chat.kind]!),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chat: chat,
                            uid: widget.uid,
                            displayName: widget.displayName,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
