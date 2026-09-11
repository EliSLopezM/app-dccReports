import 'package:app_dcc_reports/data/firebase/firebase_auth_repository_impl.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('register (T4, RF-2)', () {
    test('crea el usuario en Auth y el documento accounts/{uid} pendiente', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final repository = FirebaseAuthRepositoryImpl(auth, firestore);

      final uid = await repository.register(
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: '123456',
        role: AccountRole.voluntario,
        activeCourseIds: const ['primeros_auxilios'],
      );

      expect(uid, isNotEmpty);
      final doc = await firestore.collection('accounts').doc(uid).get();
      expect(doc.data()!['status'], 'pending');
      expect(doc.data()!['role'], 'voluntario');
    });

    test('registro con teléfono guarda el teléfono real, no el correo sintético', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final repository = FirebaseAuthRepositoryImpl(auth, firestore);

      final uid = await repository.register(
        name: 'John Doe',
        phone: '3001234567',
        password: '123456',
        role: AccountRole.funcionario,
        activeCourseIds: const [],
        organization: const OrganizationInfo(name: 'Comité Suba', address: 'Cra 1 # 2-3'),
      );

      final doc = await firestore.collection('accounts').doc(uid).get();
      expect(doc.data()!['phone'], '3001234567');
      expect(doc.data()!['email'], isNull);
    });

    test('correo ya usado lanza DuplicateAccountException', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      whenCalling(
        Invocation.method(#createUserWithEmailAndPassword, null,
            {#email: anything, #password: anything}),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      final repository = FirebaseAuthRepositoryImpl(auth, firestore);

      expect(
        () => repository.register(
          name: 'Jane Doe',
          email: 'jane@example.com',
          password: '123456',
          role: AccountRole.voluntario,
          activeCourseIds: const [],
        ),
        throwsA(isA<DuplicateAccountException>()),
      );
    });
  });

  group('login (T5, RF-9/RF-10)', () {
    test('login correcto no lanza', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final repository = FirebaseAuthRepositoryImpl(auth, firestore);

      await expectLater(
        repository.login(identifier: 'jane@example.com', password: '123456'),
        completes,
      );
    });

    test('credenciales incorrectas lanzan InvalidCredentialsException', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      whenCalling(
        Invocation.method(#signInWithEmailAndPassword, null,
            {#email: anything, #password: anything}),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'invalid-credential'));
      final repository = FirebaseAuthRepositoryImpl(auth, firestore);

      expect(
        () => repository.login(identifier: 'jane@example.com', password: 'wrong'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('login con teléfono normaliza a correo sintético', () async {
      expect(
        authEmailFor(phone: '+57 300 123 4567'),
        '573001234567@phone.dccbogota.app',
      );
    });
  });
}
