import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/content_kind.dart';
import 'package:app_dcc_reports/domain/entities/content_post.dart';
import 'package:app_dcc_reports/domain/repositories/content_repository.dart';
import 'package:app_dcc_reports/presentation/content/content_detail_screen.dart';
import 'package:app_dcc_reports/presentation/content/content_form_screen.dart';
import 'package:app_dcc_reports/presentation/content/content_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository(this.posts);

  final List<ContentPost> posts;
  String? lastDeletedId;
  AccountRole? lastDeletedByRole;

  @override
  Stream<List<ContentPost>> watchPosts(ContentKind kind) =>
      Stream.value(posts.where((p) => p.kind == kind).toList());

  @override
  Future<String> create({
    required ContentKind kind,
    required String authorId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
  }) async => 'new-id';

  @override
  Future<void> update({
    required String postId,
    required AccountRole authorRole,
    required String title,
    required String body,
    String? localPhotoPath,
    bool removePhoto = false,
  }) async {}

  @override
  Future<void> delete({
    required String postId,
    required AccountRole authorRole,
  }) async {
    lastDeletedId = postId;
    lastDeletedByRole = authorRole;
  }
}

ContentPost _post({required ContentKind kind, String id = 'post-1', String? photoUrl}) {
  return ContentPost(
    id: id,
    kind: kind,
    title: 'Título $id',
    body: 'Cuerpo de $id con suficiente texto para el extracto.',
    photoUrl: photoUrl,
    authorId: 'admin-uid',
    createdAt: DateTime(2026, 9, 14),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeContentRepository repo,
  required AccountRole viewerRole,
  ContentKind kind = ContentKind.noticia,
}) {
  return tester.pumpWidget(
    Provider<ContentRepository>.value(
      value: repo,
      child: MaterialApp(
        home: ContentListScreen(kind: kind, viewerId: 'viewer-uid', viewerRole: viewerRole),
      ),
    ),
  );
}

void main() {
  testWidgets('admin ve el FAB de crear y los controles de editar/eliminar (RF-3)', (tester) async {
    final repo = _FakeContentRepository([_post(kind: ContentKind.noticia)]);
    await _pumpScreen(tester, repo: repo, viewerRole: AccountRole.admin);
    await tester.pump();

    expect(find.byKey(const Key('create-content-fab')), findsOneWidget);
    expect(find.byKey(const Key('edit-content-post-1')), findsOneWidget);
    expect(find.byKey(const Key('delete-content-post-1')), findsOneWidget);
  });

  testWidgets('un rol no-admin no ve ningún control de gestión (RF-4)', (tester) async {
    final repo = _FakeContentRepository([_post(kind: ContentKind.noticia)]);
    await _pumpScreen(tester, repo: repo, viewerRole: AccountRole.voluntario);
    await tester.pump();

    expect(find.byKey(const Key('create-content-fab')), findsNothing);
    expect(find.byKey(const Key('edit-content-post-1')), findsNothing);
    expect(find.byKey(const Key('delete-content-post-1')), findsNothing);
  });

  testWidgets('solo muestra publicaciones del kind pedido (RF-1/RF-2)', (tester) async {
    final repo = _FakeContentRepository([
      _post(kind: ContentKind.noticia, id: 'noticia-1'),
      _post(kind: ContentKind.preparate, id: 'preparate-1'),
    ]);
    await _pumpScreen(tester, repo: repo, viewerRole: AccountRole.voluntario, kind: ContentKind.noticia);
    await tester.pump();

    expect(find.byKey(const Key('content-post-noticia-1')), findsOneWidget);
    expect(find.byKey(const Key('content-post-preparate-1')), findsNothing);
  });

  testWidgets('tocar una publicación navega al detalle con el cuerpo completo (RF-1)', (tester) async {
    final repo = _FakeContentRepository([_post(kind: ContentKind.noticia)]);
    await _pumpScreen(tester, repo: repo, viewerRole: AccountRole.voluntario);
    await tester.pump();

    await tester.tap(find.byKey(const Key('content-post-post-1')));
    await tester.pumpAndSettle();

    expect(find.byType(ContentDetailScreen), findsOneWidget);
    expect(find.byKey(const Key('content-detail-body')), findsOneWidget);
  });

  testWidgets('lista vacía muestra el estado vacío sin error', (tester) async {
    final repo = _FakeContentRepository(const []);
    await _pumpScreen(tester, repo: repo, viewerRole: AccountRole.voluntario);
    await tester.pump();

    expect(find.text('Todavía no hay noticias.'), findsOneWidget);
  });

  testWidgets('admin toca el FAB y navega al formulario de creación (RF-3)', (tester) async {
    final repo = _FakeContentRepository(const []);
    await _pumpScreen(tester, repo: repo, viewerRole: AccountRole.admin);
    await tester.pump();

    await tester.tap(find.byKey(const Key('create-content-fab')));
    await tester.pumpAndSettle();

    expect(find.byType(ContentFormScreen), findsOneWidget);
  });

  testWidgets('admin elimina una publicación tras confirmar (RF-3)', (tester) async {
    final repo = _FakeContentRepository([_post(kind: ContentKind.noticia)]);
    await _pumpScreen(tester, repo: repo, viewerRole: AccountRole.admin);
    await tester.pump();

    await tester.tap(find.byKey(const Key('delete-content-post-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();

    expect(repo.lastDeletedId, 'post-1');
    expect(repo.lastDeletedByRole, AccountRole.admin);
  });
}
