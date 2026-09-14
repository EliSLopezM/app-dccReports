import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/comite.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/repositories/account_repository.dart';
import 'package:app_dcc_reports/domain/repositories/auth_repository.dart';
import 'package:app_dcc_reports/domain/repositories/comite_repository.dart';
import 'package:app_dcc_reports/domain/repositories/location_repository.dart';
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
  Future<void> login({
    required String identifier,
    required String password,
  }) async {}

  @override
  Future<void> logout() async {}

  @override
  Stream<String?> watchCurrentUid() => const Stream.empty();
}

class _FakeAccountRepository implements AccountRepository {
  String? lastComiteUid;
  String? lastComiteId;

  @override
  Future<void> setComite({
    required String uid,
    required String comiteId,
  }) async {
    lastComiteUid = uid;
    lastComiteId = comiteId;
  }

  @override
  Stream<Account?> watchAccount(String uid) => Stream.value(null);

  @override
  Stream<List<Account>> watchAllAccounts() => Stream.value(const []);

  @override
  Stream<List<Account>> watchPendingAccounts() => Stream.value(const []);

  @override
  Future<void> approve({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
  }) async {}

  @override
  Future<void> reject({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
    String? reason,
  }) async {}
}

class _FakeComiteRepository implements ComiteRepository {
  _FakeComiteRepository({this.existingComites = const []});

  final List<Comite> existingComites;
  String? lastCreatedName;
  String? lastCreatedAddress;
  String? lastCreatedLeaderId;
  double? lastCreatedLatitude;
  double? lastCreatedLongitude;

  @override
  Future<String> create({
    required String name,
    required String address,
    required String leaderId,
    double? latitude,
    double? longitude,
  }) async {
    lastCreatedName = name;
    lastCreatedAddress = address;
    lastCreatedLeaderId = leaderId;
    lastCreatedLatitude = latitude;
    lastCreatedLongitude = longitude;
    return 'new-comite-id';
  }

  @override
  Stream<List<Comite>> watchNearbyComites({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) => Stream.value(const []);

  @override
  Stream<List<Comite>> watchAllComites() => Stream.value(existingComites);

  @override
  Stream<Comite?> watchComite(String comiteId) => Stream.value(null);

  @override
  Future<void> setDelegate({
    required String comiteId,
    required String requesterId,
    required String delegateId,
  }) async {}
}

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository({this.result});

  final ({double latitude, double longitude})? result;

  @override
  Future<({double latitude, double longitude})?> getCurrentLocation() async =>
      result;
}

Future<void> _pumpRegisterScreen(
  WidgetTester tester,
  _FakeAuthRepository authRepo, {
  _FakeAccountRepository? accountRepo,
  _FakeComiteRepository? comiteRepo,
  _FakeLocationRepository? locationRepo,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepo),
        Provider<AccountRepository>.value(
          value: accountRepo ?? _FakeAccountRepository(),
        ),
        Provider<ComiteRepository>.value(
          value: comiteRepo ?? _FakeComiteRepository(),
        ),
        Provider<LocationRepository>.value(
          value: locationRepo ?? _FakeLocationRepository(),
        ),
      ],
      child: const MaterialApp(home: RegisterScreen()),
    ),
  );
}

void main() {
  testWidgets('rol voluntario no muestra campos de organización (RF-3)', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester, _FakeAuthRepository());

    expect(find.byKey(const Key('organization-section')), findsNothing);
  });

  testWidgets('rol voluntario muestra el selector de comité (RF-2, spec 004)', (
    tester,
  ) async {
    await _pumpRegisterScreen(tester, _FakeAuthRepository());

    expect(
      find.byKey(const Key('no-comites-message'), skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets(
    'cambiar a funcionario muestra los campos de organización (RF-2)',
    (tester) async {
      await _pumpRegisterScreen(tester, _FakeAuthRepository());

      await tester.tap(find.byKey(const Key('role-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Funcionario').last);
      await tester.pumpAndSettle();

      // El resto del formulario queda fuera del viewport del ListView en el
      // test (offstage) hasta que se desplaza; los finders por defecto
      // ignoran widgets offstage.
      final orgSection = find.byKey(
        const Key('organization-section'),
        skipOffstage: false,
      );
      await tester.dragUntilVisible(
        orgSection,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(orgSection, findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Nombre del grupo/comité'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('no-comites-message')), findsNothing);
    },
  );

  testWidgets(
    'enviar con funcionario funda un comité nuevo con ubicación (RF-1, spec 004; RF-13, spec 004 Enmienda 1)',
    (tester) async {
      final authRepo = _FakeAuthRepository();
      final accountRepo = _FakeAccountRepository();
      final comiteRepo = _FakeComiteRepository();
      final locationRepo = _FakeLocationRepository(
        result: (latitude: 4.6, longitude: -74.1),
      );
      await _pumpRegisterScreen(
        tester,
        authRepo,
        accountRepo: accountRepo,
        comiteRepo: comiteRepo,
        locationRepo: locationRepo,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre completo'),
        'Jane Doe',
      );
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

      final submitButton = find.widgetWithText(
        ElevatedButton,
        'Registrarme',
        skipOffstage: false,
      );
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -300),
      );
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

      expect(authRepo.lastRole, AccountRole.funcionario);
      expect(authRepo.lastOrganization?.name, 'Comité Suba');
      expect(comiteRepo.lastCreatedName, 'Comité Suba');
      expect(comiteRepo.lastCreatedLeaderId, 'fake-uid');
      expect(accountRepo.lastComiteId, 'new-comite-id');
      expect(comiteRepo.lastCreatedLatitude, 4.6);
      expect(comiteRepo.lastCreatedLongitude, -74.1);
    },
  );

  testWidgets(
    'voluntario elige un comité existente y se manda a setComite (RF-2)',
    (tester) async {
      final authRepo = _FakeAuthRepository();
      final accountRepo = _FakeAccountRepository();
      final comite = Comite(
        id: 'comite-1',
        name: 'Comité Suba',
        address: 'Cra 1 # 2-3',
        leaderId: 'leader-uid',
        createdAt: DateTime(2026, 9, 14),
      );
      final comiteRepo = _FakeComiteRepository(existingComites: [comite]);
      await _pumpRegisterScreen(
        tester,
        authRepo,
        accountRepo: accountRepo,
        comiteRepo: comiteRepo,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre completo'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo (opcional si das teléfono)'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123456',
      );

      final comiteDropdown = find.byKey(
        const Key('comite-dropdown'),
        skipOffstage: false,
      );
      await tester.dragUntilVisible(
        comiteDropdown,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      await tester.tap(comiteDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comité Suba').last);
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(
        ElevatedButton,
        'Registrarme',
        skipOffstage: false,
      );
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(accountRepo.lastComiteId, 'comite-1');
      expect(accountRepo.lastComiteUid, 'fake-uid');
    },
  );
}
