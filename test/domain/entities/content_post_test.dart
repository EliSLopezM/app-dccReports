import 'package:app_dcc_reports/domain/entities/content_kind.dart';
import 'package:app_dcc_reports/domain/entities/content_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('se puede construir un ContentPost con foto', () {
    final post = ContentPost(
      id: 'post-1',
      kind: ContentKind.noticia,
      title: 'Simulacro de sismo',
      body: 'La DCC realizará un simulacro el próximo mes.',
      photoUrl: 'https://example.com/noticia.jpg',
      authorId: 'admin-uid',
      createdAt: DateTime(2026, 9, 14),
    );

    expect(post.kind, ContentKind.noticia);
    expect(post.photoUrl, isNotNull);
  });

  test('se puede construir un ContentPost sin foto (spec 007)', () {
    final post = ContentPost(
      id: 'post-2',
      kind: ContentKind.preparate,
      title: 'Cómo armar tu botiquín',
      body: 'Elementos básicos que no pueden faltar...',
      authorId: 'admin-uid',
      createdAt: DateTime(2026, 9, 14),
    );

    expect(post.kind, ContentKind.preparate);
    expect(post.photoUrl, isNull);
  });
}
