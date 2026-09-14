import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/account_repository.dart';
import 'account_mapper.dart';

class FirestoreAccountRepositoryImpl implements AccountRepository {
  FirestoreAccountRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _accounts =>
      _firestore.collection(accountsCollection);

  @override
  Stream<Account?> watchAccount(String uid) {
    return _accounts.doc(uid).snapshots().map(
          (doc) => doc.exists ? accountFromFirestore(doc.id, doc.data()!) : null,
        );
  }

  @override
  Stream<List<Account>> watchAllAccounts() {
    return _accounts.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => accountFromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<Account>> watchPendingAccounts() {
    return _accounts.where('status', isEqualTo: AccountStatus.pending.name).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => accountFromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// RF-7: solo Admin revisa cuentas de rango funcionario/liderFuncionario.
  Future<void> _assertCanReview(AccountRole reviewerRole, String accountId) async {
    final target = await _accounts.doc(accountId).get();
    if (!target.exists) throw AccountNotFoundException();
    final targetRole = AccountRole.values.byName(target.data()!['role'] as String);
    if (!canReview(reviewerRole: reviewerRole, targetRole: targetRole)) {
      throw InsufficientReviewPermissionException();
    }
  }

  @override
  Future<void> approve({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
  }) async {
    await _assertCanReview(reviewerRole, accountId);
    await _accounts.doc(accountId).update({
      'status': AccountStatus.approved.name,
      'reviewedBy': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reject({
    required AccountRole reviewerRole,
    required String reviewerId,
    required String accountId,
    String? reason,
  }) async {
    await _assertCanReview(reviewerRole, accountId);
    await _accounts.doc(accountId).update({
      'status': AccountStatus.rejected.name,
      'reviewedBy': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': ?reason,
    });
  }

  @override
  Future<void> setComite({required String uid, required String comiteId}) async {
    await _accounts.doc(uid).update({'comiteId': comiteId});
  }
}
