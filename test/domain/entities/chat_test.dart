import 'package:app_dcc_reports/domain/entities/chat.dart';
import 'package:app_dcc_reports/domain/entities/chat_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 14);

  test('chat de comité requiere comiteId (RF-3)', () {
    final chat = Chat(
      id: 'chat-1',
      name: 'Comité Suba',
      kind: ChatKind.comite,
      comiteId: 'comite-1',
      createdAt: now,
    );

    expect(chat.comiteId, 'comite-1');
  });

  test('chat de comité sin comiteId lanza un assertion error', () {
    expect(
      () => Chat(id: 'chat-1', name: 'X', kind: ChatKind.comite, createdAt: now),
      throwsA(isA<AssertionError>()),
    );
  });

  test('chat personalizado requiere createdBy (RF-7)', () {
    final chat = Chat(
      id: 'chat-1',
      name: 'Grupo de trabajo',
      kind: ChatKind.custom,
      createdBy: 'funcionario-uid',
      createdAt: now,
    );

    expect(chat.createdBy, 'funcionario-uid');
  });

  test('chat de departamento no lleva comiteId ni createdBy (RF-6)', () {
    final chat = Chat(
      id: 'dept-bogota',
      name: 'DCC Bogotá',
      kind: ChatKind.department,
      createdAt: now,
    );

    expect(chat.comiteId, isNull);
    expect(chat.createdBy, isNull);
  });
}
