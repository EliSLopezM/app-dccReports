import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/organization_info.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import 'account_mapper.dart';

const _invalidCredentialCodes = {
  'user-not-found',
  'wrong-password',
  'invalid-credential',
  'invalid-email',
};

const _phoneEmailDomain = 'phone.dccbogota.app';

/// Correo real, o correo sintético a partir de un teléfono (RF-9): ver
/// la decisión "Login por correo o teléfono" en plan.md.
String authEmailFor({String? email, String? phone}) {
  if (email != null) return email.trim();
  final digits = phone!.replaceAll(RegExp(r'[^0-9]'), '');
  return '$digits@$_phoneEmailDomain';
}

class FirebaseAuthRepositoryImpl implements AuthRepository {
  FirebaseAuthRepositoryImpl(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<String?> watchCurrentUid() =>
      _auth.authStateChanges().map((user) => user?.uid);

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
    assert(email != null || phone != null, 'register requiere email o phone');
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: authEmailFor(email: email, phone: phone),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw AuthUnexpectedException('No se pudo crear la cuenta.');
      }
      await _firestore.collection(accountsCollection).doc(uid).set(
            newAccountToFirestore(
              name: name,
              email: email,
              phone: phone,
              role: role,
              activeCourseIds: activeCourseIds,
              organization: organization,
            ),
          );
      return uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw DuplicateAccountException();
      }
      throw AuthUnexpectedException(
        e.message ?? 'No se pudo crear la cuenta. Intenta de nuevo.',
      );
    }
  }

  @override
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final isEmail = identifier.contains('@');
    try {
      await _auth.signInWithEmailAndPassword(
        email: authEmailFor(
          email: isEmail ? identifier : null,
          phone: isEmail ? null : identifier,
        ),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (_invalidCredentialCodes.contains(e.code)) {
        throw InvalidCredentialsException();
      }
      throw AuthUnexpectedException(
        e.message ?? 'No se pudo iniciar sesión. Intenta de nuevo.',
      );
    }
  }

  @override
  Future<void> logout() => _auth.signOut();
}
