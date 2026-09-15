import 'package:app_dcc_reports/data/firebase/firestore_content_repository_impl.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/content_kind.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> _uploader(String postId, String localPath) async =>
    'https://storage.example/$postId.jpg';

void main() {
  group('watchPosts (T3, RF-1/RF-2)', () {
    test('filtra por kind y ordena por createdAt descendente', () async {
      final firestore = FakeFirebaseFirestore();
      var now = DateTime(2026, 9, 14, 10);
      final repo = FirestoreContentRepositoryImpl(firestore, now: () => now);

      await repo.create(
        kind: ContentKind.noticia,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'Noticia vieja',
        body: 'Cuerpo 1',
      );
      now = now.add(const Duration(hours: 1));
      await repo.create(
        kind: ContentKind.noticia,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'Noticia nueva',
        body: 'Cuerpo 2',
      );
      await repo.create(
        kind: ContentKind.preparate,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'Botiquín',
        body: 'Cuerpo 3',
      );

      final noticias = await repo.watchPosts(ContentKind.noticia).first;

      expect(noticias, hasLength(2));
      expect(noticias.first.title, 'Noticia nueva');
      expect(noticias.last.title, 'Noticia vieja');
    });
  });

  group('create/update/delete (T4, RF-3/RF-4)', () {
    test('admin crea una publicación con foto', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreContentRepositoryImpl(firestore, uploadPhoto: _uploader);

      final id = await repo.create(
        kind: ContentKind.preparate,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'RCP para bebés',
        body: 'Pasos a seguir...',
        localPhotoPath: '/tmp/rcp.jpg',
      );

      final doc = await firestore.collection('content_posts').doc(id).get();
      expect(doc.data()!['photoUrl'], 'https://storage.example/$id.jpg');
    });

    test('un rol distinto de admin no puede crear', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreContentRepositoryImpl(firestore);

      expect(
        () => repo.create(
          kind: ContentKind.noticia,
          authorId: 'uid-1',
          authorRole: AccountRole.funcionario,
          title: 'Intento',
          body: 'Cuerpo',
        ),
        throwsA(isA<NotAdminException>()),
      );

      final all = await firestore.collection('content_posts').get();
      expect(all.docs, isEmpty);
    });

    test('editar sin tocar la foto la conserva', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreContentRepositoryImpl(firestore, uploadPhoto: _uploader);
      final id = await repo.create(
        kind: ContentKind.noticia,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'Original',
        body: 'Cuerpo original',
        localPhotoPath: '/tmp/a.jpg',
      );

      await repo.update(
        postId: id,
        authorRole: AccountRole.admin,
        title: 'Editado',
        body: 'Cuerpo editado',
      );

      final doc = await firestore.collection('content_posts').doc(id).get();
      expect(doc.data()!['title'], 'Editado');
      expect(doc.data()!['photoUrl'], 'https://storage.example/$id.jpg');
    });

    test('editar con removePhoto la borra', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreContentRepositoryImpl(firestore, uploadPhoto: _uploader);
      final id = await repo.create(
        kind: ContentKind.noticia,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'Original',
        body: 'Cuerpo original',
        localPhotoPath: '/tmp/a.jpg',
      );

      await repo.update(
        postId: id,
        authorRole: AccountRole.admin,
        title: 'Original',
        body: 'Cuerpo original',
        removePhoto: true,
      );

      final doc = await firestore.collection('content_posts').doc(id).get();
      expect(doc.data()!['photoUrl'], isNull);
    });

    test('un rol distinto de admin no puede editar ni eliminar', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreContentRepositoryImpl(firestore, uploadPhoto: _uploader);
      final id = await repo.create(
        kind: ContentKind.noticia,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'Original',
        body: 'Cuerpo original',
      );

      expect(
        () => repo.update(
          postId: id,
          authorRole: AccountRole.lider,
          title: 'Hackeado',
          body: 'Hackeado',
        ),
        throwsA(isA<NotAdminException>()),
      );
      expect(
        () => repo.delete(postId: id, authorRole: AccountRole.voluntario),
        throwsA(isA<NotAdminException>()),
      );

      final doc = await firestore.collection('content_posts').doc(id).get();
      expect(doc.data()!['title'], 'Original');
    });

    test('admin elimina una publicación', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreContentRepositoryImpl(firestore);
      final id = await repo.create(
        kind: ContentKind.noticia,
        authorId: 'admin-uid',
        authorRole: AccountRole.admin,
        title: 'A borrar',
        body: 'Cuerpo',
      );

      await repo.delete(postId: id, authorRole: AccountRole.admin);

      final doc = await firestore.collection('content_posts').doc(id).get();
      expect(doc.exists, isFalse);
    });
  });
}
