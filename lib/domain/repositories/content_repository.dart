import '../entities/account_role.dart';
import '../entities/content_kind.dart';
import '../entities/content_post.dart';
import '../exceptions.dart';

/// RF-1 a RF-4 (spec 007): publicaciones de Noticias y Prepárate.
abstract class ContentRepository {
  Stream<List<ContentPost>> watchPosts(ContentKind kind);

  /// RF-3/RF-4: lanza [NotAdminException] si [authorRole] no es
  /// `AccountRole.admin`.
  Future<String> create({
    required ContentKind kind,
    required String authorId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
  });

  /// RF-3/RF-4: lanza [NotAdminException] si [authorRole] no es
  /// `AccountRole.admin`. Si [localPhotoPath] es null y [removePhoto] es
  /// false, conserva la foto existente; [removePhoto] la borra.
  Future<void> update({
    required String postId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
    bool removePhoto = false,
  });

  /// RF-3/RF-4: lanza [NotAdminException] si [authorRole] no es
  /// `AccountRole.admin`.
  Future<void> delete({
    required String postId,
    required AccountRole authorRole,
  });
}
