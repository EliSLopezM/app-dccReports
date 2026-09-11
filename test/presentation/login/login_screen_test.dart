import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
import 'package:app_dcc_reports/presentation/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.shouldThrowInvalidCredentials = false});

  final bool shouldThrowInvalidCredentials;
  String? lastIdentifier;

  @override
  Future<void> login({required String identifier, required String password}) async {
    lastIdentifier = identifier;
    if (shouldThrowInvalidCredentials) throw InvalidCredentialsException();
  }

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

Future<void> _pumpLoginScreen(WidgetTester tester, _FakeAuthRepository repo) {
  return tester.pumpWidget(
    Provider<AuthRepository>.value(
      value: repo,
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
}

void main() {
  testWidgets('login correcto no muestra error (RF-9)', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpLoginScreen(tester, repo);

    await tester.enterText(find.byKey(const Key('identifier-field')), 'jane@example.com');
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error')), findsNothing);
    expect(repo.lastIdentifier, 'jane@example.com');
  });

  testWidgets('credenciales incorrectas muestran mensaje genérico (RF-10)', (tester) async {
    final repo = _FakeAuthRepository(shouldThrowInvalidCredentials: true);
    await _pumpLoginScreen(tester, repo);

    await tester.enterText(find.byKey(const Key('identifier-field')), 'jane@example.com');
    await tester.enterText(find.byKey(const Key('password-field')), 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(find.text('Correo/teléfono o contraseña incorrectos.'), findsOneWidget);
  });
}
