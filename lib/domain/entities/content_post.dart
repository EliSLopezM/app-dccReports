import 'content_kind.dart';

/// RF-1, RF-2 (spec 007): una publicación de Noticias o Prepárate.
class ContentPost {
  final String id;
  final ContentKind kind;
  final String title;
  final String body;
  final String? photoUrl;
  final String authorId;
  final DateTime createdAt;

  const ContentPost({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.photoUrl,
    required this.authorId,
    required this.createdAt,
  });
}
