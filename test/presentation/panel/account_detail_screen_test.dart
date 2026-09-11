import 'package:app_dcc_reports/domain/entities/account.dart';
import 'package:app_dcc_reports/domain/entities/account_role.dart';
import 'package:app_dcc_reports/domain/entities/account_status.dart';
import 'package:app_dcc_reports/domain/entities/organization_info.dart';
import 'package:app_dcc_reports/presentation/panel/account_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Account _buildAccount({
  required AccountRole role,
  OrganizationInfo? organization,
  List<String> activeCourseIds = const [],
}) {
  return Account(
    id: 'uid-1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: role,
    status: AccountStatus.pending,
    activeCourseIds: activeCourseIds,
    organization: organization,
    createdAt: DateTime(2026, 9, 11),
  );
}

void main() {
  testWidgets('muestra rango, estado y cursos de un voluntario (RF-12)', (tester) async {
    final account = _buildAccount(
      role: AccountRole.voluntario,
      activeCourseIds: const ['primeros_auxilios'],
    );

    await tester.pumpWidget(MaterialApp(home: AccountDetailScreen(account: account)));

    expect(find.text('Voluntario'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.textContaining('Primeros auxilios'), findsOneWidget);
  });

  testWidgets('muestra organización solo si la cuenta es funcionario/líder funcionario (RF-12)',
      (tester) async {
    final account = _buildAccount(
      role: AccountRole.funcionario,
      organization: const OrganizationInfo(name: 'Comité Suba', address: 'Cra 1 # 2-3'),
    );

    await tester.pumpWidget(MaterialApp(home: AccountDetailScreen(account: account)));

    expect(find.text('Comité Suba'), findsOneWidget);
    expect(find.text('Cra 1 # 2-3'), findsOneWidget);
  });

  testWidgets('un voluntario no muestra sección de organización', (tester) async {
    final account = _buildAccount(role: AccountRole.voluntario);

    await tester.pumpWidget(MaterialApp(home: AccountDetailScreen(account: account)));

    expect(find.text('Organización'), findsNothing);
  });
}
