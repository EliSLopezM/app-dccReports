import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/content_kind.dart';
import 'package:app_dcc_reports/domain/entities/content_post.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
import 'package:app_dcc_reports/domain/repositories/content_repository.dart';
import 'package:app_dcc_reports/presentation/content/content_list_screen.dart';
import 'package:app_dcc_reports/presentation/pending/pending_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login({required String identifier, required String password}) async {}

  @override
  Future<String> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    required AccountRole role,
    required List<String> activeCourseIds,
    OrganizationInfo? organization,
  }) async =>
      'fake-uid';

  @override
  Future<void> logout() async {}

  @override
  Stream<String?> watchCurrentUid() => const Stream.empty();
}

class _FakeContentRepository implements ContentRepository {
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
  }) async =>
      'id';

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
  Future<void> delete({required String postId, required AccountRole authorRole}) async {}
}

Account _account(AccountStatus status) {
  return Account(
    id: 'uid-1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: AccountRole.voluntario,
    status: status,
    createdAt: DateTime(2026, 9, 11),
  );
}

Future<void> _pumpPendingScreen(WidgetTester tester, AccountStatus status) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _FakeAuthRepository()),
        Provider<ContentRepository>.value(value: _FakeContentRepository()),
      ],
      child: MaterialApp(home: PendingApprovalScreen(account: _account(status))),
    ),
  );
}

void main() {
  testWidgets('muestra los 3 accesos de contenido público y ningún acceso a Home/Panel (RF-4)',
      (tester) async {
    await _pumpPendingScreen(tester, AccountStatus.pending);

    expect(find.text('Noticias'), findsOneWidget);
    expect(find.text('Capacítate'), findsOneWidget);
    expect(find.text('Prepárate'), findsOneWidget);
    expect(find.textContaining('Mapa'), findsNothing);
    expect(find.textContaining('Panel'), findsNothing);
  });

  testWidgets('tocar Noticias navega a la pantalla real de Noticias (spec 007)', (tester) async {
    await _pumpPendingScreen(tester, AccountStatus.pending);

    await tester.tap(find.text('Noticias'));
    await tester.pumpAndSettle();

    expect(find.byType(ContentListScreen), findsOneWidget);
  });

  testWidgets('cuenta rechazada muestra el mensaje correspondiente', (tester) async {
    await _pumpPendingScreen(tester, AccountStatus.rejected);

    expect(find.textContaining('rechazada'), findsOneWidget);
  });
}
