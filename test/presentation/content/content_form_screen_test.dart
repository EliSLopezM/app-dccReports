import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/content_kind.dart';
import 'package:app_dcc_reports/domain/entities/content_post.dart';
import 'package:app_dcc_reports/domain/repositories/content_repository.dart';
import 'package:app_dcc_reports/presentation/content/content_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeContentRepository implements ContentRepository {
  bool createCalled = false;
  bool updateCalled = false;
  String? lastTitle;
  String? lastBody;
  String? lastLocalPhotoPath;
  bool? lastRemovePhoto;

  @override
  Stream<List<ContentPost>> watchPosts(ContentKind kind) => Stream.value(const []);

  @override
  Future<String> create({
    required ContentKind kind,
    required String authorId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
  }) async {
    createCalled = true;
    lastTitle = title;
    lastBody = body;
    lastLocalPhotoPath = localPhotoPath;
    return 'new-id';
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
    updateCalled = true;
    lastTitle = title;
    lastBody = body;
    lastLocalPhotoPath = localPhotoPath;
    lastRemovePhoto = removePhoto;
  }

  @override
  Future<void> delete({required String postId, required AccountRole authorRole}) async {}
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeContentRepository repo,
  ContentPost? post,
  PickImage pickImage = defaultPickImage,
}) {
  return tester.pumpWidget(
    Provider<ContentRepository>.value(
      value: repo,
      child: MaterialApp(
        home: ContentFormScreen(
          kind: ContentKind.noticia,
          authorId: 'admin-uid',
          authorRole: AccountRole.admin,
          post: post,
          pickImage: pickImage,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('crear con título/cuerpo llama a create (RF-3)', (tester) async {
    final repo = _FakeContentRepository();
    await _pumpScreen(tester, repo: repo);
    await tester.pump();

    await tester.enterText(find.byKey(const Key('content-form-title')), 'Nueva noticia');
    await tester.enterText(find.byKey(const Key('content-form-body')), 'Cuerpo de la noticia');
    await tester.tap(find.byKey(const Key('content-form-submit')));
    await tester.pumpAndSettle();

    expect(repo.createCalled, isTrue);
    expect(repo.lastTitle, 'Nueva noticia');
    expect(repo.lastBody, 'Cuerpo de la noticia');
  });

  testWidgets('crear sin título se bloquea', (tester) async {
    final repo = _FakeContentRepository();
    await _pumpScreen(tester, repo: repo);
    await tester.pump();

    await tester.enterText(find.byKey(const Key('content-form-body')), 'Cuerpo');
    await tester.tap(find.byKey(const Key('content-form-submit')));
    await tester.pumpAndSettle();

    expect(repo.createCalled, isFalse);
  });

  testWidgets('elegir una foto y publicar la manda como localPhotoPath (RF-3)', (tester) async {
    final repo = _FakeContentRepository();
    await _pumpScreen(tester, repo: repo, pickImage: (_) async => '/tmp/foto.jpg');
    await tester.pump();

    await tester.enterText(find.byKey(const Key('content-form-title')), 'Con foto');
    await tester.enterText(find.byKey(const Key('content-form-body')), 'Cuerpo');
    await tester.tap(find.byIcon(Icons.add_a_photo));
    await tester.pump();
    await tester.tap(find.byKey(const Key('content-form-submit')));
    await tester.pumpAndSettle();

    expect(repo.lastLocalPhotoPath, '/tmp/foto.jpg');
  });

  testWidgets('editar una publicación existente precarga sus datos y llama a update', (tester) async {
    final repo = _FakeContentRepository();
    final post = ContentPost(
      id: 'post-1',
      kind: ContentKind.noticia,
      title: 'Original',
      body: 'Cuerpo original',
      photoUrl: 'https://example.com/a.jpg',
      authorId: 'admin-uid',
      createdAt: DateTime(2026, 9, 14),
    );
    await _pumpScreen(tester, repo: repo, post: post);
    await tester.pump();

    expect(find.text('Original'), findsOneWidget);
    expect(find.text('Cuerpo original'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('content-form-title')), 'Editado');
    await tester.tap(find.byKey(const Key('content-form-submit')));
    await tester.pumpAndSettle();

    expect(repo.updateCalled, isTrue);
    expect(repo.lastTitle, 'Editado');
    expect(repo.lastLocalPhotoPath, isNull);
    expect(repo.lastRemovePhoto, isFalse);
  });

  testWidgets('quitar la foto y guardar manda removePhoto true', (tester) async {
    final repo = _FakeContentRepository();
    final post = ContentPost(
      id: 'post-1',
      kind: ContentKind.noticia,
      title: 'Original',
      body: 'Cuerpo original',
      photoUrl: 'https://example.com/a.jpg',
      authorId: 'admin-uid',
      createdAt: DateTime(2026, 9, 14),
    );
    await _pumpScreen(tester, repo: repo, post: post);
    await tester.pump();

    await tester.tap(find.byKey(const Key('content-form-remove-photo')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('content-form-submit')));
    await tester.pumpAndSettle();

    expect(repo.lastRemovePhoto, isTrue);
  });
}
