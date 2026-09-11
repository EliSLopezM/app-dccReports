import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
import 'package:app_dcc_reports/presentation/register/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepository implements AuthRepository {
  AccountRole? lastRole;
  OrganizationInfo? lastOrganization;

  @override
  Future<String> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    required AccountRole role,
    required List<String> activeCourseIds,
    OrganizationInfo? organization,
  }) async {
    lastRole = role;
    lastOrganization = organization;
    return 'fake-uid';
  }

  @override
  Future<void> login({required String identifier, required String password}) async {}

  @override
  Future<void> logout() async {}

  @override
  Stream<String?> watchCurrentUid() => const Stream.empty();
}

Future<void> _pumpRegisterScreen(WidgetTester tester, _FakeAuthRepository repo) {
  return tester.pumpWidget(
    Provider<AuthRepository>.value(
      value: repo,
      child: const MaterialApp(home: RegisterScreen()),
    ),
  );
}

void main() {
  testWidgets('rol voluntario no muestra campos de organización (RF-3)', (tester) async {
    await _pumpRegisterScreen(tester, _FakeAuthRepository());

    expect(find.byKey(const Key('organization-section')), findsNothing);
  });

  testWidgets('cambiar a funcionario muestra los campos de organización (RF-2)', (tester) async {
    await _pumpRegisterScreen(tester, _FakeAuthRepository());

    await tester.tap(find.byKey(const Key('role-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Funcionario').last);
    await tester.pumpAndSettle();

    // El resto del formulario queda fuera del viewport del ListView en el
    // test (offstage) hasta que se desplaza; los finders por defecto
    // ignoran widgets offstage.
    final orgSection = find.byKey(const Key('organization-section'), skipOffstage: false);
    await tester.dragUntilVisible(orgSection, find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(orgSection, findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Nombre del grupo/comité'), findsOneWidget);
  });

  testWidgets('enviar con funcionario manda la organization al repositorio', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repo);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre completo'), 'Jane Doe');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo (opcional si das teléfono)'),
      'jane@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      '123456',
    );

    await tester.tap(find.byKey(const Key('role-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Funcionario').last);
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(ElevatedButton, 'Registrarme', skipOffstage: false);
    await tester.dragUntilVisible(submitButton, find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre del grupo/comité'),
      'Comité Suba',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Dirección de la sede principal'),
      'Cra 1 # 2-3',
    );

    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repo.lastRole, AccountRole.funcionario);
    expect(repo.lastOrganization?.name, 'Comité Suba');
  });
}
