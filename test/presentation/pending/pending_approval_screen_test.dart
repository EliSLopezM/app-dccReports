import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
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

Future<void> _pumpPendingScreen(WidgetTester tester, AccountStatus status) {
  return tester.pumpWidget(
    Provider<AuthRepository>.value(
      value: _FakeAuthRepository(),
      child: MaterialApp(home: PendingApprovalScreen(status: status)),
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

  testWidgets('tocar Noticias navega al stub de Noticias', (tester) async {
    await _pumpPendingScreen(tester, AccountStatus.pending);

    await tester.tap(find.text('Noticias'));
    await tester.pumpAndSettle();

    expect(find.text('Próximamente'), findsOneWidget);
  });

  testWidgets('cuenta rechazada muestra el mensaje correspondiente', (tester) async {
    await _pumpPendingScreen(tester, AccountStatus.rejected);

    expect(find.textContaining('rechazada'), findsOneWidget);
  });
}
