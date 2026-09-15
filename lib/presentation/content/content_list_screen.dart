import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/content_kind.dart';
import '../../domain/entities/content_post.dart';
import '../../domain/repositories/content_repository.dart';
import 'content_detail_screen.dart';
import 'content_form_screen.dart';

const _titles = {
  ContentKind.noticia: 'Noticias',
  ContentKind.preparate: 'Prepárate',
};

const _emptyMessages = {
  ContentKind.noticia: 'Todavía no hay noticias.',
  ContentKind.preparate: 'Todavía no hay contenido de preparación.',
};

String _excerpt(String body) => body.length <= 120 ? body : '${body.substring(0, 120)}…';

/// RF-1, RF-2, RF-3, RF-4: lista de Noticias o Prepárate, parametrizada
/// por [kind]. Los controles de gestión solo aparecen si
/// `viewerRole.canManageContent` (RF-4: la restricción real vive en
/// `ContentRepository`, esto solo oculta la UI).
class ContentListScreen extends StatelessWidget {
  const ContentListScreen({
    super.key,
    required this.kind,
    required this.viewerId,
    required this.viewerRole,
  });

  final ContentKind kind;
  final String viewerId;
  final AccountRole viewerRole;

  Future<void> _delete(BuildContext context, ContentPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: Text('¿Eliminar "${post.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<ContentRepository>().delete(postId: post.id, authorRole: viewerRole);
  }

  @override
  Widget build(BuildContext context) {
    final canManage = viewerRole.canManageContent;
    return Scaffold(
      appBar: AppBar(title: Text(_titles[kind]!)),
      floatingActionButton: canManage
          ? FloatingActionButton(
              key: const Key('create-content-fab'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContentFormScreen(
                    kind: kind,
                    authorId: viewerId,
                    authorRole: viewerRole,
                  ),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<ContentPost>>(
        stream: context.read<ContentRepository>().watchPosts(kind),
        builder: (context, snapshot) {
          final posts = snapshot.data ?? const [];
          if (posts.isEmpty) {
            return Center(child: Text(_emptyMessages[kind]!));
          }
          return ListView(
            children: [
              for (final post in posts)
                ListTile(
                  key: Key('content-post-${post.id}'),
                  leading: post.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: post.photoUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : null,
                  title: Text(post.title),
                  subtitle: Text(_excerpt(post.body)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ContentDetailScreen(post: post)),
                  ),
                  trailing: canManage
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: Key('edit-content-${post.id}'),
                              icon: const Icon(Icons.edit),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ContentFormScreen(
                                    kind: kind,
                                    authorId: viewerId,
                                    authorRole: viewerRole,
                                    post: post,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              key: Key('delete-content-${post.id}'),
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(context, post),
                            ),
                          ],
                        )
                      : null,
                ),
            ],
          );
        },
      ),
    );
  }
}
