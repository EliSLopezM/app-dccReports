import 'package:app_dcc_reports/data/firebase/firestore_participation_repository_impl.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/difficulty_level.dart';
import 'package:app_dcc_reports/domain/entities/participation_status.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('goTo (T4, RF-1)', () {
    test('crea la participación en going', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);

      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );

      final participation = await repo
          .watchMyParticipation(reportId: 'report-1', accountId: 'uid-1')
          .first;
      expect(participation!.status, ParticipationStatus.going);
    });

    test('llamarlo dos veces no duplica ni resetea el progreso', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);
      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );
      await repo.arrive(reportId: 'report-1', accountId: 'uid-1');

      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );

      final participation = await repo
          .watchMyParticipation(reportId: 'report-1', accountId: 'uid-1')
          .first;
      expect(participation!.status, ParticipationStatus.arrived);
    });
  });

  group('arrive (T4, RF-4)', () {
    test('marca arrived con la hora', () async {
      final firestore = FakeFirebaseFirestore();
      final now = DateTime(2026, 9, 14, 10);
      final repo = FirestoreParticipationRepositoryImpl(
        firestore,
        now: () => now,
      );
      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );

      await repo.arrive(reportId: 'report-1', accountId: 'uid-1');

      final participation = await repo
          .watchMyParticipation(reportId: 'report-1', accountId: 'uid-1')
          .first;
      expect(participation!.status, ParticipationStatus.arrived);
      expect(participation.arrivedAt, now);
    });
  });

  group('setMeetingPoint (T5, RF-7/RF-8)', () {
    test('un voluntario pone el primer punto de encuentro', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);

      await repo.setMeetingPoint(
        reportId: 'report-1',
        requesterId: 'uid-1',
        requesterRole: AccountRole.voluntario,
        latitude: 4.6,
        longitude: -74.1,
      );

      final point = await repo.watchMeetingPoint('report-1').first;
      expect(point!.setByUid, 'uid-1');
    });

    test('un segundo voluntario no puede poner otro (RF-8)', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);
      await repo.setMeetingPoint(
        reportId: 'report-1',
        requesterId: 'uid-1',
        requesterRole: AccountRole.voluntario,
        latitude: 4.6,
        longitude: -74.1,
      );

      expect(
        () => repo.setMeetingPoint(
          reportId: 'report-1',
          requesterId: 'uid-2',
          requesterRole: AccountRole.voluntario,
          latitude: 4.61,
          longitude: -74.11,
        ),
        throwsA(isA<MeetingPointBlockedException>()),
      );
    });

    test('un funcionario reemplaza el punto de un voluntario', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);
      await repo.setMeetingPoint(
        reportId: 'report-1',
        requesterId: 'uid-1',
        requesterRole: AccountRole.voluntario,
        latitude: 4.6,
        longitude: -74.1,
      );

      await repo.setMeetingPoint(
        reportId: 'report-1',
        requesterId: 'funcionario-uid',
        requesterRole: AccountRole.funcionario,
        latitude: 4.65,
        longitude: -74.15,
      );

      final point = await repo.watchMeetingPoint('report-1').first;
      expect(point!.setByUid, 'funcionario-uid');
    });

    test('el mismo voluntario que lo puso lo puede cambiar', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);
      await repo.setMeetingPoint(
        reportId: 'report-1',
        requesterId: 'uid-1',
        requesterRole: AccountRole.voluntario,
        latitude: 4.6,
        longitude: -74.1,
      );

      await expectLater(
        repo.setMeetingPoint(
          reportId: 'report-1',
          requesterId: 'uid-1',
          requesterRole: AccountRole.voluntario,
          latitude: 4.62,
          longitude: -74.12,
        ),
        completes,
      );
    });
  });

  group('requestAmbulance (T6, RF-9)', () {
    test('registra el timestamp y se puede llamar más de una vez', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);
      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );

      await repo.requestAmbulance(reportId: 'report-1', accountId: 'uid-1');
      await expectLater(
        repo.requestAmbulance(reportId: 'report-1', accountId: 'uid-1'),
        completes,
      );

      final participation = await repo
          .watchMyParticipation(reportId: 'report-1', accountId: 'uid-1')
          .first;
      expect(participation!.ambulanceRequestedAt, isNotNull);
    });
  });

  group('finishCompleted / finishWithdrawn (T7, RF-10/RF-11)', () {
    test('finishCompleted calcula los tiempos y sube la foto', () async {
      final firestore = FakeFirebaseFirestore();
      final goingAt = DateTime(2026, 9, 14, 10);
      final arrivedAt = DateTime(2026, 9, 14, 10, 20);
      final finishedAt = DateTime(2026, 9, 14, 11, 20);
      var now = goingAt;
      final repo = FirestoreParticipationRepositoryImpl(
        firestore,
        now: () => now,
        uploadPhoto: (reportId, accountId, path) async =>
            'https://storage.example/$path',
      );

      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );
      now = arrivedAt;
      await repo.arrive(reportId: 'report-1', accountId: 'uid-1');
      now = finishedAt;
      await repo.finishCompleted(
        reportId: 'report-1',
        accountId: 'uid-1',
        localPhotoPath: '/tmp/finish.jpg',
        difficultyLevel: DifficultyLevel.media,
      );

      final participation = await repo
          .watchMyParticipation(reportId: 'report-1', accountId: 'uid-1')
          .first;
      expect(participation!.timeToArrive, const Duration(minutes: 20));
      expect(participation.timeAtEmergency, const Duration(hours: 1));
      expect(participation.photoUrl, 'https://storage.example//tmp/finish.jpg');
    });

    test('finishWithdrawn guarda la razón', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);
      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );
      await repo.arrive(reportId: 'report-1', accountId: 'uid-1');

      await repo.finishWithdrawn(
        reportId: 'report-1',
        accountId: 'uid-1',
        reason: 'Emergencia familiar',
        difficultyLevel: DifficultyLevel.baja,
      );

      final participation = await repo
          .watchMyParticipation(reportId: 'report-1', accountId: 'uid-1')
          .first;
      expect(participation!.reason, 'Emergencia familiar');
    });

    test('finalizar sin haber llegado lanza NotArrivedException', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);
      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );

      expect(
        () => repo.finishWithdrawn(
          reportId: 'report-1',
          accountId: 'uid-1',
          reason: 'No pude llegar',
          difficultyLevel: DifficultyLevel.baja,
        ),
        throwsA(isA<NotArrivedException>()),
      );
    });
  });

  group('goTo guarda accountId/reportTitle/emergencyTypeId (T4, RF-3 spec 006)', () {
    test('el documento tiene los tres campos', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);

      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio en bodega',
        emergencyTypeId: 'incendio',
      );

      final doc = await firestore
          .collection('reports')
          .doc('report-1')
          .collection('participations')
          .doc('uid-1')
          .get();
      expect(doc.data()!['accountId'], 'uid-1');
      expect(doc.data()!['reportTitle'], 'Incendio en bodega');
      expect(doc.data()!['emergencyTypeId'], 'incendio');
    });
  });

  group('watchParticipationsForAccount (T5, RF-4 spec 006)', () {
    test('trae las participaciones de la cuenta en varios reportes', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreParticipationRepositoryImpl(firestore);

      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );
      await repo.goTo(
        reportId: 'report-2',
        accountId: 'uid-1',
        accountName: 'Jane',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Inundación',
        emergencyTypeId: 'inundacion',
      );
      await repo.goTo(
        reportId: 'report-1',
        accountId: 'uid-2',
        accountName: 'John',
        accountRole: AccountRole.voluntario,
        reportTitle: 'Incendio',
        emergencyTypeId: 'incendio',
      );

      final history = await repo.watchParticipationsForAccount('uid-1').first;

      expect(history, hasLength(2));
      expect(history.map((p) => p.reportId), containsAll(['report-1', 'report-2']));
    });
  });
}
