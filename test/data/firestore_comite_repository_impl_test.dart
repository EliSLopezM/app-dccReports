import 'package:app_dcc_reports/data/firebase/firestore_comite_repository_impl.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('create (T4, RF-1/RF-3)', () {
    test('crea el comité y su chat de tipo comité en la misma operación', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreComiteRepositoryImpl(firestore);

      final comiteId = await repo.create(
        name: 'Comité Suba',
        address: 'Cra 1 # 2-3',
        leaderId: 'leader-uid',
      );

      final comiteDoc = await firestore.collection('comites').doc(comiteId).get();
      expect(comiteDoc.data()!['leaderId'], 'leader-uid');

      final chatQuery = await firestore
          .collection('chats')
          .where('comiteId', isEqualTo: comiteId)
          .get();
      expect(chatQuery.docs, hasLength(1));
      expect(chatQuery.docs.single.data()['kind'], 'comite');
    });
  });

  group('setDelegate (T5, RF-5)', () {
    test('el líder asigna delegado', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreComiteRepositoryImpl(firestore);
      final comiteId = await repo.create(
        name: 'Comité Suba',
        address: 'Cra 1 # 2-3',
        leaderId: 'leader-uid',
      );

      await repo.setDelegate(
        comiteId: comiteId,
        requesterId: 'leader-uid',
        delegateId: 'volunteer-uid',
      );

      final comite = await repo.watchComite(comiteId).first;
      expect(comite!.delegateId, 'volunteer-uid');
    });

    test('alguien que no es el líder no puede asignar delegado', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreComiteRepositoryImpl(firestore);
      final comiteId = await repo.create(
        name: 'Comité Suba',
        address: 'Cra 1 # 2-3',
        leaderId: 'leader-uid',
      );

      expect(
        () => repo.setDelegate(
          comiteId: comiteId,
          requesterId: 'someone-else',
          delegateId: 'volunteer-uid',
        ),
        throwsA(isA<NotComiteLeaderException>()),
      );
    });
  });
}
