import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/content_kind.dart';
import '../../domain/entities/content_post.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/content_repository.dart';
import 'content_mapper.dart';

/// Sube la foto de una publicación (RF-3) y devuelve su URL pública.
typedef ContentPhotoUploader = Future<String> Function(
  String postId,
  String localPhotoPath,
);

class FirestoreContentRepositoryImpl implements ContentRepository {
  FirestoreContentRepositoryImpl(
    this._firestore, {
    ContentPhotoUploader? uploadPhoto,
    DateTime Function()? now,
    // ignore: prefer_initializing_formals
  })  : _uploadPhoto = uploadPhoto,
        _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final ContentPhotoUploader? _uploadPhoto;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection(contentPostsCollection);

  void _assertAdmin(AccountRole authorRole) {
    if (!authorRole.canManageContent) {
      throw NotAdminException();
    }
  }

  @override
  Stream<List<ContentPost>> watchPosts(ContentKind kind) {
    return _posts
        .where('kind', isEqualTo: kind.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => contentPostFromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<String> create({
    required ContentKind kind,
    required String authorId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
  }) async {
    _assertAdmin(authorRole);
    final doc = _posts.doc();
    final uploader = _uploadPhoto;
    final photoUrl = (localPhotoPath != null && uploader != null)
        ? await uploader(doc.id, localPhotoPath)
        : null;
    await doc.set(
      newContentPostToFirestore(
        kind: kind,
        title: title,
        body: body,
        photoUrl: photoUrl,
        authorId: authorId,
        createdAt: _now(),
      ),
    );
    return doc.id;
  }

  @override
  Future<void> update({
    required String postId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
    bool removePhoto = false,
  }) async {
    _assertAdmin(authorRole);
    final update = <String, dynamic>{'title': title, 'body': body};
    final uploader = _uploadPhoto;
    if (localPhotoPath != null && uploader != null) {
      update['photoUrl'] = await uploader(postId, localPhotoPath);
    } else if (removePhoto) {
      update['photoUrl'] = null;
    }
    await _posts.doc(postId).update(update);
  }

  @override
  Future<void> delete({
    required String postId,
    required AccountRole authorRole,
  }) async {
    _assertAdmin(authorRole);
    await _posts.doc(postId).delete();
  }
}
