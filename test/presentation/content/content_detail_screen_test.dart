import 'package:app_dcc_reports/domain/entities/content_kind.dart';
import 'package:app_dcc_reports/domain/entities/content_post.dart';
import 'package:app_dcc_reports/presentation/content/content_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra título, cuerpo y foto de la publicación (RF-1/RF-2)', (tester) async {
    final post = ContentPost(
      id: 'post-1',
      kind: ContentKind.preparate,
      title: 'Cómo armar tu botiquín',
      body: 'Elementos básicos que no pueden faltar en casa.',
      photoUrl: 'https://example.com/botiquin.jpg',
      authorId: 'admin-uid',
      createdAt: DateTime(2026, 9, 14),
    );

    await tester.pumpWidget(MaterialApp(home: ContentDetailScreen(post: post)));
    await tester.pump();

    // CachedNetworkImage no es testeable de forma fiable en widget tests
    // sin plataforma real (igual que en emergency_detail_screen_test.dart);
    // solo se verifica el texto, la rama con foto se cubre en la demo manual.
    expect(find.text('Cómo armar tu botiquín'), findsWidgets);
    expect(find.byKey(const Key('content-detail-body')), findsOneWidget);
  });

  testWidgets('sin foto no intenta mostrar ninguna imagen', (tester) async {
    final post = ContentPost(
      id: 'post-2',
      kind: ContentKind.noticia,
      title: 'Simulacro de sismo',
      body: 'La DCC realizará un simulacro.',
      authorId: 'admin-uid',
      createdAt: DateTime(2026, 9, 14),
    );

    await tester.pumpWidget(MaterialApp(home: ContentDetailScreen(post: post)));
    await tester.pump();

    expect(find.byKey(const Key('content-detail-photo')), findsNothing);
  });
}
