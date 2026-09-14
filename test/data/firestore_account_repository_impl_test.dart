import 'package:app_dcc_reports/data/firebase/firestore_account_repository_impl.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> _seedAccount(
  FakeFirebaseFirestore firestore, {
  required AccountRole role,
  required String status,
}) async {
  final doc = await firestore.collection('accounts').add({
    'name': 'Test User',
    'email': 'test-${role.name}-$status@example.com',
    'phone': null,
    'role': role.name,
    'status': status,
    'activeCourseIds': <String>[],
    'organization': null,
    'createdAt': Timestamp.now(),
    'reviewedBy': null,
    'reviewedAt': null,
  });
  return doc.id;
}

void main() {
  group('lectura (T6, RF-4/RF-11/RF-12)', () {
    test('watchAllAccounts trae cuentas de los 3 estados', () async {
      final firestore = FakeFirebaseFirestore();
      await _seedAccount(firestore, role: AccountRole.voluntario, status: 'pending');
      await _seedAccount(firestore, role: AccountRole.voluntario, status: 'approved');
      await _seedAccount(firestore, role: AccountRole.voluntario, status: 'rejected');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      final accounts = await repository.watchAllAccounts().first;

      expect(accounts, hasLength(3));
    });

    test('watchPendingAccounts solo trae las pendientes', () async {
      final firestore = FakeFirebaseFirestore();
      await _seedAccount(firestore, role: AccountRole.voluntario, status: 'pending');
      await _seedAccount(firestore, role: AccountRole.voluntario, status: 'approved');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      final accounts = await repository.watchPendingAccounts().first;

      expect(accounts, hasLength(1));
      expect(accounts.single.status.name, 'pending');
    });

    test('watchAccount trae null si no existe', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = FirestoreAccountRepositoryImpl(firestore);

      final account = await repository.watchAccount('no-existe').first;

      expect(account, isNull);
    });
  });

  group('aprobar/rechazar (T7, RF-6/RF-7/RF-8)', () {
    test('Admin aprueba una cuenta de funcionario', () async {
      final firestore = FakeFirebaseFirestore();
      final accountId =
          await _seedAccount(firestore, role: AccountRole.funcionario, status: 'pending');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      await repository.approve(
        reviewerRole: AccountRole.admin,
        reviewerId: 'admin-uid',
        accountId: accountId,
      );

      final doc = await firestore.collection('accounts').doc(accountId).get();
      expect(doc.data()!['status'], 'approved');
      expect(doc.data()!['reviewedBy'], 'admin-uid');
    });

    test('Funcionario NO puede aprobar a otro funcionario (RF-7)', () async {
      final firestore = FakeFirebaseFirestore();
      final accountId =
          await _seedAccount(firestore, role: AccountRole.funcionario, status: 'pending');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      expect(
        () => repository.approve(
          reviewerRole: AccountRole.funcionario,
          reviewerId: 'reviewer-uid',
          accountId: accountId,
        ),
        throwsA(isA<InsufficientReviewPermissionException>()),
      );
    });

    test('Funcionario SÍ puede aprobar a un voluntario', () async {
      final firestore = FakeFirebaseFirestore();
      final accountId =
          await _seedAccount(firestore, role: AccountRole.voluntario, status: 'pending');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      await repository.approve(
        reviewerRole: AccountRole.funcionario,
        reviewerId: 'reviewer-uid',
        accountId: accountId,
      );

      final doc = await firestore.collection('accounts').doc(accountId).get();
      expect(doc.data()!['status'], 'approved');
    });

    test('rechazo marca status rejected', () async {
      final firestore = FakeFirebaseFirestore();
      final accountId =
          await _seedAccount(firestore, role: AccountRole.voluntario, status: 'pending');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      await repository.reject(
        reviewerRole: AccountRole.admin,
        reviewerId: 'admin-uid',
        accountId: accountId,
        reason: 'Datos incompletos',
      );

      final doc = await firestore.collection('accounts').doc(accountId).get();
      expect(doc.data()!['status'], 'rejected');
      expect(doc.data()!['rejectionReason'], 'Datos incompletos');
    });

    test('voluntario NO puede aprobar (no tiene canReviewAccounts)', () async {
      final firestore = FakeFirebaseFirestore();
      final accountId =
          await _seedAccount(firestore, role: AccountRole.voluntario, status: 'pending');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      expect(
        () => repository.approve(
          reviewerRole: AccountRole.voluntario,
          reviewerId: 'someone',
          accountId: accountId,
        ),
        throwsA(isA<InsufficientReviewPermissionException>()),
      );
    });
  });

  group('setComite (spec 004, RF-1/RF-2)', () {
    test('fija el comiteId de la cuenta', () async {
      final firestore = FakeFirebaseFirestore();
      final accountId = await _seedAccount(firestore, role: AccountRole.voluntario, status: 'pending');
      final repository = FirestoreAccountRepositoryImpl(firestore);

      await repository.setComite(uid: accountId, comiteId: 'comite-1');

      final doc = await firestore.collection('accounts').doc(accountId).get();
      expect(doc.data()!['comiteId'], 'comite-1');
    });
  });
}
