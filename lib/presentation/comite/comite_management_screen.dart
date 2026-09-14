import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/comite.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/comite_repository.dart';

/// RF-5: solo el líder de [comite] entra aquí (la entrada en HomeShell ya
/// filtra por `leaderId == account.id`).
class ComiteManagementScreen extends StatelessWidget {
  const ComiteManagementScreen({super.key, required this.comite, required this.requesterId});

  final Comite comite;
  final String requesterId;

  Future<void> _assignDelegate(BuildContext context, String delegateId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<ComiteRepository>().setDelegate(
            comiteId: comite.id,
            requesterId: requesterId,
            delegateId: delegateId,
          );
    } on NotComiteLeaderException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Solo el líder del comité puede asignar delegado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(comite.name)),
      body: StreamBuilder<Comite?>(
        stream: context.read<ComiteRepository>().watchComite(comite.id),
        initialData: comite,
        builder: (context, comiteSnapshot) {
          final currentComite = comiteSnapshot.data ?? comite;
          return StreamBuilder<Chat?>(
            stream: context.read<ChatRepository>().watchChatByComite(comite.id),
            builder: (context, chatSnapshot) {
              final memberIds = chatSnapshot.data?.memberIds ?? const [];
              if (memberIds.isEmpty) {
                return const Center(child: Text('Todavía no hay miembros en este comité.'));
              }
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      currentComite.delegateId == null
                          ? 'Sin delegado asignado todavía.'
                          : 'Delegado actual: ${currentComite.delegateId}',
                      key: const Key('current-delegate'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Miembros', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  for (final memberId in memberIds)
                    // Se muestra el uid, no el nombre: AccountRepository no
                    // tiene una búsqueda por lote de varios ids todavía.
                    ListTile(
                      title: Text(memberId),
                      trailing: currentComite.delegateId == memberId
                          ? const Icon(Icons.star, color: Colors.amber)
                          : TextButton(
                              onPressed: () => _assignDelegate(context, memberId),
                              child: const Text('Hacer delegado'),
                            ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
