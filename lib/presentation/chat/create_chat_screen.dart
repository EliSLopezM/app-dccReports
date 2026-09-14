import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_kind.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/chat_repository.dart';

/// RF-7/RF-8/RF-9: solo funcionario — la entrada en HomeShell ya filtra
/// por rol.
class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key, required this.funcionarioId});

  final String funcionarioId;

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final _nameController = TextEditingController();
  String? _errorMessage;
  late final Stream<List<Chat>> _myCreatedChatsStream;

  @override
  void initState() {
    super.initState();
    _myCreatedChatsStream = context.read<ChatRepository>().watchMyChats(widget.funcionarioId).map(
          (chats) => chats
              .where((chat) => chat.kind == ChatKind.custom && chat.createdBy == widget.funcionarioId)
              .toList(),
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    try {
      await context.read<ChatRepository>().createCustomChat(
            name: name,
            createdBy: widget.funcionarioId,
            initialMemberIds: const [],
          );
      _nameController.clear();
      setState(() => _errorMessage = null);
    } on ChatLimitExceededException {
      setState(() => _errorMessage = 'Ya tienes 5 chats activos. Elimina uno para crear otro.');
    }
  }

  Future<void> _delete(String chatId) {
    return context.read<ChatRepository>().deleteChat(
          chatId: chatId,
          requesterId: widget.funcionarioId,
        );
  }

  Future<void> _pickMemberToAdd(BuildContext context, Chat chat) async {
    final accountRepository = context.read<AccountRepository>();
    final chatRepository = context.read<ChatRepository>();
    final accounts = await accountRepository.watchAllAccounts().first;
    final candidates = accounts
        .where((a) => !chat.memberIds.contains(a.id) && a.id != widget.funcionarioId)
        .toList();

    if (!context.mounted) return;
    final selected = await showModalBottomSheet<Account>(
      context: context,
      builder: (context) => ListView(
        children: [
          for (final account in candidates)
            ListTile(title: Text(account.name), onTap: () => Navigator.of(context).pop(account)),
        ],
      ),
    );

    if (selected != null) {
      await chatRepository.addMember(
        chatId: chat.id,
        requesterId: widget.funcionarioId,
        newMemberUid: selected.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis chats')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('new-chat-name-field'),
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del nuevo chat'),
                  ),
                ),
                IconButton(
                  key: const Key('create-chat-button'),
                  icon: const Icon(Icons.add),
                  onPressed: _create,
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                key: const Key('create-chat-error'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: _myCreatedChatsStream,
              builder: (context, snapshot) {
                final chats = snapshot.data ?? const [];
                if (chats.isEmpty) {
                  return const Center(child: Text('Todavía no has creado ningún chat.'));
                }
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      title: Text(chat.name),
                      subtitle: Text('${chat.memberIds.length} miembro(s)'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_add),
                            tooltip: 'Agregar miembro',
                            onPressed: () => _pickMemberToAdd(context, chat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Eliminar chat',
                            onPressed: () => _delete(chat.id),
                          ),
                        ],
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
