import 'package:app_dcc_reports/domain/entities/comite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un comité válido se construye sin delegado (RF-1)', () {
    final comite = Comite(
      id: 'comite-1',
      name: 'Comité Suba',
      address: 'Cra 1 # 2-3',
      leaderId: 'leader-uid',
      createdAt: DateTime(2026, 9, 14),
    );

    expect(comite.delegateId, isNull);
  });

  test('un comité con delegado se construye (RF-5)', () {
    final comite = Comite(
      id: 'comite-1',
      name: 'Comité Suba',
      address: 'Cra 1 # 2-3',
      leaderId: 'leader-uid',
      delegateId: 'delegate-uid',
      createdAt: DateTime(2026, 9, 14),
    );

    expect(comite.delegateId, 'delegate-uid');
  });
}
