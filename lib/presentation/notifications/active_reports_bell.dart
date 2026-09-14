import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/emergency_report.dart';
import '../../domain/repositories/emergency_report_repository.dart';
import 'active_reports_list_screen.dart';

// "Desde siempre": la campana no filtra por fecha (a diferencia del mapa,
// RF-1/RF-2) — cuenta todas las emergencias activas.
final _sinceBeginning = DateTime(2000);

/// RF-5/RF-6: campana con el conteo de emergencias activas, sin dirigirse
/// solo a grupos/comités cercanos todavía (spec 004 lo amplía).
class ActiveReportsBell extends StatelessWidget {
  const ActiveReportsBell({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.accountRole,
  });

  final String accountId;
  final String accountName;
  final AccountRole accountRole;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<EmergencyReportRepository>();

    return StreamBuilder<List<EmergencyReport>>(
      stream: repository.watchActiveReports(since: _sinceBeginning),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? const [];
        return IconButton(
          key: const Key('active-reports-bell'),
          tooltip: 'Emergencias activas',
          icon: Badge(
            label: Text('${reports.length}'),
            isLabelVisible: reports.isNotEmpty,
            child: const Icon(Icons.notifications),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ActiveReportsListScreen(
                reports: reports,
                accountId: accountId,
                accountName: accountName,
                accountRole: accountRole,
              ),
            ),
          ),
        );
      },
    );
  }
}
