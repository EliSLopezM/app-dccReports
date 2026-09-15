import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/content_kind.dart';
import '../../domain/entities/content_post.dart';

const contentPostsCollection = 'content_posts';

Map<String, dynamic> newContentPostToFirestore({
  required ContentKind kind,
  required String title,
  required String body,
  String? photoUrl,
  required String authorId,
  required DateTime createdAt,
}) {
  return {
    'kind': kind.name,
    'title': title,
    'body': body,
    'photoUrl': photoUrl,
    'authorId': authorId,
    // Reloj inyectable (no FieldValue.serverTimestamp()) para que el
    // orden por fecha sea determinístico en tests con fake_cloud_firestore.
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

ContentPost contentPostFromFirestore(String id, Map<String, dynamic> data) {
  return ContentPost(
    id: id,
    kind: ContentKind.values.byName(data['kind'] as String),
    title: data['title'] as String,
    body: data['body'] as String,
    photoUrl: data['photoUrl'] as String?,
    authorId: data['authorId'] as String,
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
