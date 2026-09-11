import 'package:app_dcc_reports/data/firebase/firestore_emergency_report_repository_impl.dart';
import 'package:app_dcc_reports/domain/entities/report_status.dart';
import 'package:app_dcc_reports/domain/exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> _uploader(String reportId, String localPath, int index) async =>
    'https://storage.example/$reportId/$index.jpg';

void main() {
  group('submit (T4, RF-2/RF-3/RF-6)', () {
    test('reporte con 2+ fotos se crea en pending', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreEmergencyReportRepositoryImpl(firestore, uploadPhoto: _uploader);

      final id = await repo.submit(
        title: 'Incendio en bodega',
        address: 'Cra 68 # 24-10',
        emergencyTypeId: 'incendio',
        localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        deviceId: 'device-1',
      );

      final doc = await firestore.collection('reports').doc(id).get();
      expect(doc.data()!['status'], 'pending');
      expect(doc.data()!['photoUrls'], hasLength(2));
    });

    test('reporte con menos de 2 fotos lanza InvalidReportException', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreEmergencyReportRepositoryImpl(firestore, uploadPhoto: _uploader);

      expect(
        () => repo.submit(
          title: 'Incendio',
          address: 'Cra 68',
          emergencyTypeId: 'incendio',
          localPhotoPaths: const ['/tmp/a.jpg'],
          deviceId: 'device-1',
        ),
        throwsA(isA<InvalidReportException>()),
      );
    });

    test('título vacío lanza InvalidReportException', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreEmergencyReportRepositoryImpl(firestore, uploadPhoto: _uploader);

      expect(
        () => repo.submit(
          title: '',
          address: 'Cra 68',
          emergencyTypeId: 'incendio',
          localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
          deviceId: 'device-1',
        ),
        throwsA(isA<InvalidReportException>()),
      );
    });
  });

  group('antispam (T5, RF-7)', () {
    test('3 reportes seguidos pasan, el 4to se bloquea', () async {
      final firestore = FakeFirebaseFirestore();
      final fixedNow = DateTime(2026, 9, 11, 12);
      final repo = FirestoreEmergencyReportRepositoryImpl(
        firestore,
        uploadPhoto: _uploader,
        now: () => fixedNow,
      );

      for (var i = 0; i < 3; i++) {
        await repo.submit(
          title: 'Reporte $i',
          address: 'Dir $i',
          emergencyTypeId: 'incendio',
          localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
          deviceId: 'device-spam',
        );
      }

      expect(
        () => repo.submit(
          title: 'Reporte 4',
          address: 'Dir 4',
          emergencyTypeId: 'incendio',
          localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
          deviceId: 'device-spam',
        ),
        throwsA(isA<SpamLimitExceededException>()),
      );
    });

    test('pasada la ventana de una hora, se permite de nuevo', () async {
      final firestore = FakeFirebaseFirestore();
      var fixedNow = DateTime(2026, 9, 11, 12);
      final repo = FirestoreEmergencyReportRepositoryImpl(
        firestore,
        uploadPhoto: _uploader,
        now: () => fixedNow,
      );

      for (var i = 0; i < 3; i++) {
        await repo.submit(
          title: 'Reporte $i',
          address: 'Dir $i',
          emergencyTypeId: 'incendio',
          localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
          deviceId: 'device-spam-2',
        );
      }

      fixedNow = fixedNow.add(const Duration(hours: 2));

      await expectLater(
        repo.submit(
          title: 'Reporte tardío',
          address: 'Dir tardía',
          emergencyTypeId: 'incendio',
          localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
          deviceId: 'device-spam-2',
        ),
        completes,
      );
    });
  });

  group('lectura (T6, RF-8/RF-12)', () {
    test('watchAllReports trae todos los reportes', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreEmergencyReportRepositoryImpl(firestore, uploadPhoto: _uploader);
      await repo.submit(
        title: 'R1',
        address: 'D1',
        emergencyTypeId: 'incendio',
        localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        deviceId: 'device-a',
      );
      await repo.submit(
        title: 'R2',
        address: 'D2',
        emergencyTypeId: 'sismo_estructura_afectada',
        localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        deviceId: 'device-b',
      );

      final reports = await repo.watchAllReports().first;

      expect(reports, hasLength(2));
    });

    test('watchReportsByDevice filtra por deviceId', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreEmergencyReportRepositoryImpl(firestore, uploadPhoto: _uploader);
      await repo.submit(
        title: 'R1',
        address: 'D1',
        emergencyTypeId: 'incendio',
        localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        deviceId: 'device-a',
      );
      await repo.submit(
        title: 'R2',
        address: 'D2',
        emergencyTypeId: 'incendio',
        localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        deviceId: 'device-b',
      );

      final reports = await repo.watchReportsByDevice('device-a').first;

      expect(reports, hasLength(1));
      expect(reports.single.reporterEvidence.deviceId, 'device-a');
    });

    test('watchReportsByPhone filtra por teléfono', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreEmergencyReportRepositoryImpl(firestore, uploadPhoto: _uploader);
      await repo.submit(
        title: 'R1',
        address: 'D1',
        emergencyTypeId: 'incendio',
        localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        deviceId: 'device-a',
        reporterPhone: '3001234567',
      );

      final reports = await repo.watchReportsByPhone('3001234567').first;

      expect(reports, hasLength(1));
    });
  });

  group('updateStatus (T7, RF-9/RF-10)', () {
    test('pasa de pending a activa, y de activa a falsaControlada', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FirestoreEmergencyReportRepositoryImpl(firestore, uploadPhoto: _uploader);
      final id = await repo.submit(
        title: 'R1',
        address: 'D1',
        emergencyTypeId: 'incendio',
        localPhotoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
        deviceId: 'device-a',
      );

      await repo.updateStatus(
        reviewerId: 'reviewer-1',
        reportId: id,
        newStatus: ReportStatus.activa,
      );
      var doc = await firestore.collection('reports').doc(id).get();
      expect(doc.data()!['status'], 'activa');

      await repo.updateStatus(
        reviewerId: 'reviewer-1',
        reportId: id,
        newStatus: ReportStatus.falsaControlada,
      );
      doc = await firestore.collection('reports').doc(id).get();
      expect(doc.data()!['status'], 'falsaControlada');
    });
  });
}
