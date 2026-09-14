import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_kind.dart';
import '../../domain/entities/comite.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/comite_repository.dart';
import 'chat_mapper.dart';
import 'comite_mapper.dart';

class FirestoreComiteRepositoryImpl implements ComiteRepository {
  FirestoreComiteRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _comites =>
      _firestore.collection(comitesCollection);

  CollectionReference<Map<String, dynamic>> get _chats => _firestore.collection(chatsCollection);

  @override
  Future<String> create({
    required String name,
    required String address,
    required String leaderId,
    double? latitude,
    double? longitude,
  }) async {
    final comiteDoc = _comites.doc();
    final chatDoc = _chats.doc();
    final batch = _firestore.batch();
    batch.set(
      comiteDoc,
      newComiteToFirestore(
        name: name,
        address: address,
        leaderId: leaderId,
        latitude: latitude,
        longitude: longitude,
      ),
    );
    batch.set(
      chatDoc,
      newChatToFirestore(name: name, kind: ChatKind.comite, comiteId: comiteDoc.id),
    );
    await batch.commit();
    return comiteDoc.id;
  }

  @override
  Stream<List<Comite>> watchAllComites() {
    return _comites.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => comiteFromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Stream<Comite?> watchComite(String comiteId) {
    return _comites.doc(comiteId).snapshots().map(
          (doc) => doc.exists ? comiteFromFirestore(doc.id, doc.data()!) : null,
        );
  }

  @override
  Future<void> setDelegate({
    required String comiteId,
    required String requesterId,
    required String delegateId,
  }) async {
    final doc = await _comites.doc(comiteId).get();
    if (!doc.exists) throw ComiteNotFoundException();
    if (doc.data()!['leaderId'] != requesterId) {
      throw NotComiteLeaderException();
    }
    await _comites.doc(comiteId).update({'delegateId': delegateId});
  }
}
